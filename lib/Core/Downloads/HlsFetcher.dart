import 'DownloadCancel.dart';
import 'dart:async';
import 'dart:io';

import 'package:dartotsu_extension_bridge/dartotsu_extension_bridge.dart';
import 'package:path/path.dart' as p;

import '../../Logger.dart';
import '../NetworkManager/NetworkManager.dart';
import '../State/State.dart';
import 'FileFetcher.dart';
import 'Hls.dart';

Future<bool> _complete(File file) async =>
    await file.exists() && await file.length() > 0;

Future<String> fetchText(
  String url, {
  Map<String, String>? headers,
  DownloadCancel? cancel,
}) async {
  final res = await find<NetworkManager>().get(
    url,
    headers: headers,
    cancelToken: cancel?.fresh(),
    decodeJson: false,
  );
  if (res.statusCode >= 400) throw DownloadHttpError(res.statusCode);
  return '${res.data}';
}

class HlsMaster {
  final List<HlsVariant> variants;
  final List<HlsAudio> audios;

  const HlsMaster(this.variants, this.audios);
}

Future<HlsMaster> loadMaster(String url, {Map<String, String>? headers}) async {
  final text = await fetchText(url, headers: headers);
  if (!isMasterPlaylist(text)) return const HlsMaster([], []);
  final base = Uri.parse(url);
  return HlsMaster(parseMaster(text, base), parseAudios(text, base));
}

Future<List<HlsVariant>> loadVariants(
  String url, {
  Map<String, String>? headers,
}) async => (await loadMaster(url, headers: headers)).variants;

