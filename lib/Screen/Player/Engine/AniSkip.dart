import '../../Detail/Watch/Data/Providers/MetaHttp.dart';

enum SkipKind { opening, ending, recap, other }

class SkipStamp {
  final String name;
  final SkipKind kind;
  final double start;
  final double end;

  const SkipStamp(this.name, this.kind, this.start, this.end);

  bool covers(double seconds) => seconds >= start && seconds < end;
}

SkipKind skipKindOf(String type) {
  final t = type.toLowerCase();
  if (t == 'op' || t == 'mixed-op' || t.contains('open')) {
    return SkipKind.opening;
  }
  if (t == 'ed' || t == 'mixed-ed' || t.contains('end')) return SkipKind.ending;
  if (t == 'recap') return SkipKind.recap;
  return SkipKind.other;
}

String skipName(String type) => switch (type.toLowerCase()) {
  'op' => 'Opening',
  'ed' => 'Ending',
  'recap' => 'Recap',
  'mixed-op' => 'Mixed Opening',
  'mixed-ed' => 'Mixed Ending',
  _ => type,
};

List<SkipStamp> parseAniSkip(Object? body) {
  if (body is! Map || body['found'] != true) return const [];
  final results = body['results'];
  if (results is! List) return const [];
  final out = <SkipStamp>[];
  for (final r in results) {
    if (r is! Map) continue;
    final interval = r['interval'];
    final type = r['skipType'];
    if (interval is! Map || type is! String) continue;
    final start = (interval['startTime'] as num?)?.toDouble();
    final end = (interval['endTime'] as num?)?.toDouble();
    if (start == null || end == null || end <= start) continue;
    out.add(SkipStamp(skipName(type), skipKindOf(type), start, end));
  }
  out.sort((a, b) => a.start.compareTo(b.start));
  return out;
}

class AniSkip {
  AniSkip._();

  static Future<List<SkipStamp>> fetch({
    required int malId,
    required int episode,
    required int lengthSeconds,
  }) async {
    final body = await metaGet(
      'https://api.aniskip.com/v2/skip-times/$malId/$episode'
      '?types[]=op&types[]=ed&types[]=mixed-op&types[]=mixed-ed&types[]=recap'
      '&episodeLength=$lengthSeconds',
      tag: 'ANISKIP',
    );
    return parseAniSkip(body);
  }
}
