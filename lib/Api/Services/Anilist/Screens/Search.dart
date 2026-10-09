import '../../../../Core/Preferences/PrefManager.dart';
import '../../../../Core/Services/MediaService.dart';
import '../../../../Core/Services/Model/Author.dart';
import '../../../../Core/Services/Model/Character.dart';
import '../../../../Core/Services/Model/Studio.dart';
import '../../../../Core/Services/Model/User.dart';
import '../../../../Model/SearchResults.dart';
import '../../../../Core/ThemeManager/LanguageSwitcher.dart';
import '../Auth.dart';

Map<String, String> get _anilistSorts => {
  'SCORE_DESC': getString.sortTopRated,
  'POPULARITY_DESC': getString.sortMostPopular,
  'TRENDING_DESC': getString.sortTrending,
  'START_DATE_DESC': getString.sortNewest,
  'TITLE_ROMAJI': getString.sortAz,
  'FAVOURITES_DESC': getString.sortMostFavourited,
};

class AnilistSearchView extends SearchScreenView {
  @override
  Future<SearchResults?> search(SearchResults query) =>
      anilistAuth.queries.search(query);

  @override
  Future<void> prepare() async {
    try {
      await anilistAuth.queries.getGenresAndTags();
    } catch (_) {}
  }

  @override
  List<MediaType> get types => const [MediaType.anime, MediaType.manga];

  @override
  List<SearchType> get searchTypes => const [
    SearchType.ANIME,
    SearchType.MANGA,
    SearchType.CHARACTER,
    SearchType.STAFF,
    SearchType.STUDIO,
    SearchType.USER,
  ];

  @override
  String? entityUrl(SearchType type, Object entity) {
    const base = 'https://anilist.co';
    return switch (entity) {
      Character c => '$base/character/${c.id}',
      Author a => '$base/staff/${a.id}',
      Studio s => '$base/studio/${s.id}',
      User u => '$base/user/${u.name}',
      _ => null,
    };
  }

  @override
  SearchFilterSpec filters(MediaType type) {
    final anime = type.isVideo;
    final genres =
        loadCustomData<List<String>>('anilist_genres') ?? const <String>[];
    final tags =
        loadCustomData<List<String>>('anilist_tags_nonadult') ??
        const <String>[];
    return SearchFilterSpec(
      sorts: _anilistSorts,
      formats: anime
          ? const ['TV', 'TV SHORT', 'MOVIE', 'SPECIAL', 'OVA', 'ONA', 'MUSIC']
          : const ['MANGA', 'NOVEL', 'ONE SHOT'],
      statuses: const [
        'RELEASING',
        'FINISHED',
        'NOT YET RELEASED',
        'CANCELLED',
        'HIATUS',
      ],
      sources: const [
        'ORIGINAL',
        'MANGA',
        'LIGHT NOVEL',
        'VISUAL NOVEL',
        'VIDEO GAME',
        'NOVEL',
        'WEB NOVEL',
        'OTHER',
      ],
      genres: genres,
      tags: tags,
      countries: {
        '': getString.anyCountry,
        'JP': 'Japan',
        'KR': 'Korea',
        'CN': 'China',
        'TW': 'Taiwan',
      },
      season: anime,
      year: true,
      adult: true,
      onList: anilistAuth.isLoggedIn,
    );
  }
}
