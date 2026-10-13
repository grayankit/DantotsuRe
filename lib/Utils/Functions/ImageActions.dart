import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../Core/Downloads/ChapterFetcher.dart';
import '../../Core/NetworkManager/NetworkManager.dart';
import '../../Core/Preferences/StorageManager.dart';
import '../../Core/State/State.dart';

String imageFileName(String name) {
  final clean = name
      .replaceAll(RegExp(r'[\\/:*?"<>|]'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
  return clean.isEmpty ? 'image' : clean;
}

Future<File> downloadImage(String url, {required String name}) async {
  final temp = await getTemporaryDirectory();
  final part = File(p.join(temp.path, 'img_${url.hashCode.abs()}.part'));
  await find<NetworkManager>().download(url, part.path);
  final head = await part.openRead(0, 16).expand((b) => b).toList();
  final ext = sniffImageExtension(head) ?? 'jpg';
  final target = File(p.join(temp.path, '${imageFileName(name)}.$ext'));
  if (await target.exists()) await target.delete();
  return part.rename(target.path);
}

Future<File> saveImage(String url, {required String name}) async {
  final source = await downloadImage(url, name: name);
  final dir = await StorageManager.getDirectory(subPath: 'images');
  if (dir == null) throw const FileSystemException('No storage available');
  final ext = p.extension(source.path);
  final base = imageFileName(name);
  var target = File(p.join(dir.path, '$base$ext'));
  for (var i = 2; await target.exists(); i++) {
    target = File(p.join(dir.path, '$base ($i)$ext'));
  }
  return source.copy(target.path);
}
