import 'package:dartotsu_extension_bridge/dartotsu_extension_bridge.dart';

import 'EpisodeMeta.dart';

class WatchUnit {
  final DEpisode raw;
  final String number;
  final double value;
  final String? scanlator;
  String title;
  String? description;
  String? thumbnail;
  bool filler;
  bool recap;
  DateTime? uploaded;
  DateTime? aired;
  int? runtime;
  double? rating;

  WatchUnit({
    required this.raw,
    required this.number,
    required this.value,
    required this.title,
    this.scanlator,
    this.description,
    this.thumbnail,
    this.filler = false,
    this.recap = false,
    this.uploaded,
    this.aired,
    this.runtime,
    this.rating,
  });

  DateTime? get date => aired ?? uploaded;

  bool isWatched(int progress) => value <= progress;
}

List<DEpisode> normalizeEpisodes(List<DEpisode> input) {
  var first = true;
  var normalize = false;
  var shift = 0;
  final seen = <String, int>{};
  final ordered = input.reversed.toList();
  final out = <DEpisode>[];
  for (final (index, ep) in ordered.indexed) {
    final number = double.tryParse(ep.episodeNumber) ?? (index + 1).toDouble();
    if (first) {
      first = false;
      if (number > 3.0) normalize = true;
    }
    var label = ep.episodeNumber;
    if (normalize) {
      if (number % 1 != 0) {
        shift--;
        final remainder = double.parse((number % 1).toStringAsFixed(2));
        label = (index + 1 + remainder + shift).toString();
      } else {
        label = (index + 1 + shift).toString();
      }
    }
    final count = seen[label];
    if (count != null) {
      seen[label] = count + 1;
      label = '$label.${count + 1}';
    } else {
      seen[label] = 1;
    }
    ep.episodeNumber = label;
    out.add(ep);
  }
  out.sort(
    (a, b) => (double.tryParse(a.episodeNumber) ?? 0).compareTo(
      double.tryParse(b.episodeNumber) ?? 0,
    ),
  );
  return out;
}

final _chapterNumber = RegExp(r'([0-9]+)(\.[0-9]+)?');
final _volume = RegExp(r'\b(?:v|ver|vol|version|volume|season|s)[^a-z]?[0-9]+');

double? parseChapterNumber(String title, String name) {
  var text = name.toLowerCase().replaceAll(title.toLowerCase(), '').trim();
  text = text.replaceAll(',', '.').replaceAll('-', '.').replaceAll(_volume, '');
  final match = _chapterNumber.firstMatch(text);
  if (match == null) return null;
  return double.tryParse('${match.group(1)}${match.group(2) ?? ''}');
}

List<DEpisode> prepareChapters(List<DEpisode> input, String title) {
  final out = <DEpisode>[];
  for (final (index, ch) in input.reversed.indexed) {
    final known = double.tryParse(ch.episodeNumber);
    final value =
        (known != null && known > 0 ? known : null) ??
        parseChapterNumber(title, ch.name ?? '') ??
        (index + 1).toDouble();
    ch.episodeNumber = value == value.truncateToDouble()
        ? value.toInt().toString()
        : value.toString();
    out.add(ch);
  }
  return out;
}

List<DEpisode> normalizeIsolate(List<DEpisode> input) =>
    normalizeEpisodes(input);

DateTime? parseUploadDate(String? raw) {
  if (raw == null || raw.isEmpty) return null;
  final millis = int.tryParse(raw);
  if (millis != null && millis > 100000000) {
    return DateTime.fromMillisecondsSinceEpoch(
      millis < 100000000000 ? millis * 1000 : millis,
    );
  }
  return DateTime.tryParse(raw);
}

List<WatchUnit> buildUnits(
  List<DEpisode> episodes,
  Map<String, EpisodeMeta> meta, {
  required String fallbackThumb,
  required bool anime,
}) {
  return [
    for (final ep in episodes)
      _unit(ep, meta[episodeKey(ep.episodeNumber)], fallbackThumb, anime),
  ];
}

void refreshUnit(
  WatchUnit unit,
  EpisodeMeta? meta, {
  required String fallbackThumb,
  required bool anime,
}) {
  final fresh = _unit(unit.raw, meta, fallbackThumb, anime);
  unit
    ..title = fresh.title
    ..description = fresh.description
    ..thumbnail = fresh.thumbnail
    ..filler = fresh.filler
    ..recap = fresh.recap
    ..aired = fresh.aired
    ..runtime = fresh.runtime
    ..rating = fresh.rating;
}

WatchUnit _unit(DEpisode ep, EpisodeMeta? meta, String fallback, bool anime) {
  final value = double.tryParse(ep.episodeNumber) ?? 0;
  final own = ep.name?.trim();
  final fromMeta = meta?.title?.trim();
  final title = (fromMeta?.isNotEmpty ?? false)
      ? fromMeta!
      : (own?.isNotEmpty ?? false)
      ? own!
      : '';
  return WatchUnit(
    raw: ep,
    number: ep.episodeNumber,
    value: value,
    title: title,
    scanlator: ep.scanlator,
    description: (meta?.description?.isNotEmpty ?? false)
        ? meta!.description
        : ep.description,
    thumbnail: anime
        ? (meta?.thumbnail ??
              ((ep.thumbnail?.isNotEmpty ?? false) ? ep.thumbnail : null) ??
              (fallback.isEmpty ? null : fallback))
        : null,
    filler: meta?.filler == true || ep.filler == true,
    recap: meta?.recap == true,
    uploaded: parseUploadDate(ep.dateUpload),
    aired: meta?.aired,
    runtime: meta?.runtime,
    rating: meta?.rating,
  );
}

List<List<WatchUnit>> chunkUnits(List<WatchUnit> units, int size) {
  if (units.isEmpty) return const [];
  return [
    for (var i = 0; i < units.length; i += size)
      units.sublist(i, i + size > units.length ? units.length : i + size),
  ];
}

int chunkOf(List<List<WatchUnit>> chunks, int progress) {
  for (final (i, chunk) in chunks.indexed) {
    if (chunk.any((u) => u.value == progress + 1)) return i;
  }
  for (final (i, chunk) in chunks.indexed) {
    if (chunk.any((u) => u.value > progress)) return i;
  }
  return chunks.isEmpty ? 0 : chunks.length - 1;
}
