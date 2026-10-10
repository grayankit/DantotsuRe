import '../../../Utils/Lru.dart';
import '../EpisodeMeta.dart';
import 'MetaHttp.dart';

class AniZipProvider extends EpisodeMetaProvider {
  @override
  String get id => 'anizip';

  @override
  String get name => 'ani.zip';

  @override
  bool supports(MetaIds ids) =>
      ids.anime && (ids.anilist != null || ids.mal != null);

  static final _memo = Lru<String, Future<Map<String, dynamic>?>>(24);

  Future<Map<String, dynamic>?> _load(MetaIds ids) {
    final query = ids.anilist != null
        ? {'anilist_id': '${ids.anilist}'}
        : {'mal_id': '${ids.mal}'};
    final key = query.entries.first.toString();
    final cached = _memo[key];
    if (cached != null) return cached;
    final future = metaGet(
      'https://api.ani.zip/mappings',
      query: query,
    ).then((body) => body is Map<String, dynamic> ? body : null);
    _memo[key] = future;
    future.then((body) {
      if (body == null) _memo.remove(key);
    });
    return future;
  }

  @override
  Future<Map<String, EpisodeMeta>> fetch(MetaIds ids) async {
    final body = await _load(ids);
    return parseAniZipEpisodes(body?['episodes']);
  }
}

Map<String, EpisodeMeta> parseAniZipEpisodes(Object? episodes) {
  if (episodes is! Map) return const {};
  final out = <String, EpisodeMeta>{};
  for (final entry in episodes.entries) {
    final ep = entry.value;
    if (ep is! Map || double.tryParse('${entry.key}') == null) continue;
    final absolute = ep['absoluteEpisodeNumber'];
    final key = episodeKey(
      absolute is num && absolute > 0 ? absolute : entry.key,
    );
    final titles = ep['title'];
    final title = titles is Map
        ? nonBlank(titles['en']) ??
              nonBlank(titles['x-jat']) ??
              nonBlank(titles['ja'])
        : nonBlank(titles);
    out[key] = EpisodeMeta(
      number: key,
      title: title,
      description: nonBlank(ep['summary']) ?? nonBlank(ep['overview']),
      thumbnail: nonBlank(ep['image']),
      aired:
          DateTime.tryParse('${ep['airDateUtc'] ?? ''}') ??
          DateTime.tryParse('${ep['airdate'] ?? ep['airDate'] ?? ''}'),
      runtime:
          (ep['runtime'] as num?)?.toInt() ?? (ep['length'] as num?)?.toInt(),
      rating: double.tryParse('${ep['rating'] ?? ''}'),
    );
  }
  return out;
}
