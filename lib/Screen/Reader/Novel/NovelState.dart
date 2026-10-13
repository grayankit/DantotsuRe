import '../../../Core/Downloads/DownloadEngine.dart';
import 'dart:async';

import 'package:dartotsu_extension_bridge/dartotsu_extension_bridge.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../Detail/Watch/Data/Media/MediaRecord.dart';
import '../../../Core/Preferences/Incognito.dart';
import '../Engine/NovelText.dart';
import '../Engine/ReaderRequest.dart';
import '../Engine/ReaderSettings.dart';
import '../Engine/VolumeKeys.dart';
import '../../Detail/Watch/Data/TrackConfirm.dart';
import '../../../Core/State/State.dart';
import '../../../Core/ThemeManager/LanguageSwitcher.dart';
import '../../Detail/Watch/Data/EpisodeUnits.dart';
import '../../../Logger.dart';
import '../../../Widgets/Components/ScreenState.dart';
import '../../Detail/Watch/Components/UnitTile.dart';
import '../../../Utils/Animation/WidgetAnimations.dart';
import '../../../Utils/Functions/Wakelock.dart';

const _scale = 10000;

class NovelState extends ScreenState {
  final ReaderRequest request;

  NovelState(this.request);

  late ReaderSettings settings;

  final index = 0.live;
  final blocks = <NovelBlock>[].liveList;
  final loading = true.live;
  final error = Live<String?>(null);
  final controlsVisible = false.live;
  final settingsVersion = 0.live;
  final fraction = 0.0.live;
  final perTitle = false.live;
  final scroll = ScrollController();

  final autoScrolling = false.live;
  Timer? _saveTimer;
  Timer? _autoTimer;
  int _run = 0;
  bool _marked = false;
  bool _closed = false;
  bool _restoring = false;
  double? _restore;

  MediaRecord get record => MediaRecords.of(request.service, request.media);

  List<WatchUnit> get units => request.units;

  WatchUnit get unit => units[index.value];

  String get title => unitTitle(unit, false);

  bool get hasNext => nextUnitIndex(units, index.value) < units.length;

  bool get hasPrevious => index.value > 0;

  @override
  void onInit() {
    final overrides = record.reader;
    final base = ReaderPrefs.global.value;
    settings = overrides.isEmpty ? base.copy() : base.merged(overrides);
    perTitle.value = overrides.isNotEmpty;
    index.value = request.index;
    scroll.addListener(_onScroll);
    _applySystem();
    unawaited(_open(request.index));
  }

  @override
  void onClose() {
    _closed = true;
    find<DownloadEngine>().sweepFinished();
    _saveTimer?.cancel();
    _autoTimer?.cancel();
    unawaited(VolumeKeys.disable());
    _save();
    scroll.dispose();
    unawaited(setWakelock(false));
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  void _applySystem() {
    if (settings.volumeKeys) {
      unawaited(VolumeKeys.enable((d) => pageBy(d.toDouble())));
    } else {
      unawaited(VolumeKeys.disable());
    }
    if (settings.keepOn) {
      unawaited(setWakelock(true));
    } else {
      unawaited(setWakelock(false));
    }
    SystemChrome.setEnabledSystemUIMode(
      settings.fullscreen
          ? SystemUiMode.immersiveSticky
          : SystemUiMode.edgeToEdge,
    );
  }

  Future<void> _open(int target, {double? jump}) async {
    final run = ++_run;
    _save();
    loading.value = true;
    error.value = null;
    index.value = target;
    _marked = false;
    fraction.value = 0;
    try {
      final local = request.online
          ? null
          : await find<DownloadEngine>().localNovel(
              request.service.id,
              request.media.id,
              units[target].key,
            );
      final source = request.source;
      if (local == null && source == null) {
        throw StateError(getString.downloadSourceMissing);
      }
      final text =
          local ?? await source!.methods.getNovelContent(units[target].raw);
      if (run != _run || _closed) return;
      final parsed = parseNovel(text ?? '');
      if (parsed.isEmpty) throw StateError(getString.readerNoText);
      blocks.value = parsed;
      final saved = record.playback[unit.number];
      _restore =
          jump ??
          (saved != null && !saved.finished && saved.position > 0
              ? saved.position / _scale
              : null);
      loading.value = false;
      _scheduleRestore();
    } catch (e, st) {
      if (run != _run || _closed) return;
      logger(
        'Novel load failed: $e\n$st',
        logLevel: LogLevel.error,
        tag: 'READER',
      );
      error.value = e.toString();
      loading.value = false;
    }
  }

  void _scheduleRestore() {
    final target = _restore;
    if (scroll.hasClients) scroll.jumpTo(0);
    if (target == null) return;
    _restoring = true;
    var tries = 0;
    void attempt() {
      if (_closed) return;
      if (scroll.hasClients && scroll.position.maxScrollExtent > 0) {
        scroll.jumpTo(scroll.position.maxScrollExtent * target);
        _restoring = false;
        return;
      }
      if (++tries > 20) {
        _restoring = false;
        return;
      }
      Future<void>.delayed(const Duration(milliseconds: 80), attempt);
    }

    attempt();
  }

  final bookmarkTick = 0.live;

  bool get bookmarked {
    bookmarkTick.value;
    final key = unit.number;
    final at = (fraction.value * _scale).round();
    return record.bookmarks.any(
      (b) => b.unit == key && (b.position - at).abs() <= _scale ~/ 100,
    );
  }

  void toggleBookmark() {
    final key = unit.number;
    final at = (fraction.value * _scale).round();
    final near = record.bookmarks
        .where((b) => b.unit == key && (b.position - at).abs() <= _scale ~/ 100)
        .toList();
    if (near.isNotEmpty) {
      record.bookmarks.removeWhere(near.contains);
    } else {
      record.bookmarks.add(
        Bookmark(
          unit: key,
          position: at,
          total: _scale,
          label: title,
          at: DateTime.now().millisecondsSinceEpoch,
        ),
      );
    }
    MediaRecords.save(request.service, request.media);
    bookmarkTick.value++;
  }

  void removeBookmark(Bookmark b) {
    record.bookmarks.remove(b);
    MediaRecords.save(request.service, request.media);
    bookmarkTick.value++;
  }

  void openBookmark(Bookmark b) {
    final index = units.indexWhere((u) => u.number == b.unit);
    if (index < 0) return;
    final target = b.position / _scale;
    if (index == this.index.value && !loading.value) {
      seekTo(target);
    } else {
      unawaited(_open(index, jump: target));
    }
  }

  void retry() => unawaited(_open(index.value));

  void openChapter(int target) {
    if (target < 0 || target >= units.length) return;
    unawaited(_open(target));
  }

  void next() => openChapter(nextUnitIndex(units, index.value));

  void previous() => openChapter(index.value - 1);

  void _onScroll() {
    if (!scroll.hasClients || _restoring) return;
    final max = scroll.position.maxScrollExtent;
    fraction.value = max <= 0 ? 1.0 : (scroll.offset / max).clamp(0.0, 1.0);
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(seconds: 1), _save);
    if (!_marked && fraction.value >= 0.9) {
      _marked = true;
      find<DownloadEngine>().markFinished(
        request.service.id,
        request.media.id,
        unit.key,
      );
      unawaited(_track());
    }
  }

