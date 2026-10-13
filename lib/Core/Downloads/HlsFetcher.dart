import 'dart:async';
import 'dart:io';

import 'package:dartotsu_extension_bridge/dartotsu_extension_bridge.dart';
import 'package:path/path.dart' as p;
import 'package:rhttp/rhttp.dart';

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
  CancelToken? cancel,
}) async {
  final res = await find<NetworkManager>().get(
    url,
    headers: headers,
    cancelToken: cancel,
    decodeJson: false,
  );
  if (res.statusCode >= 400) throw DownloadHttpError(res.statusCode);
  return '${res.data}';
}

Future<List<HlsVariant>> loadVariants(
  String url, {
  Map<String, String>? headers,
}) async {
  final text = await fetchText(url, headers: headers);
  return isMasterPlaylist(text) ? parseMaster(text, Uri.parse(url)) : const [];
}

Future<void> downloadHls({
  required String url,
  required File output,
  required FfmpegAddon? ffmpeg,
  required CancelToken cancel,
  required FfmpegCancel ffmpegCancel,
  required void Function(int done, int total) onProgress,
  required void Function() onFinishing,
  Map<String, String>? headers,
  int? height,
  int workers = 4,
  Future<String> Function(String url)? getText,
  Future<void> Function(Uri uri, File target)? getFile,
}) async {
  Future<String> text0(String u) =>
      getText?.call(u) ?? fetchText(u, headers: headers, cancel: cancel);
  var playlistUrl = url;
  var text = await text0(url);
  if (isMasterPlaylist(text)) {
    final variants = parseMaster(text, Uri.parse(url));
    if (variants.isEmpty) throw const HlsUnsupported('Empty master playlist');
    playlistUrl = pickVariant(variants, height: height).uri.toString();
    text = await text0(playlistUrl);
  }
  final media = parseMedia(text, Uri.parse(playlistUrl));
  final name = p.basenameWithoutExtension(output.path);
  final dir = Directory(
    p.join(output.parent.path, ffmpeg == null ? name : '.$name'),
  );
  await dir.create(recursive: true);

  final keys = <Uri, String>{};
  final maps = <Uri, String>{};
  for (final s in media.segments) {
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

  Future<void> grab(Uri uri, String name) async {
    final target = File(p.join(dir.path, name));
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

  for (final e in keys.entries) {
    await grab(e.key, e.value);
  }
  for (final e in maps.entries) {
    await grab(e.key, e.value);
  }

  final pending = <int>[];
  for (final (i, s) in media.segments.indexed) {
    if (!await _complete(File(p.join(dir.path, segmentName(i, s.uri))))) {
      pending.add(i);
    }
  }
  var next = 0;
  var done = media.segments.length - pending.length;
  Object? failure;
  Future<void> worker() async {
    while (failure == null) {
      final n = next++;
      if (n >= pending.length) return;
      final i = pending[n];
      try {
        final uri = media.segments[i].uri;
        await grab(uri, segmentName(i, uri));
        done++;
        onProgress(done, media.segments.length);
      } catch (e) {
        logger(
          'HLS segment ${i + 1}/${media.segments.length} failed: $e',
          tag: 'DOWNLOAD',
        );
        failure ??= e;
      }
    }
  }

  onProgress(done, media.segments.length);
  await Future.wait([for (var k = 0; k < workers; k++) worker()]);
  final error = failure;
  if (error != null) throw error;

  final local = File(
    p.join(dir.path, ffmpeg == null ? 'index.m3u8' : 'local.m3u8'),
  );
  await local.writeAsString(
    buildLocalPlaylist(
      media,
      keyName: (uri) => keys[uri]!,
      mapName: (uri) => maps[uri]!,
    ),
  );
  if (ffmpeg == null) return;
  onFinishing();
  final temp = File('${output.path}.part.mp4');
  if (await temp.exists()) await temp.delete();
  await ffmpeg.remuxPlaylist(
    playlist: local.path,
    output: temp.path,
    cancel: ffmpegCancel,
  );
  if (await output.exists()) await output.delete();
  await temp.rename(output.path);
  await dir.delete(recursive: true);
}
