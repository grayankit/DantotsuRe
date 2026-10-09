import 'dart:async';

import 'package:collection/collection.dart';

import '../../Utils/Functions/RefreshController.dart';
import '../../Utils/Functions/SnackBar.dart';
import '../Preferences/Incognito.dart';
import '../Preferences/PrefManager.dart';
import '../Services/MediaServiceController.dart';
import '../State/State.dart';
import '../ThemeManager/LanguageSwitcher.dart';
import '../Services/Model/Media.dart';
import 'SyncAdapter.dart';
import 'SyncIdIndex.dart';
import 'SyncModels.dart';
import 'SyncPlanner.dart';

enum SyncPhase { idle, fetching, syncing }

class SyncController extends AppController {
  static const _planKey = 'syncPlan';
  static const _stampKey = 'syncStamps';

  final phase = SyncPhase.idle.live;
  final anime = true.live;
  final plan = Live<SyncPlan?>(null);
  final fetchDone = 0.live;
  final fetchTotal = 0.live;
  final fetchLabel = ''.live;
  final error = Live<String?>(null);
  final resumeAt = <String, DateTime>{}.liveMap;
  final targetError = <String, String>{}.liveMap;
  final clock = 0.live;
  final changes = Trigger();

  final _stamps = <String, List<int>>{};
  final _holds = <String, DateTime>{};
  bool _stop = false;
  Timer? _saver;
  Timer? _auto;
  bool _autoBusy = false;

  List<MediaService> get _services => find<MediaServiceController>().services;

  MediaService? get mainService =>
      _services.firstWhereOrNull((s) => s.id == mainId);

  String get mainId {
    final saved = PrefName.syncMain.rx.value;
    if (_candidates.any((s) => s.id == saved)) return saved;
    return _candidates.firstOrNull?.id ?? '';
  }

  List<MediaService> get _candidates => [
    for (final s in _services)
      if (s.syncAdapter != null && s.isLoggedIn) s,
  ];

  List<MediaService> get candidates => _candidates;

  List<MediaService> targetsFor(String main, bool isAnime) => [
    for (final s in _candidates)
      if (s.id != main && s.syncAdapter!.supports(anime: isAnime)) s,
  ];

  bool get busy => phase.value != SyncPhase.idle;

  @override
  void onInit() {
    super.onInit();
    final raw = loadCustomData<Map>(_planKey, location: PrefLocation.CACHE);
    if (raw != null) {
      try {
        final restored = SyncPlan.fromJson(Map<String, dynamic>.from(raw));
        plan.value = restored;
        anime.value = restored.anime;
      } catch (_) {
        removeCustomData(_planKey, location: PrefLocation.CACHE);
      }
    }
    final stamps = loadCustomData<Map>(_stampKey, location: PrefLocation.CACHE);
    if (stamps != null) {
      for (final e in stamps.entries) {
        _stamps['${e.key}'] = [
          for (final v in e.value as List) (v as num).toInt(),
        ];
      }
    }
  }

  @override
  void onClose() {
    _saver?.cancel();
    _auto?.cancel();
    super.onClose();
  }

  void startAuto() {
    _auto?.cancel();
    _auto = Timer.periodic(const Duration(minutes: 30), (_) => _autoRun());
    Timer(const Duration(seconds: 45), _autoRun);
  }

  Future<void> _autoRun() async {
    if (!PrefName.syncAuto.value || busy || _autoBusy) return;
    if (incognitoBlocksEdits || mainService == null) return;
    _autoBusy = true;
    try {
      for (final isAnime in [true, false]) {
        if (targetsFor(mainId, isAnime).isEmpty) continue;
        if (!mainService!.syncAdapter!.supports(anime: isAnime)) continue;
        await fetch(anime: isAnime);
        if (plan.value?.hasPending == true) await start();
      }
    } finally {
      _autoBusy = false;
    }
  }

