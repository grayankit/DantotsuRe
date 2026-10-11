import 'dart:async';

import 'package:dartotsu_extension_bridge/dartotsu_extension_bridge.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../../Core/Media/MediaRecord.dart';
import '../../../Core/Preferences/Incognito.dart';
import '../../../Core/Reader/NovelText.dart';
import '../../../Core/Reader/ReaderRequest.dart';
import '../../../Core/Reader/ReaderSettings.dart';
import '../../../Core/State/State.dart';
import '../../../Core/ThemeManager/LanguageSwitcher.dart';
import '../../../Core/Watch/EpisodeUnits.dart';
import '../../../Logger.dart';
import '../../../Widgets/Components/ScreenState.dart';
import '../../Detail/Watch/Components/UnitTile.dart';

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

  Timer? _saveTimer;
  int _run = 0;
  bool _marked = false;
  bool _closed = false;
  bool _restoring = false;
  double? _restore;

  MediaRecord get record => MediaRecords.of(request.service, request.media);

  List<WatchUnit> get units => request.units;

  WatchUnit get unit => units[index.value];

  String get title => unitTitle(unit, false);

  bool get hasNext => index.value + 1 < units.length;

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
    _saveTimer?.cancel();
    _save();
    scroll.dispose();
    WakelockPlus.disable();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  void _applySystem() {
    if (settings.keepOn) {
      WakelockPlus.enable();
    } else {
      WakelockPlus.disable();
    }
    SystemChrome.setEnabledSystemUIMode(
      settings.fullscreen
          ? SystemUiMode.immersiveSticky
          : SystemUiMode.edgeToEdge,
    );
  }

  Future<void> _open(int target) async {
    final run = ++_run;
    _save();
    loading.value = true;
    error.value = null;
    index.value = target;
    _marked = false;
    fraction.value = 0;
    try {
      final text = await request.source.methods.getNovelContent(
        units[target].raw,
      );
      if (run != _run || _closed) return;
      final parsed = parseNovel(text ?? '');
      if (parsed.isEmpty) throw StateError(getString.readerNoText);
      blocks.value = parsed;
      final saved = record.playback[unit.number];
      _restore = saved != null && !saved.finished && saved.position > 0
          ? saved.position / _scale
          : null;
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

  void retry() => unawaited(_open(index.value));

  void openChapter(int target) {
    if (target < 0 || target >= units.length) return;
    unawaited(_open(target));
  }

  void next() => openChapter(index.value + 1);

  void previous() => openChapter(index.value - 1);

  void _onScroll() {
    if (!scroll.hasClients || _restoring) return;
    final max = scroll.position.maxScrollExtent;
    fraction.value = max <= 0 ? 1.0 : (scroll.offset / max).clamp(0.0, 1.0);
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(seconds: 1), _save);
    if (!_marked && fraction.value >= 0.9) {
      _marked = true;
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
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
      ),
    );
  }

  void _save() {
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
