import 'dart:async';

import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

import '../../Logger.dart';
import '../Preferences/StorageManager.dart';

class SeekPreview {
  Player? _player;
  VideoController? _controller;
  String? _opened;
  Timer? _timer;
  Duration? _pending;
  bool _disposed = false;

  VideoController? get controller => _controller;

  Future<void> open(String target, Map<String, String> headers) async {
    if (_disposed) return;
    if (_opened == target && _player != null) return;
    _opened = target;
    try {
      var player = _player;
      if (player == null) {
        player = Player(
          configuration: const PlayerConfiguration(
            logLevel: MPVLogLevel.error,
            bufferSize: 16 * 1024 * 1024,
            libass: false,
          ),
        );
        _player = player;
        _controller = VideoController(
          player,
          configuration: const VideoControllerConfiguration(hwdec: 'no'),
        );
        await _configure(player);
      }
      final agent = headers.entries
          .where((e) => e.key.toLowerCase() == 'user-agent')
          .firstOrNull
          ?.value;
      final native = player.platform as NativePlayer;
      if (agent != null) await native.setProperty('user-agent', agent);
      await player.open(
        Media(
          target,
          httpHeaders: {
            for (final e in headers.entries)
              if (e.key.toLowerCase() != 'user-agent') e.key: e.value,
          },
        ),
        play: false,
      );
      logger('Seek preview ready', logLevel: LogLevel.debug, tag: 'PLAYER');
    } catch (e, st) {
      logError('SeekPreview', e, st, 'open failed');
      _opened = null;
    }
  }

  Future<void> _configure(Player player) async {
    final native = player.platform;
    if (native is! NativePlayer) return;
    final cache = await StorageManager.getDirectory(
      subPath: 'cache/mpv-preview',
    );
    final props = <String, String>{
      if (cache != null) 'demuxer-cache-dir': cache.path,
      'aid': 'no',
      'sid': 'no',
      'ao': 'null',
      'volume': '0',
      'hr-seek': 'no',
      'hwdec': 'no',
      'vd-lavc-skiploopfilter': 'all',
      'vd-lavc-fast': 'yes',
      'vd-lavc-threads': '2',
      'demuxer-readahead-secs': '0',
      'keep-open': 'yes',
      'ytdl': 'no',
      'network-timeout': '15',
    };
    for (final e in props.entries) {
      try {
        await native.setProperty(e.key, e.value);
      } catch (err, st) {
        logError('SeekPreview', err, st, 'mpv ${e.key} failed');
      }
    }
  }

  void seek(Duration position) {
    _pending = position;
    if (_timer?.isActive ?? false) return;
    _timer = Timer(const Duration(milliseconds: 90), () async {
      final to = _pending;
      final player = _player;
      if (to == null || player == null || _disposed) return;
      try {
        await player.seek(to);
      } catch (e, st) {
        logError('SeekPreview', e, st, 'seek failed');
      }
    });
  }

  Future<void> dispose() async {
    _disposed = true;
    _timer?.cancel();
    final player = _player;
    _player = null;
    _controller = null;
    _opened = null;
    try {
      await player?.dispose();
    } catch (e, st) {
      logError('SeekPreview', e, st, 'dispose failed');
    }
  }
}