  Future<void> fetch({bool? anime}) async {
    if (busy) return;
    final isAnime = anime ?? this.anime.value;
    this.anime.value = isAnime;
    final main = mainService;
    final adapter = main?.syncAdapter;
    if (main == null || adapter == null || !adapter.supports(anime: isAnime)) {
      error.value = getString.syncNothingToSync;
      return;
    }
    final targets = targetsFor(main.id, isAnime);
    if (targets.isEmpty) {
      error.value = getString.syncNoTargets;
      return;
    }
    phase.value = SyncPhase.fetching;
    error.value = null;
    targetError.clear();
    fetchDone.value = 0;
    fetchTotal.value = targets.length + 1 + (isAnime ? 1 : 0);
    try {
      SyncIdIndex? index;
      if (isAnime) {
        fetchLabel.value = getString.syncLoadingMap;
        index = await SyncIdIndex.load();
        fetchDone.value++;
      }
      fetchLabel.value = main.name;
      final mainItems = expandItems(
        await adapter.library(anime: isAnime),
        index,
        adapter.key,
      );
      fetchDone.value++;
      final loaded = await Future.wait([
        for (final t in targets) _loadTarget(t, isAnime, index),
      ]);
      final onlyForward = PrefName.syncOnlyForward.value;
      final result = <String, SyncTargetPlan>{};
      for (var i = 0; i < targets.length; i++) {
        final t = targets[i];
        final items = loaded[i];
        result[t.id] = items.$1 == null
            ? SyncTargetPlan(const [], error: items.$2)
            : planTarget(
                main: mainItems,
                target: items.$1!,
                adapter: t.syncAdapter!,
                mainAdapter: adapter,
                anime: isAnime,
                onlyForward: onlyForward,
              );
      }
      plan.value = SyncPlan(
        main: main.id,
        anime: isAnime,
        targets: result,
        mainCount: mainItems.length,
      );
      _saveNow();
    } on SyncFatal catch (e) {
      error.value = e.message;
    } catch (e) {
      error.value = '$e';
    } finally {
      phase.value = SyncPhase.idle;
      changes.fire();
    }
  }

  Future<(List<SyncItem>?, String?)> _loadTarget(
    MediaService service,
    bool isAnime,
    SyncIdIndex? index,
  ) async {
    try {
      final adapter = service.syncAdapter!;
      final items = expandItems(
        await adapter.library(anime: isAnime),
        index,
        adapter.key,
      );
      return (items, null);
    } catch (e) {
      return (null, '$e');
    } finally {
      fetchDone.value++;
      fetchLabel.value = service.name;
    }
  }

  Future<void> start({String? only}) async {
    final current = plan.value;
    if (busy || current == null) return;
    if (incognitoBlocksEdits) {
      snackString(getString.incognitoEditsBlocked);
      return;
    }
    phase.value = SyncPhase.syncing;
    _stop = false;
    for (final t in current.targets.values) {
      for (final p in t.pairs) {
        if (p.op == SyncOpState.failed) p.op = SyncOpState.idle;
      }
    }
    targetError.clear();
    try {
      await Future.wait([
        for (final id in current.targets.keys)
          if (only == null || only == id) _work(id, current),
      ]);
    } finally {
      for (final id in current.targets.keys) {
        await _services
            .firstWhereOrNull((s) => s.id == id)
            ?.syncAdapter
            ?.finish();
      }
      phase.value = SyncPhase.idle;
      resumeAt.clear();
      _saveNow();
      changes.fire();
      tryFind<RefreshController>()?.all();
    }
  }

  void stop() => _stop = true;

  bool canPush(MediaService service, bool anime) =>
      service.id == mainId &&
      service.syncAdapter != null &&
      targetsFor(service.id, anime).isNotEmpty;

