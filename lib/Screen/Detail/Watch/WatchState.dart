import 'dart:async';

import 'package:dartotsu_extension_bridge/dartotsu_extension_bridge.dart';
import 'package:flutter/foundation.dart';

import '../../../Api/Services/Extension/Services.dart';
import '../../../Core/Services/MediaService.dart';
import '../../../Core/Services/Model/Media.dart';
import '../../../Core/State/State.dart';
import '../../../Core/ThemeManager/LanguageSwitcher.dart';
import '../../../Core/Watch/EpisodeMeta.dart';
import '../../../Core/Watch/EpisodeMetaService.dart';
import '../../../Core/Watch/EpisodeUnits.dart';
import '../../../Core/Watch/MediaIdResolver.dart';
import '../../../Core/Watch/SourceMatcher.dart';
import '../../../Core/Watch/WatchPrefs.dart';
import '../../../Logger.dart';
import '../../../Utils/Functions/SnackBar.dart';
import '../../../Widgets/Components/ScreenState.dart';

enum WatchPhase { sources, searching, loading, ready, empty, noSource, failed }

class WatchState extends ScreenState {
  final MediaService service;
  final Live<Media> media;
  final Mutations? mutations;

  WatchState({required this.service, required this.media, this.mutations});

  Media get current => media.value;

  bool get anime => current.isAnime;

  bool get fixedSource => current.sourceData != null;

  ItemType get itemType => anime
      ? ItemType.anime
      : current.format?.toLowerCase() == 'novel'
      ? ItemType.novel
      : ItemType.manga;

  final phase = WatchPhase.sources.live;
  final status = ''.live;
  final failure = Live<String?>(null);
  final sources = <Source>[].liveList;
  final source = Live<Source?>(null);
  final match = Live<DMedia?>(null);
  final settings = Live<MediaWatchSettings>(MediaWatchSettings());
  final episodes = <DEpisode>[].liveList;
  final meta = Live<Map<String, EpisodeMeta>>(const {});
  final metaLoading = false.live;
  final units = <WatchUnit>[].liveList;
  final scanlators = <String>[].liveList;
  final chunk = 0.live;
  int _generation = 0;
  int _metaGeneration = 0;
  Disposer? _progressSub;
  Disposer? _prefsSub;
  StreamSubscription<Map<String, EpisodeMeta>>? _metaSub;
  bool _chunkPinned = false;

  int get progress => current.userProgress ?? 0;

  String get title => anime ? getString.episodes : getString.chapters;

  @override
  void onInit() {
    settings.value = MediaWatchSettings.load(service, current);
    _progressSub = onChange(media, (_) => _pickChunk());
    _prefsSub = onAnyChange([
      watchChunkSizePref.rx,
      watchShowFillerPref.rx,
    ], _derive);
    unawaited(start());
  }

  @override
  void onClose() {
    _generation++;
    _metaGeneration++;
    _progressSub?.dispose();
    _prefsSub?.dispose();
    unawaited(_metaSub?.cancel());
  }

  Future<void> start() async {
    final generation = ++_generation;
    phase.value = WatchPhase.sources;
    failure.value = null;
    if (anime) unawaited(_loadMeta());
    if (fixedSource) {
      final fixed = current.sourceData!;
      if (!isSourceInstalled(fixed)) {
        phase.value = WatchPhase.noSource;
        return;
      }
      source.value = fixed;
      sources.value = [fixed];
      await _loadEpisodes(DMedia.withUrl(current.shareLink), generation);
      return;
    }
    await ensureSourcesReady(itemType);
    if (generation != _generation) return;
    final list = loadedSources(itemType);
    sources.value = list;
    if (list.isEmpty) {
      source.value = null;
      phase.value = WatchPhase.noSource;
      return;
    }
    final wanted = settings.value.sourceId;
    final next = list.where((s) => s.id == wanted).firstOrNull ?? list.first;
    await selectSource(next, remember: false);
  }

  Future<void> selectSource(Source next, {bool remember = true}) async {
    final generation = ++_generation;
    source.value = next;
    if (remember) {
      settings.value
        ..sourceId = next.id
        ..sourceName = next.name;
      settings.value.save(service, current);
    }
    episodes.clear();
    units.clear();
    match.value = null;
    phase.value = WatchPhase.searching;
    status.value = getString.watchSearching;
    final saved = SourceMatcher.saved(service, next, current);
    if (saved != null) {
      match.value = saved;
      status.value = getString.watchSelected(saved.title ?? '');
      await _loadEpisodes(saved, generation);
      return;
    }
    try {
      final found = await SourceMatcher.find(
        next,
        current,
        mode: settings.value.match,
        onStatus: (term) {
          if (generation == _generation) {
            status.value = getString.watchSearchingFor(term);
          }
        },
      );
      if (generation != _generation) return;
      if (found == null) {
        status.value = getString.watchNothingFound;
        phase.value = WatchPhase.empty;
        return;
      }
      SourceMatcher.save(service, next, current, found);
      match.value = found;
      status.value = getString.watchFound(found.title ?? '');
      await _loadEpisodes(found, generation);
    } catch (e, st) {
      if (generation != _generation) return;
      logger(
        'Watch search failed: $e\n$st',
        logLevel: LogLevel.error,
        tag: 'WATCH',
      );
      failure.value = e.toString();
      status.value = getString.watchSearchFailed;
      phase.value = WatchPhase.failed;
    }
  }

  Future<void> chooseMatch(DMedia picked) async {
    final src = source.value;
    if (src == null) return;
    final generation = ++_generation;
    SourceMatcher.save(service, src, current, picked);
    match.value = picked;
    status.value = getString.watchSelected(picked.title ?? '');
    episodes.clear();
    units.clear();
    await _loadEpisodes(picked, generation);
  }

