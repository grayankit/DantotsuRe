import 'package:dartotsu/Api/Services/Simkl/Data/Browse.dart';
import 'package:dartotsu/Api/Services/Simkl/Data/Mapper.dart';
import 'package:dartotsu/Core/Preferences/PrefBackup.dart';
import 'package:dartotsu/Core/Services/Api/LibrarySearch.dart';
import 'package:dartotsu/Core/Services/Model/Media.dart';
import 'package:dartotsu/Model/SearchResults.dart';
import 'package:dartotsu/Widgets/Components/SheetTile.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('simklBrowsePath', () {
    test('is null without any filter', () {
      expect(simklBrowsePath(SimklKind.anime, SearchResults()), isNull);
    });

    test('anime keeps genre, format, year and sort', () {
      final q = SearchResults(
        genres: ['Slice of Life'],
        format: 'OVA',
        seasonYear: 2021,
        sort: 'SCORE_DESC',
      );
      expect(
        simklBrowsePath(SimklKind.anime, q),
        '/anime/genres/slice-of-life/ovas/all/2021/rank',
      );
    });

    test('tv and movies take a country segment', () {
      final q = SearchResults(genres: ['Drama'], countryOfOrigin: 'KR');
      expect(
        simklBrowsePath(SimklKind.tv, q),
        '/tv/genres/drama/all/kr/all/all/popular-this-month',
      );
      expect(
        simklBrowsePath(SimklKind.movies, q),
        '/movies/genres/drama/movies/kr/all/popular-this-month',
      );
    });
  });

  group('searchLibrary', searchLibraryTests);

  group('groupedRadius', () {
    test('a single tile is rounded on every corner', () {
      expect(groupedRadius(0, 1), const BorderRadius.all(Radius.circular(20)));
    });

    test('first, middle and last tiles of a group', () {
      expect(
        groupedRadius(0, 3),
        const BorderRadius.vertical(
          top: Radius.circular(20),
          bottom: Radius.circular(6),
        ),
      );
      expect(groupedRadius(1, 3), const BorderRadius.all(Radius.circular(6)));
      expect(
        groupedRadius(2, 3),
        const BorderRadius.vertical(
          top: Radius.circular(6),
          bottom: Radius.circular(20),
        ),
      );
    });
  });

  group('PrefBackup.isInternal', () {
    test('schema and migration markers are never backed up', () {
      expect(PrefBackup.isInternal('OTHER/__prefSchemaVersion'), isTrue);
      expect(PrefBackup.isInternal('OTHER/__cachesMoved'), isTrue);
    });

    test('ordinary keys are kept', () {
      expect(PrefBackup.isInternal('COMMON/proxyUrl'), isFalse);
      expect(PrefBackup.isInternal('OTHER/media/anilist/1'), isFalse);
      expect(PrefBackup.isInternal('verifyTls'), isFalse);
    });
  });
}

void searchLibraryTests() {
  Media item(String name, {List<String> genres = const [], String? format}) =>
      Media(
        id: name,
        name: name,
        nameRomaji: name,
        genres: genres,
        format: format,
        status: 'FINISHED',
        shareLink: '',
      );

  final library = [
    item('Frieren', genres: ['Fantasy', 'Adventure'], format: 'TV'),
    item('Berserk', genres: ['Fantasy', 'Horror'], format: 'MANGA'),
    item('Spy x Family', genres: ['Comedy'], format: 'TV'),
  ];

  test('matches by title and by every selected genre', () {
    final byTitle = searchLibrary(library, SearchResults(search: 'fri'));
    expect(byTitle.results!.map((m) => m.id), ['Frieren']);

    final byGenre = searchLibrary(
      library,
      SearchResults(genres: ['Fantasy'], excludedGenres: ['Horror']),
    );
    expect(byGenre.results!.map((m) => m.id), ['Frieren']);
  });

  test('filters by format and pages the result', () {
    final tv = searchLibrary(library, SearchResults(format: 'tv', perPage: 1));
    expect(tv.results!.map((m) => m.id), ['Frieren']);
    expect(tv.hasNextPage, isTrue);

    final second = searchLibrary(
      library,
      SearchResults(format: 'TV', perPage: 1, page: 2),
    );
    expect(second.results!.map((m) => m.id), ['Spy x Family']);
    expect(second.hasNextPage, isFalse);
  });
}