Future<void> downloadHls({
  required String url,
  required File output,
  required FfmpegAddon? ffmpeg,
  required DownloadCancel cancel,
  required FfmpegCancel ffmpegCancel,
  required void Function(int done, int total) onProgress,
  required void Function() onFinishing,
  Map<String, String>? headers,
  int? height,
  String? audioLabel,
  int workers = 4,
  Future<String> Function(String url)? getText,
  Future<void> Function(Uri uri, File target)? getFile,
}) async {
  Future<String> text0(String u) =>
      getText?.call(u) ?? fetchText(u, headers: headers, cancel: cancel);
  var playlistUrl = url;
  var text = await text0(url);
  HlsAudio? audio;
  if (isMasterPlaylist(text)) {
    final base = Uri.parse(url);
    final variants = parseMaster(text, base);
    if (variants.isEmpty) throw const HlsUnsupported('Empty master playlist');
    final variant = pickVariant(variants, height: height);
    playlistUrl = variant.uri.toString();
    audio = pickAudio(parseAudios(text, base), variant, audioLabel);
    text = await text0(playlistUrl);
  }
  final media = parseMedia(text, Uri.parse(playlistUrl));
  final audioMedia = audio == null
      ? null
      : parseMedia(await text0(audio.uri.toString()), audio.uri!);
  final name = p.basenameWithoutExtension(output.path);
  final dir = Directory(
    p.join(output.parent.path, ffmpeg == null ? name : '.$name'),
  );
  await dir.create(recursive: true);
  final audioDir = Directory(p.join(dir.path, 'audio'));
  if (audioMedia != null) await audioDir.create(recursive: true);

  Future<void> grab(Directory into, Uri uri, String name) async {
    final target = File(p.join(into.path, name));
    if (await _complete(target)) return;
    if (getFile != null) return getFile(uri, target);
    await fetchWithRetry(
      () => fetchFile(
        url: uri.toString(),
        target: target,
        cancel: cancel,
        headers: headers,
        onProgress: (_, _) {},
      ),
      cancel: cancel,
    );
  }

  final total = media.segments.length + (audioMedia?.segments.length ?? 0);
  var done = 0;
  Object? failure;

  Future<({Map<Uri, String> keys, Map<Uri, String> maps})> pull(
    HlsMedia item,
    Directory into,
  ) async {
    final keys = <Uri, String>{};
    final maps = <Uri, String>{};
    for (final s in item.segments) {
      final key = s.key?.uri;
      if (key != null) keys.putIfAbsent(key, () => 'key${keys.length}.ts');
      final map = s.map;
      if (map != null) {
        maps.putIfAbsent(
          map,
          () => 'init${maps.length}.${hlsExtension(map, fallback: 'mp4')}',
        );
      }
    }
    for (final e in keys.entries) {
      await grab(into, e.key, e.value);
    }
    for (final e in maps.entries) {
      await grab(into, e.key, e.value);
    }
    final pending = <int>[];
    for (final (i, s) in item.segments.indexed) {
      if (await _complete(File(p.join(into.path, segmentName(i, s.uri))))) {
        done++;
      } else {
        pending.add(i);
      }
    }
    onProgress(done, total);
    var next = 0;
    Future<void> worker() async {
      while (failure == null) {
        final n = next++;
        if (n >= pending.length) return;
        final i = pending[n];
        try {
          final uri = item.segments[i].uri;
          await grab(into, uri, segmentName(i, uri));
          done++;
          onProgress(done, total);
        } catch (e) {
          logger(
            'HLS segment ${i + 1}/${item.segments.length} failed: $e',
            tag: 'DOWNLOAD',
          );
          failure ??= e;
        }
      }
    }

    await Future.wait([for (var k = 0; k < workers; k++) worker()]);
    final error = failure;
    if (error != null) throw error;
    return (keys: keys, maps: maps);
  }

  Future<void> writePlaylist(
    HlsMedia item,
    File target,
    ({Map<Uri, String> keys, Map<Uri, String> maps}) names,
  ) => target.writeAsString(
    buildLocalPlaylist(
      item,
      keyName: (uri) => names.keys[uri]!,
      mapName: (uri) => names.maps[uri]!,
    ),
  );

  final videoNames = await pull(media, dir);
  final audioNames = audioMedia == null
      ? null
      : await pull(audioMedia, audioDir);

  final videoPlaylist = File(
    p.join(
      dir.path,
      ffmpeg != null
          ? 'local.m3u8'
          : (audioMedia == null ? 'index.m3u8' : 'video.m3u8'),
    ),
  );
  await writePlaylist(media, videoPlaylist, videoNames);
  File? audioPlaylist;
  if (audioMedia != null) {
    audioPlaylist = File(
      p.join(audioDir.path, ffmpeg != null ? 'local.m3u8' : 'audio.m3u8'),
    );
    await writePlaylist(audioMedia, audioPlaylist, audioNames!);
  }
  if (ffmpeg == null) {
    if (audio != null) {
      await File(p.join(dir.path, 'index.m3u8')).writeAsString(
        buildLocalMaster(
          audio: audio,
          audioPath: 'audio/audio.m3u8',
          videoPath: 'video.m3u8',
        ),
      );
    }
    return;
  }
  onFinishing();
  final temp = File('${output.path}.part.mp4');
  if (await temp.exists()) await temp.delete();
  if (audioPlaylist == null) {
    await ffmpeg.remuxPlaylist(
      playlist: videoPlaylist.path,
      output: temp.path,
      cancel: ffmpegCancel,
    );
  } else {
    const input = [
      '-allowed_extensions',
      'ALL',
      '-protocol_whitelist',
      'file,crypto,data',
      '-i',
    ];
    await ffmpeg.run([
      ...input,
      videoPlaylist.path,
      ...input,
      audioPlaylist.path,
      '-map',
      '0:v:0',
      '-map',
      '1:a:0',
      '-c',
      'copy',
      '-bsf:a',
      'aac_adtstoasc',
      '-movflags',
      '+faststart',
      temp.path,
    ], cancel: ffmpegCancel);
  }
  if (await output.exists()) await output.delete();
  await temp.rename(output.path);
  await dir.delete(recursive: true);
}
