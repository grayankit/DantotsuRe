import '../../../../../Logger.dart';
import '../../../../../Utils/Lru.dart';
import '../../../../../Core/Preferences/PrefManager.dart';
import '../../../../../Core/Services/MediaService.dart';
import '../../../../../Core/Services/Model/Media.dart';
import '../WatchPrefs.dart';

class SourceMatchRecord {
  final String? title;
  final String url;
  final String? cover;

  const SourceMatchRecord({this.title, required this.url, this.cover});

  Map<String, Object?> toJson() => {'title': title, 'url': url, 'cover': cover};

  static SourceMatchRecord? fromJson(Object? json) {
    if (json is! Map) return null;
    final url = json['url'];
    if (url is! String) return null;
    return SourceMatchRecord(
      title: json['title'] as String?,
      url: url,
      cover: json['cover'] as String?,
    );
  }
}

class Playback {
  int position;
  int duration;
  int at;

  Playback({this.position = 0, this.duration = 0, int? at})
    : at = at ?? DateTime.now().millisecondsSinceEpoch;

  double get fraction => duration <= 0 ? 0 : position / duration;

  bool get finished => fraction >= 0.9;

  Map<String, Object?> toJson() => {
    'position': position,
    'duration': duration,
    'at': at,
  };

  static Playback? fromJson(Object? json) {
    if (json is! Map) return null;
    return Playback(
      position: (json['position'] as num?)?.toInt() ?? 0,
      duration: (json['duration'] as num?)?.toInt() ?? 0,
      at: (json['at'] as num?)?.toInt(),
    );
  }
}

class StreamPrefs {
  bool auto;
  Map<String, String> last;

  StreamPrefs({this.auto = false, Map<String, String>? last})
    : last = last ?? {};

  Map<String, Object?> toJson() => {'auto': auto, 'last': last};

  static StreamPrefs fromJson(Object? json) {
    if (json is! Map) return StreamPrefs();
    return StreamPrefs(
      auto: json['auto'] == true,
      last: {for (final e in _entries(json['last'])) '${e.key}': '${e.value}'},
    );
  }
}

Iterable<MapEntry<dynamic, dynamic>> _entries(Object? value) =>
    value is Map ? value.entries : const [];

class Bookmark {
  final String unit;
  final int position;
  final int total;
  final String label;
  final int at;

  const Bookmark({
    required this.unit,
    required this.position,
    required this.total,
    required this.label,
    required this.at,
  });

  Map<String, Object?> toJson() => {
    'unit': unit,
    'position': position,
    'total': total,
    'label': label,
    'at': at,
  };

  static Bookmark? fromJson(Object? json) {
    if (json is! Map) return null;
    final unit = json['unit'];
    if (unit is! String) return null;
    return Bookmark(
      unit: unit,
      position: (json['position'] as num?)?.toInt() ?? 0,
      total: (json['total'] as num?)?.toInt() ?? 0,
      label: '${json['label'] ?? ''}',
      at: (json['at'] as num?)?.toInt() ?? 0,
    );
  }
}

class MediaRecord {
  MediaWatchSettings watch;
  final Map<String, SourceMatchRecord> matches;
  final Map<String, Playback> playback;
  StreamPrefs streams;
  Map<String, Object?> ids;
  Map<String, Object?> player;
  Map<String, Object?> reader;
  int? commentsId;
  int? mangaUpdatesId;
  int tab;
  bool saveProgress;
  Map<String, bool> skips;
  List<Bookmark> bookmarks;

  MediaRecord({
    MediaWatchSettings? watch,
    Map<String, SourceMatchRecord>? matches,
    Map<String, Playback>? playback,
    StreamPrefs? streams,
    Map<String, Object?>? ids,
    Map<String, Object?>? player,
    Map<String, Object?>? reader,
    this.commentsId,
    this.mangaUpdatesId,
    this.tab = 0,
    this.saveProgress = true,
    Map<String, bool>? skips,
    List<Bookmark>? bookmarks,
  }) : skips = skips ?? {},
       bookmarks = bookmarks ?? [],
       watch = watch ?? MediaWatchSettings(),
       matches = matches ?? {},
       playback = playback ?? {},
       streams = streams ?? StreamPrefs(),
       ids = ids ?? {},
       player = player ?? {},
       reader = reader ?? {};

  Map<String, Object?> toJson() => {
    'watch': watch.toJson(),
    'matches': {for (final e in matches.entries) e.key: e.value.toJson()},
    'playback': {for (final e in playback.entries) e.key: e.value.toJson()},
    'streams': streams.toJson(),
    'ids': ids,
    'player': player,
    'reader': reader,
    'commentsId': commentsId,
    'mangaUpdatesId': mangaUpdatesId,
    'tab': tab,
    'saveProgress': saveProgress,
    'skips': skips,
    'bookmarks': [for (final b in bookmarks) b.toJson()],
  };

  factory MediaRecord.fromJson(Map<dynamic, dynamic> json) {
    final matches = <String, SourceMatchRecord>{};
    for (final e in _entries(json['matches'])) {
      final match = SourceMatchRecord.fromJson(e.value);
      if (match != null) matches['${e.key}'] = match;
    }
    final playback = <String, Playback>{};
    for (final e in _entries(json['playback'])) {
      final item = Playback.fromJson(e.value);
      if (item != null) playback['${e.key}'] = item;
    }
    return MediaRecord(
      watch: json['watch'] is Map
          ? MediaWatchSettings.fromJson(json['watch'] as Map)
          : null,
      matches: matches,
      playback: playback,
      streams: StreamPrefs.fromJson(json['streams']),
      ids: json['ids'] is Map
          ? Map<String, Object?>.from(json['ids'] as Map)
          : null,
      player: json['player'] is Map
          ? Map<String, Object?>.from(json['player'] as Map)
          : null,
      reader: json['reader'] is Map
          ? Map<String, Object?>.from(json['reader'] as Map)
          : null,
      commentsId: (json['commentsId'] as num?)?.toInt(),
      mangaUpdatesId: (json['mangaUpdatesId'] as num?)?.toInt(),
      tab: (json['tab'] as num?)?.toInt() ?? 0,
      saveProgress: json['saveProgress'] != false,
      skips: {
        for (final e in _entries(json['skips']))
          if (e.value is bool) '${e.key}': e.value as bool,
      },
      bookmarks: [
        for (final e
            in json['bookmarks'] is List ? json['bookmarks'] as List : const [])
          ?Bookmark.fromJson(e),
      ],
    );
  }
}

class MediaRecords {
  MediaRecords._();

  static final _memo = Lru<String, MediaRecord>(64);

  static void reload() => _memo.clear();

  static String key(MediaService service, Media media) =>
      'media/${service.id}/${media.id}';

  static MediaRecord of(MediaService service, Media media) {
    final k = key(service, media);
    final hit = _memo[k];
    if (hit != null) return hit;
    final raw = PrefManager.getCustomVal<Map>(k);
    var record = MediaRecord();
    if (raw != null) {
      try {
        record = MediaRecord.fromJson(raw);
      } catch (e, st) {
        logError('MediaRecord', e, st);
      }
    }
    return _memo[k] = record;
  }

  static void save(MediaService service, Media media) {
    final record = of(service, media);
    PrefManager.setCustomVal<Map>(key(service, media), record.toJson());
  }

  static void reset(MediaService service, Media media) {
    final k = key(service, media);
    _memo.remove(k);
    PrefManager.removeCustomVal(k);
  }
}
