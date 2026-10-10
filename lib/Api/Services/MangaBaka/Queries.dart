import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'dart:async';

import '../../../Core/Preferences/PrefManager.dart';
import '../../../Core/Services/Api/LibraryCache.dart';
import '../../../Core/Services/Api/Queries.dart';
import '../../../Core/Services/Api/SectionJobs.dart';
import '../../../Core/Services/LayoutPref.dart';
import '../../../Core/Services/Model/Media.dart';
import '../../../Core/Services/Model/MediaListEntry.dart';
import '../../../Core/ThemeManager/LanguageSwitcher.dart';
import '../../../Model/MediaType.dart';
import '../../../Model/SearchResults.dart';
import 'Client.dart';
import 'Data/Mapper.dart';
import 'Prefs.dart';

const mangaBakaPageSize = 20;

class MangaBakaSection {
  final String title;
  final Map<String, String> query;

  const MangaBakaSection(this.title, this.query);
}

const mangaBakaSections = [
  MangaBakaSection('Trending Now', {
    'sort_by': 'popularity_asc',
    'status': 'releasing',
  }),
  MangaBakaSection('Latest Releases', {'sort_by': 'latest'}),
  MangaBakaSection('Top Rated', {'sort_by': 'score_desc'}),
  MangaBakaSection('Upcoming', {
    'sort_by': 'popularity_asc',
    'status': 'upcoming',
  }),
  MangaBakaSection('Top Manga', {
    'sort_by': 'popularity_asc',
    'type': 'manga,manhwa,manhua',
  }),
  MangaBakaSection('Top Novels', {
    'sort_by': 'popularity_asc',
    'type': 'novel',
  }),
];

const _readingTypes = 'manga,manhwa,manhua';

List<MangaBakaSection> mangaBakaSectionsFor(MediaType type) {
  final novel = type == MediaType.novel;
  return [
    for (final s in mangaBakaSections)
      if (s.title == (novel ? 'Top Manga' : 'Top Novels'))
        ...const <MangaBakaSection>[]
      else
        MangaBakaSection(s.title, {
          ...s.query,
          'type': s.query['type'] ?? (novel ? 'novel' : _readingTypes),
        }),
  ];
}

const _fallbackGenres = {
  'Action': 'action',
  'Adventure': 'adventure',
  'Comedy': 'comedy',
  'Drama': 'drama',
  'Fantasy': 'fantasy',
  'Horror': 'horror',
  'Mystery': 'mystery',
  'Romance': 'romance',
  'School Life': 'school_life',
  'Sci-Fi': 'sci-fi',
  'Seinen': 'seinen',
  'Shoujo': 'shoujo',
  'Shounen': 'shounen',
  'Slice Of Life': 'slice_of_life',
  'Sports': 'sports',
  'Supernatural': 'supernatural',
};

const _genreKey = 'mangabaka_genres';

Map<String, String> mangaBakaGenreSlugs() {
  final saved = loadCustomData<Map<String, dynamic>>(_genreKey);
  if (saved == null || saved.isEmpty) return _fallbackGenres;
  return {for (final e in saved.entries) e.key: '${e.value}'};
}

List<String> mangaBakaGenres() => mangaBakaGenreSlugs().keys.toList();

const _sorts = {
  'SCORE_DESC': 'score_desc',
  'POPULARITY_DESC': 'popularity_asc',
  'START_DATE_DESC': 'latest',
  'TITLE_ROMAJI': 'name_asc',
};

Map<String, String> get mangaBakaSearchSorts => {
  'SCORE_DESC': getString.sortTopRated,
  'POPULARITY_DESC': getString.sortMostPopular,
  'START_DATE_DESC': getString.sortNewest,
  'TITLE_ROMAJI': getString.sortAz,
};

String? _searchStatus(String status) =>
    switch (status.toUpperCase().replaceAll(' ', '_')) {
      'RELEASING' => 'releasing',
      'FINISHED' => 'completed',
      'NOT_YET_RELEASED' => 'upcoming',
      'HIATUS' => 'hiatus',
      'CANCELLED' => 'cancelled',
      _ => null,
    };

class MangaBakaQueries extends Queries {
  final MangaBakaClient client;
  final Future<bool> Function() refreshUser;
  final void Function(int chapters)? onChapters;

  MangaBakaQueries(this.client, {required this.refreshUser, this.onChapters});

  int ratingScale = 10;

  Map<String, List<String>> get _nsfwFilter => MangaBakaPref.hideNsfw.value
      ? const {
          'not_content_rating': ['erotica', 'pornographic'],
        }
      : const {};

  List<Media> _media(Map<String, dynamic> body) {
    final seen = <String>{};
    return [
      for (final s in (body['data'] as List?) ?? const [])
        if (s is Map && seen.add('${s['id']}'))
          mapMangaBakaSeries(s.cast<String, dynamic>()),
    ];
  }

  Future<List<Media>> _withList(List<Media> items) async {
    if (!client.hasToken || items.isEmpty) return items;
    try {
      final mine = {for (final m in await library()) m.id: m};
      for (final m in items) {
        final entry = mine[m.id];
        if (entry != null) m.takeListEntry(entry);
      }
    } catch (_) {}
    return items;
  }

