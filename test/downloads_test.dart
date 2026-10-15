import 'dart:io';

import 'package:dartotsu/Core/Downloads/ChapterFetcher.dart';
import 'package:dartotsu/Core/Downloads/DownloadCancel.dart';
import 'package:dartotsu/Core/Downloads/DownloadPaths.dart';
import 'package:dartotsu/Core/Downloads/DownloadQueue.dart';
import 'package:dartotsu/Core/Downloads/DownloadTask.dart';
import 'package:dartotsu/Core/Downloads/Hls.dart';
import 'package:dartotsu/Core/Downloads/HlsFetcher.dart';
import 'package:dartotsu/Core/Downloads/NameMatch.dart';
import 'package:dartotsu_extension_bridge/dartotsu_extension_bridge.dart';
import 'package:flutter_test/flutter_test.dart';

DownloadTask task({double number = 1, DownloadState? state}) {
  final t = DownloadTask(
    id: DownloadTask.idOf('anilist', '7', '$number'),
    kind: DownloadKind.video,
    serviceId: 'anilist',
    mediaId: '7',
    mediaTitle: 'Show',
    cover: null,
    sourceId: 'src',
    unitKey: '$number',
    number: number,
    title: 'Pilot',
    media: {'id': '7'},
    episode: {'episodeNumber': '$number'},
    profile: const StreamProfile('1080p', 'English'),
    createdAt: 1,
    video: {'url': 'https://x/y.mkv', 'quality': '1080p'},
  );
  if (state != null) t.state.value = state;
  return t;
}

