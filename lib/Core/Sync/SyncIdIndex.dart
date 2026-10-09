import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

import '../NetworkManager/NetworkManager.dart';
import '../Preferences/StorageManager.dart';
import '../State/State.dart';
import 'SyncModels.dart';
import '../../Logger.dart';

const _source =
    'https://raw.githubusercontent.com/Fribb/anime-lists/master/anime-list-mini.json';

const _columns = [SyncKey.anilist, SyncKey.mal, SyncKey.kitsu, SyncKey.simkl];

const _maxAge = Duration(days: 7);

List<int> _compact(String raw) {
  final rows = jsonDecode(raw) as List;
  final out = <int>[];
  for (final r in rows) {
    if (r is! Map) continue;
    final row = [
      for (final c in const ['anilist_id', 'mal_id', 'kitsu_id', 'simkl_id'])
        r[c] is int ? r[c] as int : 0,
    ];
    if (row.where((v) => v > 0).length < 2) continue;
    out.addAll(row);
  }
  return out;
}

class SyncIdIndex {
  final List<int> _flat;
  late final Map<String, Map<int, int>> _by = _build();

  SyncIdIndex(this._flat);

  int get rows => _flat.length ~/ _columns.length;

  Map<String, Map<int, int>> _build() {
    final by = {for (final c in _columns) c: <int, int>{}};
    for (var row = 0; row < rows; row++) {
      for (var c = 0; c < _columns.length; c++) {
        final v = _flat[row * _columns.length + c];
        if (v > 0) by[_columns[c]]!.putIfAbsent(v, () => row);
      }
    }
    return by;
  }

  Map<String, int> expand(Map<String, int> ids, {String? prefer}) {
    final order = [
      ?prefer,
      for (final c in _columns)
        if (c != prefer) c,
    ];
    for (final c in order) {
      final id = ids[c];
      final row = id == null ? null : _by[c]?[id];
      if (row == null) continue;
      final out = {...ids};
      for (var i = 0; i < _columns.length; i++) {
        final v = _flat[row * _columns.length + i];
        if (v > 0) out.putIfAbsent(_columns[i], () => v);
      }
      return out;
    }
    return ids;
  }

  static SyncIdIndex? _cached;

  static Future<File> _file() async {
    final dir = await StorageManager.getDirectory(subPath: 'sync');
    return File(p.join(dir!.path, 'anime-ids.json'));
  }

  static Future<SyncIdIndex> load({bool force = false}) async {
    final cached = _cached;
    if (cached != null && !force) return cached;
    final file = await _file();
    final stale =
        !await file.exists() ||
        DateTime.now().difference(await file.lastModified()) > _maxAge;
    if (stale || force) {
      try {
        final res = await find<NetworkManager>().get(
          _source,
          decodeJson: false,
        );
        if (res.statusCode == 200 && res.data is String) {
          final flat = await compute(_compact, res.data as String);
          if (flat.isNotEmpty) {
            await file.writeAsString(jsonEncode(flat));
            return _cached = SyncIdIndex(flat);
          }
        }
      } catch (e) {
        logger('SyncIdIndex download failed: $e', logLevel: LogLevel.error);
      }
    }
    if (await file.exists()) {
      final flat = (jsonDecode(await file.readAsString()) as List).cast<int>();
      return _cached = SyncIdIndex(flat);
    }
    throw SyncFatal('Could not download the anime ID mapping');
  }
}