  Future<List<Media>> sectionPage(
    MangaBakaSection section, {
    int page = 1,
  }) async {
    final types = section.query['type']?.split(',');
    final body = await client.get(
      '/series/search',
      query: {
        for (final e in section.query.entries)
          if (e.key != 'type') e.key: e.value,
        'limit': '$mangaBakaPageSize',
        'page': '$page',
      },
      multi: {..._nsfwFilter, 'type': ?types},
      cache: const Duration(minutes: 10),
    );
    return _withList(_media(body));
  }

  Future<List<Media>> typePicks(String type) async {
    final body = await client.get(
      '/series/search',
      query: {'sort_by': 'popularity_asc', 'type': type, 'limit': '12'},
      multi: _nsfwFilter,
      cache: const Duration(minutes: 10),
    );
    return _withList(_media(body));
  }

  @override
  Future<bool> getUserData() async => refreshUser();

  late final _library = LibraryCache<List<Media>>(load: (_) => _loadLibrary());

  Future<List<Media>> library() =>
      client.hasToken ? _library.get() : Future.value(const []);

  void invalidateLibrary() => _library.expire();

  void clearLibrary() => _library.clear();

  Future<List<Media>> _loadLibrary() async {
    final rows = <Map<String, dynamic>>[];
    String? next;
    var first = true;
    while (first || next != null) {
      first = false;
      final (page, link) = await client.getParsed(
        next ?? '/my/library',
        _parseLibraryRows,
        query: next == null
            ? {'page': '1', 'limit': '100', 'sort_by': 'updated_at_desc'}
            : null,
      );
      rows.addAll(page);
      next = link;
    }
    final mapped = await compute(_mapLibrary, rows);
    ratingScale = mapped.scale;
    onChapters?.call(mapped.chapters);
    return mapped.media;
  }

  Future<void> _overlayEntry(Media media) async {
    if (!client.hasToken) return;
    try {
      final body = await client.get('/my/library/${media.id}');
      final entry = (body['data'] as Map?)?.cast<String, dynamic>();
      if (entry != null) applyMangaBakaEntry(media, entry, ratingScale);
    } on MangaBakaException catch (e) {
      if (e.status != 404) rethrow;
    } catch (_) {}
  }

  Future<Media?> _fetch(String id) async {
    final body = await client.get(
      '/series/$id',
      cache: const Duration(minutes: 5),
    );
    final data = (body['data'] as Map?)?.cast<String, dynamic>();
    if (data == null) return null;
    final media = mapMangaBakaSeries(data);
    await _overlayEntry(media);
    return media;
  }

  @override
  Future<Media?> getMedia(String id) async {
    try {
      return await _fetch(id);
    } on MangaBakaException {
      return null;
    }
  }

  @override
  Future<Media?> mediaDetails(Media media) async {
    final full = await getMedia(media.id);
    return full == null
        ? media
        : (full..cameFromContinue = media.cameFromContinue);
  }

  Future<List<Media>> related(Media media) async {
    try {
      final body = await client.get(
        '/series/${media.id}/related',
        cache: const Duration(minutes: 30),
      );
      final out = <Media>[];
      final data = (body['data'] as Map?) ?? const {};
      for (final e in data.entries) {
        for (final s in (e.value as List?) ?? const []) {
          if (s is! Map) continue;
          final m = mapMangaBakaSeries(s.cast<String, dynamic>())
            ..relation = _label('${e.key}');
          if (e.key == 'prequel') media.prequel ??= m;
          if (e.key == 'sequel') media.sequel ??= m;
          out.add(m);
        }
      }
      return _visible(out);
    } catch (_) {
      return const [];
    }
  }

  Future<List<Media>> similar(Media media) async {
    try {
      final body = await client.get(
        '/series/${media.id}/similar',
        cache: const Duration(minutes: 30),
      );
      return _visible([
        for (final e in (body['data'] as List?) ?? const [])
          if (e is Map && e['series'] is Map)
            mapMangaBakaSeries((e['series'] as Map).cast<String, dynamic>()),
      ]);
    } catch (_) {
      return const [];
    }
  }

  List<Media> _visible(List<Media> items) => MangaBakaPref.hideNsfw.value
      ? [
          for (final m in items)
            if (!m.isAdult) m,
        ]
      : items;

  String _label(String key) => key
      .replaceAll('_', ' ')
      .split(' ')
      .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
      .join(' ');

