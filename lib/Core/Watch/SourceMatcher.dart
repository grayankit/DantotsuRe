import 'package:dartotsu_extension_bridge/dartotsu_extension_bridge.dart';

import '../Preferences/PrefManager.dart';
import '../Services/MediaService.dart';
import '../Services/Model/Media.dart';
import 'TitleMatch.dart';

class SourceMatch {
  final DMedia media;
  final int score;
  const SourceMatch(this.media, this.score);
}

class SourceMatcher {
  SourceMatcher._();

  static String _key(MediaService service, Source source, Media media) =>
      'watchMatch/${service.id}/${source.id}/${media.id}';

  static DMedia? saved(MediaService service, Source source, Media media) {
    final raw = PrefManager.getCustomVal<Map>(_key(service, source, media));
    final url = raw?['url'] as String?;
    if (raw == null || url == null) return null;
    return DMedia(
      title: raw['title'] as String?,
      url: url,
      cover: raw['cover'] as String?,
    );
  }

  static void save(
    MediaService service,
    Source source,
    Media media,
    DMedia match,
  ) => PrefManager.setCustomVal<Map>(_key(service, source, media), {
    'title': match.title,
    'url': match.url,
    'cover': match.cover,
  });

  static void forget(MediaService service, Source source, Media media) =>
      PrefManager.removeCustomVal(_key(service, source, media));

  static List<String> names(Media media) {
    final seen = <String>{};
    return [
          media.name,
          media.nameRomaji,
          media.userPreferredName,
          ...media.synonyms.where(_latin),
        ]
        .whereType<String>()
        .where((n) => n.trim().isNotEmpty && seen.add(n))
        .toList();
  }

  static bool _latin(String value) =>
      RegExp(r'^[a-zA-Z0-9\s]+$').hasMatch(value);

  static int _score(DMedia found, List<String> names) =>
      bestTitleRatio([found.title], names);

  static Future<List<SourceMatch>> search(
    Source source,
    String term,
    List<String> names,
  ) async {
    final pages = await source.methods.search(term, 1, const []);
    final list = [
      for (final m in pages.list)
        if (m.url != null && (m.title?.isNotEmpty ?? false))
          SourceMatch(m, _score(m, names)),
    ]..sort((a, b) => b.score.compareTo(a.score));
    return list;
  }

  static Future<DMedia?> find(
    Source source,
    Media media, {
    required String mode,
    void Function(String status)? onStatus,
  }) async {
    final targets = names(media);
    final terms = <String>[
      media.mainName,
      if (media.nameRomaji?.isNotEmpty ?? false) media.nameRomaji!,
      ...targets,
    ];
    final tried = <String>{};
    SourceMatch? best;
    for (final term in terms) {
      if (term.trim().isEmpty || !tried.add(term.toLowerCase())) continue;
      onStatus?.call(term);
      final found = await search(source, term, targets);
      if (found.isNotEmpty &&
          (best == null || found.first.score > best.score)) {
        best = found.first;
      }
      if (best != null && best.score >= 96) break;
      if (tried.length >= 4) break;
    }
    if (best == null) return null;
    final needed = mode == 'exact' ? 90 : 0;
    return best.score >= needed ? best.media : null;
  }
}
