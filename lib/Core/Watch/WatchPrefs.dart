import '../Preferences/PrefManager.dart';
import '../Services/MediaService.dart';
import '../Services/Model/Media.dart';

const watchDefaultViewPref = Pref('watchDefaultView', 0, PrefLocation.OTHER);
const watchAutoMatchPref = Pref(
  'watchAutoMatch',
  'closest',
  PrefLocation.OTHER,
);
const watchChunkSizePref = Pref('watchChunkSize', 30, PrefLocation.OTHER);
const watchBlurUnwatchedPref = Pref(
  'watchBlurUnwatched',
  false,
  PrefLocation.OTHER,
);
const watchShowDescriptionPref = Pref(
  'watchShowDescription',
  true,
  PrefLocation.OTHER,
);
const watchShowFillerPref = Pref('watchShowFiller', true, PrefLocation.OTHER);
const watchMarkOnLongPressPref = Pref(
  'watchMarkOnLongPress',
  true,
  PrefLocation.OTHER,
);

class MediaWatchSettings {
  int? viewType;
  bool reverse;
  String? sourceId;
  String? sourceName;
  List<String> hiddenScanlators;
  String? matchMode;
  String? metaSource;

  MediaWatchSettings({
    this.viewType,
    this.reverse = false,
    this.sourceId,
    this.sourceName,
    List<String>? hiddenScanlators,
    this.matchMode,
    this.metaSource,
  }) : hiddenScanlators = hiddenScanlators ?? [];

  int get view => viewType ?? watchDefaultViewPref.rx.value;

  String get match => matchMode ?? watchAutoMatchPref.rx.value;

  Map<String, Object?> toJson() => {
    'viewType': viewType,
    'reverse': reverse,
    'sourceId': sourceId,
    'sourceName': sourceName,
    'hiddenScanlators': hiddenScanlators,
    'matchMode': matchMode,
    'metaSource': metaSource,
  };

  factory MediaWatchSettings.fromJson(Map<dynamic, dynamic> json) =>
      MediaWatchSettings(
        viewType: (json['viewType'] as num?)?.toInt(),
        reverse: json['reverse'] == true,
        sourceId: json['sourceId'] as String?,
        sourceName: json['sourceName'] as String?,
        hiddenScanlators: [
          for (final s in (json['hiddenScanlators'] as List?) ?? const []) '$s',
        ],
        matchMode: json['matchMode'] as String?,
        metaSource: json['metaSource'] as String?,
      );

  MediaWatchSettings copy() => MediaWatchSettings.fromJson(toJson());

  static String _key(MediaService service, Media media) =>
      'watchSettings/${service.id}/${media.id}';

  static MediaWatchSettings load(MediaService service, Media media) {
    final raw = PrefManager.getCustomVal<Map>(_key(service, media));
    return raw == null
        ? MediaWatchSettings()
        : MediaWatchSettings.fromJson(raw);
  }

  void save(MediaService service, Media media) =>
      PrefManager.setCustomVal<Map>(_key(service, media), toJson());

  static void reset(MediaService service, Media media) =>
      PrefManager.removeCustomVal(_key(service, media));
}