  void seekTo(double value) {
    if (!scroll.hasClients) return;
    scroll.jumpTo(scroll.position.maxScrollExtent * value);
  }

  void pageBy(double direction) {
    if (!scroll.hasClients) return;
    final target =
        (scroll.offset + scroll.position.viewportDimension * 0.9 * direction)
            .clamp(0.0, scroll.position.maxScrollExtent);
    unawaited(
      scroll.animateTo(
        target,
        duration: animDuration(220),
        curve: Curves.easeOutCubic,
      ),
    );
  }

  final _unsaved = <String>{};

  void _discard(WatchUnit unit) {
    _unsaved.add(unit.number);
    record.playback.remove(unit.number);
    MediaRecords.save(request.service, request.media);
  }

  void _save() {
    if (_unsaved.contains(unit.number)) return;
    if (blocks.isEmpty || !settings.saveProgress || isIncognito) return;
    record.playback[unit.number] = Playback(
      position: (fraction.value * _scale).round(),
      duration: _scale,
    );
    MediaRecords.save(request.service, request.media);
  }

  Future<void> _track() async {
    final media = request.media;
    final mutations = request.service.getMutations;
    if (!record.saveProgress || isIncognito || mutations == null) return;
    final target = unit.value.floor();
    if (target <= 0 || target <= (media.userProgress ?? 0)) return;
    final choice = await confirmTracking(
      context,
      anime: false,
      name: media.mainName,
    );
    if (choice == TrackChoice.none) {
      _discard(unit);
      return;
    }
    if (choice == TrackChoice.local) return;
    try {
      await mutations.setProgress(media, target);
      media.userProgress = target;
    } catch (e) {
      logger(
        'Novel progress failed: $e',
        logLevel: LogLevel.error,
        tag: 'READER',
      );
    }
  }

  void updateSettings(void Function(ReaderSettings s) change) {
    change(settings);
    if (perTitle.value) {
      record.reader = settings.diff(ReaderPrefs.global.value);
      MediaRecords.save(request.service, request.media);
    } else {
      ReaderPrefs.update(change);
    }
    _applySystem();
    settingsVersion.value++;
    if (autoScrolling.value) setAutoScroll(true, hide: false);
  }

  int get wordsLeft {
    var words = 0;
    for (final b in blocks) {
      if (b is NovelParagraph) words += b.text.split(RegExp(r'\s+')).length;
    }
    return (words * (1 - fraction.value)).round();
  }

  void toggleAutoScroll() => setAutoScroll(!autoScrolling.value);

  void setAutoScroll(bool on, {bool hide = true}) {
    _autoTimer?.cancel();
    autoScrolling.value = on;
    if (!on) return;
    if (hide) controlsVisible.value = false;
    final speed = settings.autoScrollSpeed.clamp(1, 10);
    const frame = Duration(milliseconds: 16);
    final pixels = (10 + speed * 12) * frame.inMilliseconds / 1000;
    _autoTimer = Timer.periodic(frame, (_) {
      if (!scroll.hasClients || loading.value) return;
      final max = scroll.position.maxScrollExtent;
      if (scroll.offset >= max) {
        if (settings.autoNext && hasNext) {
          next();
        } else {
          setAutoScroll(false);
        }
        return;
      }
      scroll.jumpTo((scroll.offset + pixels).clamp(0.0, max));
    });
  }

  void setPerTitle(bool value) {
    perTitle.value = value;
    if (value) {
      record.reader = settings.diff(ReaderPrefs.global.value);
      if (record.reader.isEmpty) {
        record.reader = {'novelSize': settings.novelSize};
      }
    } else {
      record.reader = {};
      settings = ReaderPrefs.global.value.copy();
    }
    MediaRecords.save(request.service, request.media);
    _applySystem();
    settingsVersion.value++;
  }

  void toggleControls() => controlsVisible.value = !controlsVisible.value;
}
