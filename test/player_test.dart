import 'dart:convert';

import 'package:dartotsu_extension_bridge/Models/Video.dart' as v;
import 'package:flutter_test/flutter_test.dart';

import 'package:dartotsu/Core/Media/MediaRecord.dart';
import 'package:dartotsu/Core/Player/AniSkip.dart';
import 'package:dartotsu/Core/Player/MpvFiles.dart';
import 'package:dartotsu/Core/Player/PlayRequest.dart';
import 'package:dartotsu/Core/Player/PlayerPlaylist.dart';
import 'package:dartotsu/Core/Player/PlayerSettings.dart';
import 'package:dartotsu/Core/Player/TorrentStream.dart';
import 'package:dartotsu/Core/Watch/WatchPrefs.dart';

void main() {
  group('MediaRecord', () {
    test('round trips every part through one json document', () {
      final record = MediaRecord(
        watch: MediaWatchSettings(
          viewType: 2,
          reverse: true,
          sourceId: 's1',
          hiddenScanlators: ['x'],
        ),
        matches: {
          's1': const SourceMatchRecord(title: 'One Piece', url: '/op'),
        },
        playback: {'12': Playback(position: 600, duration: 1400)},
        streams: StreamPrefs(auto: true, last: {'s1': '1080p'}),
        ids: {'anilist': 21},
        player: {'speed': 1.5},
        commentsId: 21,
        saveProgress: false,
      );
      final copy = MediaRecord.fromJson(
        jsonDecode(jsonEncode(record.toJson())),
      );
      expect(copy.watch.viewType, 2);
      expect(copy.watch.reverse, isTrue);
      expect(copy.watch.hiddenScanlators, ['x']);
      expect(copy.matches['s1']!.url, '/op');
      expect(copy.playback['12']!.position, 600);
      expect(copy.playback['12']!.finished, isFalse);
      expect(copy.streams.auto, isTrue);
      expect(copy.streams.last['s1'], '1080p');
      expect(copy.ids['anilist'], 21);
      expect(copy.player['speed'], 1.5);
      expect(copy.commentsId, 21);
      expect(copy.saveProgress, isFalse);
    });

    test('an empty or damaged document gives defaults', () {
      final copy = MediaRecord.fromJson({
        'matches': 5,
        'playback': {'1': 'x'},
      });
      expect(copy.matches, isEmpty);
      expect(copy.playback, isEmpty);
      expect(copy.streams.auto, isFalse);
      expect(copy.saveProgress, isTrue);
    });

    test('playback is finished from ninety percent', () {
      expect(Playback(position: 1300, duration: 1400).finished, isTrue);
      expect(Playback(position: 100, duration: 0).finished, isFalse);
    });
  });

  group('PlayerSettings', () {
    test('defaults and typed access', () {
      final s = PlayerSettings();
      expect(s.speed, 1.0);
      expect(s.autoPlay, isTrue);
      expect(s.skipDuration, 85);
      expect(s.shaders, isFalse);
    });

    test('numbers from json keep their type', () {
      final s = PlayerSettings({'speed': 2, 'skipDuration': 90.0});
      expect(s.speed, 2.0);
      expect(s.skipDuration, 90);
    });

    test('diff keeps only what changed and merged applies it', () {
      final base = PlayerSettings();
      final mine = base.copy()
        ..speed = 1.5
        ..autoPlay = false;
      final diff = mine.diff(base);
      expect(diff, {'speed': 1.5, 'autoPlay': false});
      final merged = base.merged(diff);
      expect(merged.speed, 1.5);
      expect(merged.autoPlay, isFalse);
      expect(merged.skipDuration, 85);
    });
  });

  group('mpv.conf', () {
    test('parses options, flags and quotes', () {
      final lines = parseMpvConf('''
# comment
hwdec=auto-safe
--scale=ewa_lanczos
deband
no-correct-downscaling
sub-font = "Open Sans"
glsl-shaders=~~/a.glsl # trailing
[profile.high]
vo=gpu-next
''');
      final map = {for (final l in lines) l.key: l.value};
      expect(map['hwdec'], 'auto-safe');
      expect(map['scale'], 'ewa_lanczos');
      expect(map['deband'], 'yes');
      expect(map['correct-downscaling'], 'no');
      expect(map['sub-font'], 'Open Sans');
      expect(map['glsl-shaders'], '~~/a.glsl');
      expect(map.containsKey('vo'), isFalse);
    });

    test('shader lists use the platform separator', () {
      expect(joinShaders(['a', 'b'], windows: true), 'a;b');
      expect(joinShaders(['a', 'b'], windows: false), 'a:b');
    });

    test('profile and custom shader lookup', () {
      expect(shaderFilesOf('MID-END', 'Anime4K: Mode C (Fast)', const []), [
        'Anime4K_Clamp_Highlights.glsl',
        'Anime4K_Upscale_Denoise_CNN_x2_M.glsl',
      ]);
      expect(shaderFilesOf(customShaderProfile, 'x', ['mine.glsl']), [
        'mine.glsl',
      ]);
      expect(shaderFilesOf('MID-END', 'nope', const []), isEmpty);
    });
  });

  group('streams', () {
    final videos = [
      v.Video('Server A - 1080p', 'u1', '1080p'),
      v.Video('Server A - 720p', 'u2', '720p'),
      v.Video(null, 'u3', 'HLS'),
    ];

    test('exact label wins, close label is matched, junk is not', () {
      expect(bestStreamIndex(videos, 'Server A - 720p'), 1);
      expect(bestStreamIndex(videos, 'server a 1080p'), 0);
      expect(bestStreamIndex(videos, 'zzzz qqqq'), isNull);
      expect(bestStreamIndex(videos, 'server a 1080p', exact: true), isNull);
      expect(streamLabel(videos[2]), 'HLS');
    });

    test('subtitles found on one stream are shared with the rest', () {
      final a = v.Video(
        'a',
        'u',
        'q',
        subtitles: [v.Track(file: 'f', label: 'English')],
      );
      final b = v.Video('b', 'u', 'q');
      shareSubtitles([a, b]);
      expect(b.subtitles!.single.label, 'English');
    });
  });

  group('AniSkip', () {
    test('parses openings and endings in order', () {
      final stamps = parseAniSkip({
        'found': true,
        'results': [
          {
            'interval': {'startTime': 1349.9, 'endTime': 1474},
            'skipType': 'ed',
          },
          {
            'interval': {'startTime': 58.6, 'endTime': 148.6},
            'skipType': 'op',
          },
          {
            'interval': {'startTime': 5, 'endTime': 5},
            'skipType': 'recap',
          },
        ],
      });
      expect(stamps.map((e) => e.kind), [SkipKind.opening, SkipKind.ending]);
      expect(stamps.first.name, 'Opening');
      expect(stamps.first.covers(100), isTrue);
      expect(stamps.first.covers(148.6), isFalse);
    });

    test('a miss gives nothing', () {
      expect(parseAniSkip({'found': false}), isEmpty);
      expect(parseAniSkip(null), isEmpty);
    });
  });

  group('playlists', () {
    test('natural order puts episode 2 before 10', () {
      final names = ['Show 10.mkv', 'Show 2.mkv', 'Show 1.mkv']
        ..sort(naturalCompare);
      expect(names, ['Show 1.mkv', 'Show 2.mkv', 'Show 10.mkv']);
    });

    test('video and torrent detection', () {
      expect(isVideoPath('/a/b.MKV'), isTrue);
      expect(isVideoPath('/a/b.txt'), isFalse);
      expect(isTorrentSource('magnet:?xt=urn:btih:abc'), isTrue);
      expect(isTorrentSource('https://x/y.torrent?a=1'), isTrue);
      expect(isTorrentSource('https://x/y.mp4'), isFalse);
    });

    test('referer headers carry the origin', () {
      expect(refererHeaders('https://a.com/path'), {
        'Referer': 'https://a.com/path',
        'Origin': 'https://a.com',
      });
      expect(refererHeaders(' '), isEmpty);
    });
  });
}
