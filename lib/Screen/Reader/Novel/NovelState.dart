import '../../../Core/Downloads/DownloadEngine.dart';
import 'dart:async';

import 'package:dartotsu_extension_bridge/dartotsu_extension_bridge.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../Detail/Watch/Data/Media/MediaRecord.dart';
import '../../../Core/Preferences/Incognito.dart';
import '../Engine/NovelSpeech.dart';
import '../Engine/NovelText.dart';
import '../Engine/NovelTranslate.dart';
import '../../../Utils/Functions/SnackBar.dart';
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
  final original = <NovelBlock>[].liveList;
  final translated = Live<List<NovelBlock>?>(null);
  final translating = false.live;
  final translateProgress = 0.0.live;
  final speaking = false.live;
  final speakingAt = (-1).live;
  final _translator = NovelTranslator();
  final _speech = NovelSpeech();
  int _speakRun = 0;
  final blockKeys = <int, GlobalKey>{};

  List<NovelBlock> get blocks => translated.value ?? original;
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
    _speakRun++;
    unawaited(_speech.dispose());
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
      stopSpeaking();
      blockKeys.clear();
      translated.value = null;
      original.value = parsed;
      final saved = record.playback[unit.number];
      _restore =
          jump ??
          (saved != null && !saved.finished && saved.position > 0
              ? saved.position / _scale
              : null);
      loading.value = false;
      _scheduleRestore();
      if (_resumeSpeakingAfterOpen) {
        _resumeSpeakingAfterOpen = false;
        Future<void>.delayed(
          const Duration(milliseconds: 400),
          () => unawaited(startSpeaking(from: 0)),
        );
      }
      if (settings.translateTo.isNotEmpty) unawaited(translate());
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
    if (original.isEmpty || !settings.saveProgress || isIncognito) return;
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
    final before = settings.translateTo;
    change(settings);
    if (before != settings.translateTo) {
      translated.value = null;
      if (settings.translateTo.isNotEmpty) unawaited(translate());
    }
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

  Future<void> translate() async {
    final to = settings.translateTo;
    if (to.isEmpty || original.isEmpty || translating.value) return;
    final run = _run;
    final source = original.toList();
    translating.value = true;
    translateProgress.value = 0;
    try {
      final result = await _translator.translate(
        source,
        to,
        cancelled: () => _closed || run != _run,
        onProgress: (p) => translateProgress.value = p,
      );
      if (_closed || run != _run) return;
      translated.value = result;
    } catch (e, st) {
      logger(
        'Novel translate failed: $e\n$st',
        logLevel: LogLevel.error,
        tag: 'READER',
      );
      if (!_closed) snackString(getString.novelTranslateFailed(e.toString()));
    } finally {
      translating.value = false;
    }
  }

  void showOriginal() {
    translated.value = null;
    stopSpeaking();
  }

  void toggleTranslation() {
    if (translated.value != null) {
      showOriginal();
    } else {
      if (settings.translateTo.isEmpty) {
        snackString(getString.novelTranslateOff);
        return;
      }
      unawaited(translate());
    }
  }

  bool get canSpeak => NovelSpeech.supported;

  void toggleSpeaking() {
    if (speaking.value) {
      stopSpeaking();
    } else {
      unawaited(startSpeaking());
    }
  }

  void stopSpeaking() {
    _speakRun++;
    speaking.value = false;
    speakingAt.value = -1;
    unawaited(_speech.stop());
  }

  Future<void> startSpeaking({int? from}) async {
    if (!canSpeak || blocks.isEmpty) {
      snackString(getString.novelSpeechUnavailable);
      return;
    }
    final run = ++_speakRun;
    await _speech.stop();
    if (run != _speakRun) return;
    speaking.value = true;
    controlsVisible.value = false;
    var i = from ?? _firstVisible();
    final language = translated.value != null ? settings.translateTo : null;
    while (run == _speakRun && !_closed) {
      final list = blocks;
      while (i < list.length && !_speakable(list[i])) {
        i++;
      }
      if (i >= list.length) {
        if (settings.autoNext && hasNext) {
          speaking.value = false;
          speakingAt.value = -1;
          _resumeSpeakingAfterOpen = true;
          next();
        } else {
          stopSpeaking();
        }
        return;
      }
      speakingAt.value = i;
      _follow(i);
      final ok = await _speech.speak(
        (list[i] as NovelParagraph).text,
        rate: settings.speechRate,
        pitch: settings.speechPitch,
        language: language,
        voice: settings.speechVoice,
      );
      if (run != _speakRun) return;
      if (!ok) {
        stopSpeaking();
        snackString(getString.novelSpeechUnavailable);
        return;
      }
      i++;
    }
  }

  bool _resumeSpeakingAfterOpen = false;

  void speakStep(int direction) {
    final list = blocks;
    var i = speakingAt.value + direction;
    while (i >= 0 && i < list.length && !_speakable(list[i])) {
      i += direction;
    }
    if (i < 0 || i >= list.length) return;
    unawaited(startSpeaking(from: i));
  }

  int? blockAt(Offset global) {
    for (final e in blockKeys.entries) {
      final box = e.value.currentContext?.findRenderObject();
      if (box is! RenderBox || !box.attached) continue;
      final rect = box.localToGlobal(Offset.zero) & box.size;
      if (rect.contains(global)) return e.key;
    }
    return null;
  }

  bool _speakable(NovelBlock b) =>
      b is NovelParagraph && b.text.trim().isNotEmpty;

  int _firstVisible() {
    final list = blocks;
    if (list.isEmpty) return 0;
    return (fraction.value * list.length).floor().clamp(0, list.length - 1);
  }

  void _follow(int i) {
    final context = blockKeys[i]?.currentContext;
    if (context != null) {
      unawaited(
        Scrollable.ensureVisible(
          context,
          alignment: 0.3,
          duration: animDuration(250),
          curve: Curves.easeOutCubic,
        ),
      );
      return;
    }
    if (!scroll.hasClients) return;
    final max = scroll.position.maxScrollExtent;
    scroll.jumpTo(max * (i / blocks.length).clamp(0.0, 1.0));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final c = blockKeys[i]?.currentContext;
      if (c != null && !_closed) {
        unawaited(
          Scrollable.ensureVisible(
            c,
            alignment: 0.3,
            duration: animDuration(200),
          ),
        );
      }
    });
  }

  void toggleControls() => controlsVisible.value = !controlsVisible.value;
}