  @override
  List<SectionJob> homeJobs() {
    if (!client.hasToken) return const [];
    final hide = MangaBakaPref.hideNsfw.value;
    Future<List<Media>> pick(Set<String> statuses) async => [
      for (final m in await library())
        if (statuses.contains(m.userStatus) && !(hide && m.isAdult)) m,
    ];
    SectionJob job(String title, Set<String> statuses) => () async {
      final items = await pick(statuses);
      return items.isEmpty ? <String, List<Media>>{} : {title: items};
    };
    final jobs = <(String, SectionJob)>[
      ('Continue Reading', job('Continue Reading', {'CURRENT', 'REPEATING'})),
      ('Planned Manga', job('Planned Manga', {'PLANNING'})),
      ('On Hold', job('On Hold', {'PAUSED'})),
      ('Dropped', job('Dropped', {'DROPPED'})),
      if (hide)
        (
          'Hidden Media',
          () async {
            final items = [
              for (final m in await library())
                if (m.isAdult) m,
            ];
            return items.isEmpty
                ? <String, List<Media>>{}
                : {'Hidden Media': items};
          },
        ),
    ];
    return [
      for (final j in applyLayout(
        jobs,
        (j) => j.$1,
        MangaBakaPref.homeLayout.value,
      ))
        j.$2,
    ];
  }

  List<SectionJob> browseJobsFor(MediaType type) => [
    for (final section in applyLayout(
      mangaBakaSectionsFor(type),
      (s) => s.title,
      MangaBakaPref.feedLayout.value,
    ))
      () async => {section.title: await sectionPage(section)},
  ];

  @override
  List<SectionJob> browseJobs({required bool anime}) => anime
      ? const []
      : [
          for (final section in applyLayout(
            mangaBakaSections,
            (s) => s.title,
            MangaBakaPref.feedLayout.value,
          ))
            () async => {section.title: await sectionPage(section)},
        ];

  @override
  Future<Map<String, List<Media>>> getMediaLists({
    required bool anime,
    int? userId,
    String? sortOrder,
  }) async {
    if (anime) return {};
    final all = await library();
    final names = {
      'CURRENT': getString.reading,
      'PLANNING': getString.planning,
      'COMPLETED': getString.completed,
      'PAUSED': getString.paused,
      'DROPPED': getString.dropped,
      'REPEATING': getString.rereading,
    };
    final out = <String, List<Media>>{};
    for (final entry in names.entries) {
      final items = [
        for (final m in all)
          if (m.userStatus == entry.key) m,
      ];
      if (items.isNotEmpty) out[entry.value] = items;
    }
    if (all.isNotEmpty) out['All'] = all;
    return out;
  }

  @override
  Future<List<Media>> getCalendarData() async => const [];

  @override
  Future<bool> getGenresAndTags() async {
    if (loadCustomData<Map<String, dynamic>>(_genreKey) != null) return true;
    try {
      final body = await client.get('/genres', cache: const Duration(days: 1));
      final slugs = {
        for (final g in (body['data'] as List?) ?? const [])
          if (g is Map && g['value'] != null) '${g['label']}': '${g['value']}',
      };
      if (slugs.isNotEmpty) saveCustomData(_genreKey, slugs);
    } catch (_) {}
    return true;
  }

  @override
  Future<SearchResults?> search(SearchResults? results) async {
    if (results == null) return null;
    if (results.type != SearchType.MANGA && results.type != SearchType.NOVEL) {
      return results
        ..results = const []
        ..hasNextPage = false;
    }
    final text = results.search?.trim() ?? '';
    final slugs = mangaBakaGenreSlugs();
    final genre = [
      for (final g in results.genres ?? const <String>[])
        if (slugs[g] != null) slugs[g]!,
    ].firstOrNull;
    final status = results.status == null
        ? null
        : _searchStatus(results.status!);
    final type = results.type == SearchType.NOVEL
        ? 'novel'
        : results.format?.toLowerCase().replaceAll(' ', '');
    final limit = (results.perPage ?? mangaBakaPageSize).clamp(1, 50);
    final body = await client.get(
      '/series/search',
      query: {
        'q': ?(text.isEmpty ? null : text),
        'sort_by': ?_sorts[results.sort],
        'type': ?type,
        'status': ?status,
        'genre': ?genre,
        'limit': '$limit',
        'page': '${results.page ?? 1}',
      },
      multi: results.isAdult == true ? const {} : _nsfwFilter,
      cache: const Duration(minutes: 5),
    );
    return results
      ..results = _media(body)
      ..hasNextPage = (body['pagination'] as Map?)?['next'] != null;
  }
}

(List<Map<String, dynamic>>, String?) _parseLibraryRows(String body) {
  final json = jsonDecode(body) as Map<String, dynamic>;
  return (
    [
      for (final e in (json['data'] as List?) ?? const [])
        if (e is Map) e.cast<String, dynamic>(),
    ],
    (json['pagination'] as Map?)?['next'] as String?,
  );
}

({List<Media> media, int scale, int chapters}) _mapLibrary(
  List<Map<String, dynamic>> rows,
) {
  final scale = mangaBakaRatingScale(rows);
  final out = <Media>[];
  var chapters = 0;
  for (final e in rows) {
    final series = e['Series'] ?? e['series'];
    if (series is! Map) continue;
    final media = mapMangaBakaSeries(series.cast<String, dynamic>());
    applyMangaBakaEntry(media, e, scale);
    chapters += media.userProgress ?? 0;
    out.add(media);
  }
  return (media: out, scale: scale, chapters: chapters);
}