  Future<void> resetMatch() async {
    final src = source.value;
    if (src == null || fixedSource) return;
    SourceMatcher.forget(service, src, current);
    await selectSource(src, remember: false);
  }

  Future<void> _loadEpisodes(DMedia target, int generation) async {
    final src = source.value;
    if (src == null) return;
    phase.value = WatchPhase.loading;
    try {
      final detail = await src.methods.getDetail(target);
      if (generation != _generation) return;
      final raw = detail.episodes ?? const <DEpisode>[];
      if (raw.isEmpty) {
        failure.value = null;
        phase.value = WatchPhase.empty;
        return;
      }
      final normalized = !anime
          ? prepareChapters(raw, current.mainName)
          : raw.length < 50
          ? normalizeEpisodes(raw)
          : await compute(normalizeIsolate, raw);
      if (generation != _generation) return;
      episodes.value = normalized;
      scanlators.value = {
        for (final e in normalized)
          if (e.scanlator?.isNotEmpty ?? false) e.scanlator!,
      }.toList();
      failure.value = null;
      _chunkPinned = false;
      _derive();
      phase.value = WatchPhase.ready;
    } catch (e, st) {
      if (generation != _generation) return;
      logger(
        'Watch episodes failed: $e\n$st',
        logLevel: LogLevel.error,
        tag: 'WATCH',
      );
      failure.value = e.toString();
      phase.value = WatchPhase.failed;
    }
  }

  Future<void> _loadMeta() async {
    final generation = ++_metaGeneration;
    await _metaSub?.cancel();
    final choice = settings.value.metaSource;
    if (choice == 'off') {
      meta.value = const {};
      metaLoading.value = false;
      _derive();
      return;
    }
    metaLoading.value = true;
    try {
      final ids = await MediaIdResolver.resolve(service, current);
      if (generation != _metaGeneration) return;
      final stream = EpisodeMetaService.load(ids, only: choice);
      final done = Completer<void>();
      _metaSub = stream.listen(
        (merged) {
          if (generation != _metaGeneration) return;
          meta.value = merged;
          _derive();
        },
        onError: (Object e) => logger(
          'Watch metadata failed: $e',
          logLevel: LogLevel.error,
          tag: 'WATCH',
        ),
        onDone: done.complete,
      );
      await done.future;
    } catch (e) {
      logger(
        'Watch metadata failed: $e',
        logLevel: LogLevel.error,
        tag: 'WATCH',
      );
    } finally {
      if (generation == _metaGeneration) metaLoading.value = false;
    }
  }

  Future<void> setMetaSource(String? choice) async {
    final next = settings.value.copy()..metaSource = choice;
    settings.value = next;
    next.save(service, current);
    meta.value = const {};
    _derive();
    await _loadMeta();
  }

  Future<void> reloadMeta() async {
    EpisodeMetaService.clearCache();
    await _loadMeta();
  }

  void _derive() {
    if (episodes.isEmpty) return;
    final hidden = settings.value.hiddenScanlators.toSet();
    final visible = [
      for (final e in episodes)
        if (e.scanlator == null || !hidden.contains(e.scanlator)) e,
    ];
    final built = buildUnits(
      visible,
      meta.value,
      fallbackThumb: current.banner ?? current.cover ?? '',
      anime: anime,
    );
    units.value = watchShowFillerPref.rx.value
        ? built
        : [
            for (final u in built)
              if (!u.filler) u,
          ];
    if (!_chunkPinned) _pickChunk();
    if (chunk.value >= chunks.length) chunk.value = 0;
  }

  List<List<WatchUnit>> get chunks =>
      chunkUnits(units.toList(), watchChunkSizePref.rx.value);

  void _pickChunk() {
    final list = chunks;
    chunk.value = chunkOf(list, progress);
  }

  void selectChunk(int index) {
    _chunkPinned = true;
    chunk.value = index;
  }

  WatchUnit? get next {
    final target = progress + 1;
    for (final u in units) {
      if (u.value == target) return u;
    }
    for (final u in units) {
      if (u.value > progress) return u;
    }
    return null;
  }

  void updateSettings(MediaWatchSettings next) {
    final hiddenChanged = !listEquals(
      next.hiddenScanlators,
      settings.value.hiddenScanlators,
    );
    final matchChanged = next.match != settings.value.match;
    settings.value = next;
    next.save(service, current);
    if (hiddenChanged) _derive();
    if (matchChanged && !fixedSource) unawaited(resetMatch());
  }

  void resetSettings() {
    MediaWatchSettings.reset(service, current);
    final fresh = MediaWatchSettings(
      sourceId: settings.value.sourceId,
      sourceName: settings.value.sourceName,
    );
    updateSettings(fresh);
  }

  Future<void> markWatched(WatchUnit unit) async {
    final m = mutations;
    if (m == null) {
      snackString(getString.watchSignInToTrack);
      return;
    }
    final target = unit.value.floor();
    try {
      await m.setProgress(current, target);
      media.refresh();
    } catch (e) {
      snackString(e.toString());
    }
  }

  Future<void> markUnwatched(WatchUnit unit) async {
    final m = mutations;
    if (m == null) {
      snackString(getString.watchSignInToTrack);
      return;
    }
    final target = (unit.value.floor() - 1).clamp(0, 1 << 30);
    try {
      await m.setProgress(current, target);
      media.refresh();
    } catch (e) {
      snackString(e.toString());
    }
  }

  void playUnavailable() => snackString(
    anime ? getString.watchPlayerSoon : getString.watchReaderSoon,
  );

  Future<void> refresh() async {
    EpisodeMetaService.clearCache();
    await start();
  }
}