void main() {
  group('names', () {
    test('safeName strips illegal characters', () {
      expect(safeName('Re:Zero / Season 2?'), 'Re Zero Season 2');
      expect(safeName('...'), 'Untitled');
      expect(safeName('  a   b  '), 'a b');
    });

    test('unit names are zero padded', () {
      expect(unitBaseName(task(number: 1)), 'Episode 001');
      expect(unitBaseName(task(number: 12.5)), 'Episode 012.5');
    });

    test('extensionOf reads the url path', () {
      expect(extensionOf('https://x/a/b.MKV?token=1'), 'mkv');
      expect(extensionOf('https://x/a/b'), 'mp4');
      expect(extensionOf('https://x/a/b.vtt', fallback: 'srt'), 'vtt');
    });
  });

  group('DownloadTask', () {
    test('round trips through json', () {
      final original = task(state: DownloadState.done)
        ..path = '/tmp/a.mkv'
        ..received.value = 10
        ..total.value = 10;
      final copy = DownloadTask.fromJson(original.toJson())!;
      expect(copy.id, original.id);
      expect(copy.state.value, DownloadState.done);
      expect(copy.profile?.label, '1080p');
      expect(copy.profile?.subtitle, 'English');
      expect(copy.path, '/tmp/a.mkv');
      expect(copy.fraction, 1);
    });

    test('an interrupted download comes back paused', () {
      for (final state in [
        DownloadState.queued,
        DownloadState.resolving,
        DownloadState.downloading,
      ]) {
        final copy = DownloadTask.fromJson(task(state: state).toJson())!;
        expect(copy.state.value, DownloadState.paused);
      }
    });

    test('a broken entry is dropped', () {
      expect(DownloadTask.fromJson({'id': 1}), isNull);
      expect(DownloadTask.fromJson('nope'), isNull);
    });
  });

  group('episodeNumberOf', () {
    const cases = {
      '1.mkv': 1.0,
      '01.mp4': 1.0,
      'E01.mkv': 1.0,
      'Ep 12.mkv': 12.0,
      'Episode 7.mp4': 7.0,
      '01 - Title.mkv': 1.0,
      '[Group] Show - 05 [1080p].mkv': 5.0,
      '[Group] Show - 12v2 [1080p][ABCD1234].mkv': 12.0,
      'Show S01E05.mkv': 5.0,
      'Show.Name.2019.S02E11.1080p.WEB-DL.x265.mkv': 11.0,
      'Show - 13.5.mkv': 13.5,
      'Some Show 24.avi': 24.0,
      'Chapter 12.cbz': 12.0,
      'Ch.5.cbz': 5.0,
      'c012.cbz': 12.0,
      'Vol 3.epub': 3.0,
      'Volume 03.epub': 3.0,
      'Berserk - Chapter 364.5.cbz': 364.5,
    };
    cases.forEach((name, expected) {
      test(name, () => expect(episodeNumberOf(name), expected));
    });

    test('no number', () => expect(episodeNumberOf('movie.mkv'), isNull));

    test('keys match the watch tab', () {
      expect(unitKeyOf(5), '5');
      expect(unitKeyOf(13.5), '13.5');
    });
  });

  group('sniffImageExtension', () {
    List<int> bytes(String text, {int at = 0}) => [
      ...List.filled(at, 0),
      ...text.codeUnits,
      ...List.filled(16, 0),
    ];

    test('common formats', () {
      expect(sniffImageExtension([0xFF, 0xD8, 0xFF, 0xE0, 0, 0]), 'jpg');
      expect(sniffImageExtension([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A]), 'png');
      expect(sniffImageExtension(bytes('GIF89a')), 'gif');
      expect(
        sniffImageExtension(
          bytes('RIFF')..replaceRange(8, 12, 'WEBP'.codeUnits),
        ),
        'webp',
      );
      expect(sniffImageExtension(bytes('ftypavif', at: 4)), 'avif');
      expect(sniffImageExtension(bytes('ftypheic', at: 4)), 'heic');
    });

    test('html is not an image', () {
      expect(sniffImageExtension(bytes('<!DOCTYPE html>')), isNull);
      expect(sniffImageExtension(const []), isNull);
    });
  });

  group('hls', () {
    final base = Uri.parse('https://cdn.example/video/master.m3u8');
    const master = '''#EXTM3U
#EXT-X-STREAM-INF:BANDWIDTH=800000,RESOLUTION=640x360
360/index.m3u8
#EXT-X-STREAM-INF:BANDWIDTH=2800000,RESOLUTION=1280x720,CODECS="avc1.64001f,mp4a.40.2"
720/index.m3u8
#EXT-X-STREAM-INF:BANDWIDTH=5000000,RESOLUTION=1920x1080
https://other.example/1080.m3u8
''';

    test('master playlist variants', () {
      expect(isMasterPlaylist(master), isTrue);
      final variants = parseMaster(master, base);
      expect(variants.length, 3);
      expect(
        variants[1].uri.toString(),
        'https://cdn.example/video/720/index.m3u8',
      );
      expect(variants[2].uri.host, 'other.example');
      expect(variants[1].height, 720);
      expect(variants[1].label, '720p • 2800 kbps');
    });

    test('audio renditions', () {
      const withAudio = '''#EXTM3U
#EXT-X-MEDIA:TYPE=AUDIO,GROUP-ID="aud",NAME="Japanese",LANGUAGE="ja",DEFAULT=YES,URI="ja/index.m3u8"
#EXT-X-MEDIA:TYPE=AUDIO,GROUP-ID="aud",NAME="English",LANGUAGE="en",URI="en/index.m3u8"
#EXT-X-MEDIA:TYPE=AUDIO,GROUP-ID="other",NAME="Spanish",URI="es/index.m3u8"
#EXT-X-MEDIA:TYPE=SUBTITLES,GROUP-ID="s",NAME="Eng",URI="s.m3u8"
#EXT-X-STREAM-INF:BANDWIDTH=800000,RESOLUTION=640x360,AUDIO="aud"
360/index.m3u8
''';
      final variant = parseMaster(withAudio, base).single;
      final audios = parseAudios(withAudio, base);
      expect(audios.length, 3);
      expect(variant.audioGroup, 'aud');
      expect(audiosFor(audios, variant).map((a) => a.label), [
        'Japanese',
        'English',
      ]);
      expect(pickAudio(audios, variant, null)!.label, 'Japanese');
      expect(pickAudio(audios, variant, 'english')!.label, 'English');
      expect(pickAudio(audios, variant, 'Spanish')!.label, 'Japanese');
      expect(
        pickAudio(audios, variant, 'English')!.uri.toString(),
        'https://cdn.example/video/en/index.m3u8',
      );
    });

    test('variant choice', () {
      final variants = parseMaster(master, base);
      expect(pickVariant(variants).height, 1080);
      expect(pickVariant(variants, height: 700).height, 720);
      expect(pickVariant(variants, height: 240).height, 360);
    });

    const media = '''#EXTM3U
#EXT-X-VERSION:3
#EXT-X-TARGETDURATION:6
#EXT-X-MEDIA-SEQUENCE:7
#EXT-X-KEY:METHOD=AES-128,URI="key.bin",IV=0x00000000000000000000000000000001
#EXTINF:6.0,
a.ts
#EXTINF:5.5,
b.ts
#EXT-X-KEY:METHOD=NONE
#EXTINF:4.0,
c.ts
#EXT-X-ENDLIST
''';

    test('media playlist', () {
      final parsed = parseMedia(
        media,
        Uri.parse('https://cdn.example/x/index.m3u8'),
      );
      expect(parsed.sequence, 7);
      expect(parsed.segments.length, 3);
      expect(parsed.duration, 15.5);
      expect(
        parsed.segments[0].key?.uri.toString(),
        'https://cdn.example/x/key.bin',
      );
      expect(parsed.segments[2].key, isNull);
    });

    test('local playlist keeps keys and numbering', () {
      final parsed = parseMedia(
        media,
        Uri.parse('https://cdn.example/x/index.m3u8'),
      );
      final text = buildLocalPlaylist(
        parsed,
        keyName: (_) => 'key0.bin',
        mapName: (_) => 'init0.mp4',
      );
      expect(text, contains('#EXT-X-MEDIA-SEQUENCE:7'));
      expect(
        text,
        contains('URI="key0.bin",IV=0x00000000000000000000000000000001'),
      );
      expect(text, contains('seg00000.ts'));
      expect(text, contains('#EXT-X-KEY:METHOD=NONE'));
      expect(text.trim().endsWith('#EXT-X-ENDLIST'), isTrue);
    });

    test('sample-aes and byte ranges are refused', () {
      expect(
        () => parseMedia(
          '#EXTM3U\n#EXT-X-KEY:METHOD=SAMPLE-AES,URI="k"\n#EXTINF:1,\na.ts',
          base,
        ),
        throwsA(isA<HlsUnsupported>()),
      );
      expect(
        () => parseMedia(
          '#EXTM3U\n#EXTINF:1,\n#EXT-X-BYTERANGE:100@0\na.ts',
          base,
        ),
        throwsA(isA<HlsUnsupported>()),
      );
    });
    test('segment names only use extensions the demuxer accepts', () {
      expect(segmentName(3, Uri.parse('https://a/b/chunk.ts')), 'seg00003.ts');
      expect(
        segmentName(4, Uri.parse('https://a/b/chunk.m4s')),
        'seg00004.m4s',
      );
      expect(segmentName(5, Uri.parse('https://a/b/chunk.jpg')), 'seg00005.ts');
      expect(segmentName(6, Uri.parse('https://a/b/chunk')), 'seg00006.ts');
    });
  });

  test('a task remembers it is kept as a folder', () {
    final original = task(state: DownloadState.done)..folder = true;
    expect(DownloadTask.fromJson(original.toJson())!.folder, isTrue);
  });

  test('an hls download resumes at the first missing segment', () async {
    final dir = Directory.systemTemp.createTempSync('hls');
    addTearDown(() => dir.deleteSync(recursive: true));
    final playlist = StringBuffer('#EXTM3U\n#EXT-X-TARGETDURATION:4\n');
    for (var i = 0; i < 5; i++) {
      playlist.write('#EXTINF:4,\nhttps://h/s$i.ts\n');
    }
    playlist.write('#EXT-X-ENDLIST\n');
    final fetched = <String>[];
    var broken = true;
    final progress = <int>[];

    Future<void> run() => downloadHls(
      url: 'https://h/index.m3u8',
      output: File('${dir.path}/Episode 001.mp4'),
      ffmpeg: null,
      cancel: DownloadCancel(),
      ffmpegCancel: FfmpegCancel(),
      onProgress: (done, total) => progress.add(done),
      onFinishing: () {},
      workers: 1,
      getText: (_) async => playlist.toString(),
      getFile: (uri, target) async {
        if (broken && uri.path.endsWith('s3.ts')) throw StateError('boom');
        fetched.add(uri.path);
        await target.writeAsString('x');
      },
    );

    await expectLater(run(), throwsStateError);
    expect(fetched, ['/s0.ts', '/s1.ts', '/s2.ts']);

    broken = false;
    fetched.clear();
    progress.clear();
    await run();
    expect(fetched, ['/s3.ts', '/s4.ts']);
    expect(progress.first, 3);
    expect(progress.last, 5);
    expect(File('${dir.path}/Episode 001/index.m3u8').existsSync(), isTrue);
  });

  group('queue order', () {
    test('dragging down puts the item after the target', () {
      expect(reorderWithin([1, 2, 3, 4], [1, 2, 3, 4], 0, 3), [2, 3, 1, 4]);
    });

    test('dragging up puts the item before the target', () {
      expect(reorderWithin([1, 2, 3, 4], [1, 2, 3, 4], 3, 1), [1, 4, 2, 3]);
    });

    test('finished items keep their place', () {
      expect(reorderWithin([9, 1, 8, 2, 3], [1, 2, 3], 2, 0), [9, 3, 1, 8, 2]);
    });

    test('moving to the top', () {
      expect(moveBefore([9, 1, 2, 3], 3, 1), [9, 3, 1, 2]);
      expect(moveBefore([1, 2, 3], 1, 1), [1, 2, 3]);
    });
  });
}