  Future<void> pushEdit(MediaService service, Media media) async {
    final adapter = service.syncAdapter;
    if (adapter == null || incognitoBlocksEdits) return;
    final isAnime = media.isAnime;
    final targets = targetsFor(service.id, isAnime);
    if (targets.isEmpty) return;
    var ids = adapter.idsOf(media);
    if (isAnime) {
      try {
        ids = (await SyncIdIndex.load()).expand(ids, prefer: adapter.key);
      } catch (_) {}
    }
    final want = SyncItem.fromMedia(media, ids);
    final done = <String>[];
    for (final target in targets) {
      final other = target.syncAdapter!;
      try {
        var targetId = switch (ids[other.key]) {
          final native? => other.targetId(native, anime: isAnime),
          _ => null,
        };
        final mal = ids[SyncKey.mal];
        if (targetId == null && other.canResolve && mal != null) {
          final (found, used) = await other.resolve([mal], anime: isAnime);
          _stamp(target.id, used);
          final native = found[mal];
          if (native != null) targetId = other.targetId(native, anime: isAnime);
        }
        if (targetId == null) continue;
        final wait = _waitFor(target.id, other);
        if (wait > const Duration(seconds: 20)) {
          snackString(
            getString.syncPushFailed(target.name, getString.syncRateLimited),
          );
          continue;
        }
        if (wait > Duration.zero) await Future<void>.delayed(wait);
        final used = await other.write([
          SyncOp(want, null, targetId),
        ], anime: isAnime);
        _stamp(target.id, used);
        await other.finish();
        done.add(target.name);
      } on SyncRateLimited catch (e) {
        _holds[target.id] = DateTime.now().add(e.retryAfter);
        snackString(getString.syncPushFailed(target.name, '$e'));
      } catch (e) {
        snackString(getString.syncPushFailed(target.name, '$e'));
      }
    }
    if (done.isNotEmpty) {
      snackString(getString.syncPushed(done.join(', ')));
      _saveSoon();
    }
  }

  bool _wanted(SyncPair p) =>
      p.pending &&
      (p.state == SyncStatus.outdated ||
          PrefName.syncAddMissing.rx.value && p.state == SyncStatus.missing);

  Future<void> _work(String id, SyncPlan current) async {
    final service = _services.firstWhereOrNull((s) => s.id == id);
    final adapter = service?.syncAdapter;
    if (service == null || adapter == null) return;
    final pairs = current.targets[id]!.pairs.where(_wanted).toList();
    await _resolve(id, service, adapter, pairs, current.anime);
    while (!_stop) {
      final todo = pairs
          .where((p) => _wanted(p) && p.op != SyncOpState.failed)
          .take(adapter.batchSize)
          .toList();
      if (todo.isEmpty) break;
      final wait = _waitFor(id, adapter);
      if (wait > Duration.zero) {
        await _sleep(id, wait);
        continue;
      }
      resumeAt.remove(id);
      try {
        await _send(id, adapter, todo, current.anime);
      } on SyncRateLimited catch (e) {
        _holds[id] = DateTime.now().add(e.retryAfter);
      } on SyncFatal catch (e) {
        targetError[id] = e.message;
        break;
      }
      changes.fire();
      _saveSoon();
    }
  }

  Future<void> _resolve(
    String id,
    MediaService service,
    SyncAdapter adapter,
    List<SyncPair> pairs,
    bool isAnime,
  ) async {
    if (!adapter.canResolve) return;
    final open = [
      for (final p in pairs)
        if (p.targetId == null && p.main.ids[SyncKey.mal] != null) p,
    ];
    var at = 0;
    while (at < open.length && !_stop) {
      final wait = _waitFor(id, adapter);
      if (wait > Duration.zero) {
        await _sleep(id, wait);
        continue;
      }
      final chunk = open.sublist(
        at,
        (at + adapter.resolveBatch).clamp(0, open.length),
      );
      try {
        final (found, used) = await adapter.resolve([
          for (final p in chunk) p.main.ids[SyncKey.mal]!,
        ], anime: isAnime);
        _stamp(id, used);
        for (final p in chunk) {
          final native = found[p.main.ids[SyncKey.mal]];
          final target = native == null
              ? null
              : adapter.targetId(native, anime: isAnime);
          if (target != null) {
            p.targetId = target;
          } else {
            p
              ..op = SyncOpState.failed
              ..error = getString.syncNotFound(service.name);
          }
        }
        at += chunk.length;
      } on SyncRateLimited catch (e) {
        _stamp(id, 1);
        _holds[id] = DateTime.now().add(e.retryAfter);
      } on SyncFatal catch (e) {
        targetError[id] = e.message;
        return;
      } catch (e) {
        _stamp(id, 1);
        for (final p in chunk) {
          p
            ..op = SyncOpState.failed
            ..error = '$e';
        }
        at += chunk.length;
      }
      changes.fire();
      _saveSoon();
    }
  }

