import 'package:dartotsu/Core/Services/Api/AniTrendz.dart';
import 'package:dartotsu/Core/Services/Api/AnimeThemes.dart';
import 'package:dartotsu/Core/Services/Api/MangaUpdates.dart';
import 'package:dartotsu/Core/Services/Api/SauceNao.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parseAnimeThemes orders openings first and picks the best video', () {
    final result = parseAnimeThemes({
      'anime': [
        {
          'name': 'Cowboy Bebop',
          'slug': 'cowboy_bebop',
          'animethemes': [
            {
              'type': 'ED',
              'slug': 'ED1',
              'song': {'title': 'The Real Folk Blues', 'artists': []},
              'animethemeentries': [
                {
                  'episodes': '1-25',
                  'videos': [
                    {
                      'link': 'https://v/ed.webm',
                      'resolution': 720,
                      'nc': false,
                    },
                  ],
                },
              ],
            },
            {
              'type': 'OP',
              'slug': 'OP1',
              'song': {
                'title': 'Tank!',
                'artists': [
                  {'name': 'Seatbelts'},
                ],
              },
              'animethemeentries': [
                {
                  'episodes': '1-25',
                  'videos': [
                    {
                      'link': 'https://v/a.webm',
                      'resolution': 720,
                      'nc': false,
                    },
                    {
                      'link': 'https://v/b.webm',
                      'resolution': 1080,
                      'nc': true,
                      'audio': {'link': 'https://a/b.ogg'},
                    },
                  ],
                },
              ],
            },
          ],
        },
      ],
    })!;
    expect(result.page, 'https://animethemes.moe/anime/cowboy_bebop');
    expect(result.themes.first.slug, 'OP1');
    expect(result.themes.first.artists, ['Seatbelts']);
    expect(result.themes.first.best!.link, 'https://v/b.webm');
    expect(result.themes.first.best!.label, '1080p · NC');
    expect(result.themes.first.videos.first.audio, 'https://a/b.ogg');
    expect(parseAnimeThemes({'anime': []}), isNull);
  });

  test('parseTrendz sorts entries and reports movement', () {
    final week = parseTrendz([
      {
        'name': 'Top Anime',
        'week': '3',
        'season': 'fall',
        'votes': 10,
        'choices': [
          {
            'position': 2,
            'previously': 5,
            'name': 'B',
            'peak': 2,
            'weeksAtTopTen': 4,
          },
          {
            'position': 1,
            'previously': 0,
            'name': 'A',
            'peak': 1,
            'weeksAtTopTen': 1,
          },
        ],
      },
    ])!;
    expect(week.entries.first.name, 'A');
    expect(week.entries.first.isNew, isTrue);
    expect(week.entries.last.change, 3);
    expect(parseTrendz([]), isNull);
  });

  test('parseMuSeries and parseMuRelease read the API shapes', () {
    final series = parseMuSeries({
      'series_id': 5,
      'title': 'Berserk',
      'url': 'https://mu/berserk',
      'year': '1989',
      'bayesian_rating': 8.98,
      'rating_votes': 3730,
      'latest_chapter': 386,
      'status': '43 Volumes (Ongoing)\n\nmore',
      'licensed': true,
      'genres': [
        {'genre': 'Action'},
      ],
      'publishers': [
        {'publisher_name': 'Hakusensha'},
      ],
    });
    expect(series.status, '43 Volumes (Ongoing)');
    expect(series.genres, ['Action']);
    expect(series.publishers, ['Hakusensha']);
    final release = parseMuRelease({
      'title': 'Berserk',
      'chapter': '386',
      'volume': null,
      'groups': [
        {'name': 'Evil Genius', 'url': 'https://mu/g'},
      ],
      'release_date': '2026-07-09',
    });
    expect(release.number, 'Ch 386');
    expect(release.groups.single.name, 'Evil Genius');
  });

  test('parseSauceHit reads titles, creators and similarity', () {
    final hit = parseSauceHit({
      'header': {
        'similarity': '91.4',
        'thumbnail': 'https://t/x.jpg',
        'index_name': 'Index #37: MangaDex - x.jpg',
      },
      'data': {
        'ext_urls': ['https://mangadex.org/chapter/1'],
        'title': 'Some Manga',
        'author': 'Someone',
        'part': 'Chapter 3',
      },
    })!;
    expect(hit.similarity, closeTo(91.4, 0.01));
    expect(hit.title, 'Some Manga');
    expect(hit.creator, 'Someone');
    expect(hit.part, 'Chapter 3');
    expect(hit.link, 'https://mangadex.org/chapter/1');
    expect(hit.low, isFalse);
    expect(parseSauceHit({'header': {}, 'data': {}}), isNull);
  });
}