  Future<void> _send(
    String id,
    SyncAdapter adapter,
    List<SyncPair> batch,
    bool isAnime,
  ) async {
    SyncOp op(SyncPair p) => SyncOp(p.want, p.target, p.targetId!);
    try {
      final used = await adapter.write([
        for (final p in batch) op(p),
      ], anime: isAnime);
      _stamp(id, used);
      for (final p in batch) {
        _done(p);
      }
    } on SyncRateLimited {
      _stamp(id, adapter.requestsPerBatch);
      rethrow;
    } on SyncFatal {
      rethrow;
    } catch (e) {
      _stamp(id, 1);
      if (batch.length == 1) {
        batch.first
          ..op = SyncOpState.failed
          ..error = '$e';
        return;
      }
      for (final p in batch) {
        if (_stop) return;
        await _send(id, adapter, [p], isAnime);
      }
    }
  }

  void _done(SyncPair p) {
    p
      ..target = p.want.asTarget(p.targetId!, previous: p.target)
      ..state = SyncStatus.synced
      ..op = SyncOpState.done
      ..error = null;
  }

  Duration _waitFor(String id, SyncAdapter adapter) {
    final now = DateTime.now();
    var until = _holds[id];
    if (until != null && !until.isAfter(now)) {
      _holds.remove(id);
      until = null;
    }
    final stamps = [...?_stamps[id]]..sort();
    for (final limit in adapter.limits) {
      final from = now.millisecondsSinceEpoch - limit.per.inMilliseconds;
      final inside = stamps.where((s) => s > from).toList();
      final excess = inside.length + adapter.requestsPerBatch - limit.requests;
      if (excess <= 0) continue;
      final free = DateTime.fromMillisecondsSinceEpoch(
        inside[(excess - 1).clamp(0, inside.length - 1)] +
            limit.per.inMilliseconds,
      );
      if (until == null || free.isAfter(until)) until = free;
    }
    if (until == null) return Duration.zero;
    final left = until.difference(now);
    return left.isNegative
        ? Duration.zero
        : left + const Duration(milliseconds: 50);
  }

  Future<void> _sleep(String id, Duration wait) async {
    final until = DateTime.now().add(wait);
    resumeAt[id] = until;
    while (!_stop) {
      final left = until.difference(DateTime.now());
      if (left <= Duration.zero) break;
      await Future<void>.delayed(
        left < const Duration(seconds: 1) ? left : const Duration(seconds: 1),
      );
      clock.value++;
    }
  }

  void _stamp(String id, int count) {
    final now = DateTime.now().millisecondsSinceEpoch;
    final day = now - const Duration(days: 1).inMilliseconds;
    final list = (_stamps[id] ??= [])
      ..removeWhere((s) => s < day)
      ..addAll(List.filled(count, now));
    _stamps[id] = list;
  }

  int usedIn(String id, SyncLimit limit) {
    final from =
        DateTime.now().millisecondsSinceEpoch - limit.per.inMilliseconds;
    return (_stamps[id] ?? const <int>[]).where((s) => s > from).length;
  }

  void clear() {
    if (busy) return;
    plan.value = null;
    removeCustomData(_planKey, location: PrefLocation.CACHE);
  }

  void _saveSoon() {
    _saver ??= Timer(const Duration(seconds: 3), _saveNow);
  }

  void _saveNow() {
    _saver?.cancel();
    _saver = null;
    final current = plan.value;
    if (current != null) {
      saveCustomData<Map<String, dynamic>>(
        _planKey,
        current.toJson(),
        location: PrefLocation.CACHE,
      );
    }
    saveCustomData<Map<String, dynamic>>(
      _stampKey,
      _stamps,
      location: PrefLocation.CACHE,
    );
  }
}
