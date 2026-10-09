import 'dart:async';

import '../../../../Core/Services/MediaService.dart';
import '../../../../Utils/Lru.dart';
import '../../../../Core/Services/Model/Author.dart';
import '../../../../Core/Services/Model/Character.dart';
import '../../../../Core/Services/Model/Media.dart';
import '../Auth.dart';
import '../Client.dart';
import '../Data/Mapper.dart';
import '../Prefs.dart';

const _pageSize = 20;

class KitsuSocialView extends SocialScreenView {
  KitsuSocialView(super.service);

  KitsuClient get _client => kitsuAuth.client;

  final Map<String, String> _cursors = {};

  @override
  bool get hasGlobalFeed => true;

  @override
  String? profileUrl(String name) => 'https://kitsu.app/users/$name';

  static final _link = RegExp(
    r'kitsu\.(?:app|io)/(anime|manga|users|posts)/([^/?#\s]+)',
  );

  @override
  AppLink? parseLink(String url) {
    final m = _link.firstMatch(url);
    if (m == null) return null;
    final kind = switch (m.group(1)) {
      'anime' => AppLinkKind.anime,
      'manga' => AppLinkKind.manga,
      'users' => AppLinkKind.user,
      _ => AppLinkKind.activity,
    };
    return AppLink(kind, m.group(2)!);
  }

  UserBrief _brief(Map<String, dynamic>? node) {
    if (node == null) return UserBrief(id: '0', name: '');
    final a = attrs(node);
    return UserBrief(
      id: '${node['id']}',
      name: a['name'] as String? ?? '',
      avatar: kitsuImage(a['avatar'], const ['large', 'medium', 'original']),
      banner: kitsuImage(a['coverImage'], const ['large', 'original']),
    );
  }

  Future<SocialUser?> _userNode(String? id, String? name) async {
    Map<String, dynamic> body;
    if (id != null) {
      body = await _client.get('/users/$id');
    } else if (name != null) {
      body = await _client.get(
        '/users',
        query: {'filter[name]': name, 'page[limit]': '1'},
      );
      if (JsonApi(body).data.isEmpty) {
        body = await _client.get(
          '/users',
          query: {'filter[slug]': name, 'page[limit]': '1'},
        );
      }
    } else {
      return null;
    }
    final doc = JsonApi(body);
    if (doc.data.isEmpty) return null;
    final node = doc.data.first;
    final a = attrs(node);
    final brief = _brief(node);
    final (stats, following) = await (
      _consumed(brief.id),
      _isFollowing(brief.id),
    ).wait;
    final slug = a['slug'] as String? ?? brief.name;
    return SocialUser(
      id: brief.id,
      name: brief.name,
      avatar: brief.avatar,
      banner: brief.banner,
      about: a['about'] as String?,
      siteUrl: 'https://kitsu.app/users/$slug',
      isFollowing: following,
      followers: (a['followersCount'] as num?)?.toInt() ?? 0,
      following: (a['followingCount'] as num?)?.toInt() ?? 0,
      animeCount: stats.anime.count,
      mangaCount: stats.manga.count,
      episodesWatched: stats.anime.episodesWatched,
      minutesWatched: stats.anime.minutesWatched,
      chaptersRead: stats.manga.chaptersRead,
    );
  }

  @override
  Future<SocialUser?> profile({String? id, String? name}) =>
      _userNode(id, name);

  Future<bool> _isFollowing(String userId) async {
    final me = currentUserId;
    if (me == null || me == userId || !service.isLoggedIn) return false;
    try {
      final res = await _client.get(
        '/follows',
        query: {
          'filter[follower]': me,
          'filter[followed]': userId,
          'page[limit]': '1',
          'fields[follows]': 'createdAt',
        },
      );
      return JsonApi(res).data.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  final _statsCache =
      Lru<String, (DateTime, Future<Map<String, Map<String, dynamic>>>)>(8);

  Future<Map<String, Map<String, dynamic>>> _statsByKind(String userId) {
    final hit = _statsCache[userId];
    if (hit != null &&
        DateTime.now().difference(hit.$1) < const Duration(minutes: 2)) {
      return hit.$2;
    }
    final future = _loadStats(userId);
    _statsCache[userId] = (DateTime.now(), future);
    unawaited(
      future.then<void>((_) {}, onError: (_) => _statsCache.remove(userId)),
    );
    return future;
  }

  Future<Map<String, Map<String, dynamic>>> _loadStats(String userId) async {
    final res = await _client.get(
      '/stats',
      query: {'filter[userId]': userId, 'page[limit]': '20'},
    );
    return {
      for (final n in JsonApi(res).data)
        if (attrs(n)['kind'] is String)
          attrs(n)['kind'] as String:
              (attrs(n)['statsData'] as Map?)?.cast<String, dynamic>() ??
              const {},
    };
  }

  UserStatSet _set(
    Map<String, dynamic>? consumed,
    Map<String, dynamic>? breakdown, {
    required bool anime,
  }) {
    final units = (consumed?['units'] as num?)?.toInt() ?? 0;
    final categories = <StatEntry>[
      for (final e
          in ((breakdown?['categories'] as Map?) ?? const {}).entries.toList()
            ..sort(
              (a, b) =>
                  ((b.value as num?) ?? 0).compareTo((a.value as num?) ?? 0),
            ))
        StatEntry(label: '${e.key}', count: (e.value as num?)?.toInt() ?? 0),
    ];
    return UserStatSet(
      count: (consumed?['media'] as num?)?.toInt() ?? 0,
      minutesWatched: anime
          ? ((consumed?['time'] as num?)?.toInt() ?? 0) ~/ 60
          : 0,
      episodesWatched: anime ? units : 0,
      chaptersRead: anime ? 0 : units,
      categories: categories.isEmpty
          ? const []
          : [StatCategory('genres', 'Genres', categories)],
    );
  }

  Future<UserStats> _consumed(String userId) async {
    try {
      final s = await _statsByKind(userId);
      return UserStats(
        anime: _set(
          s['anime-amount-consumed'],
          s['anime-category-breakdown'],
          anime: true,
        ),
        manga: _set(
          s['manga-amount-consumed'],
          s['manga-category-breakdown'],
          anime: false,
        ),
      );
    } catch (_) {
      return const UserStats(anime: UserStatSet(), manga: UserStatSet());
    }
  }

  @override
  Future<UserStats?> stats(String userId) => _consumed(userId);

  @override
  Future<List<ActivityDay>> activityHistory(String userId) async {
    final s = await _statsByKind(userId);
    final days = <String, int>{};
    for (final kind in const [
      'anime-activity-history',
      'manga-activity-history',
    ]) {
      final map = (s[kind]?['days'] as Map?) ?? const {};
      for (final e in map.entries) {
        final units = ((e.value as Map?)?['units'] as num?)?.toInt() ?? 0;
        days['${e.key}'] = (days['${e.key}'] ?? 0) + units;
      }
    }
    int level(int n) => n <= 0
        ? 0
        : n <= 1
        ? 1
        : n <= 3
        ? 2
        : n <= 6
        ? 3
        : 4;
    return [
      for (final e in days.entries)
        if (DateTime.tryParse(e.key) case final d?)
          ActivityDay(d, e.value, level(e.value)),
    ]..sort((a, b) => a.date.compareTo(b.date));
  }

  @override
  Future<SocialFavourites> favourites(String userId) async {
    final res = await _client.get(
      '/favorites',
      query: {
        'filter[userId]': userId,
        'include': 'item',
        'sort': 'favRank',
        'page[limit]': '20',
      },
    );
    final doc = JsonApi(res);
    final anime = <Media>[];
    final manga = <Media>[];
    final characters = <Character>[];
    final staff = <Author>[];
    for (final fav in doc.data) {
      final item = doc.one(fav, 'item');
      if (item == null) continue;
      final a = attrs(item);
      switch (item['type']) {
        case 'anime':
          anime.add(mapKitsuMedia(item, doc: doc));
        case 'manga':
          manga.add(mapKitsuMedia(item, doc: doc));
        case 'characters':
          characters.add(
            Character(
              id: '${item['id']}',
              name: a['name'] as String? ?? a['canonicalName'] as String?,
              image: kitsuImage(a['image'], const ['original', 'large']),
            ),
          );
        case 'people':
          staff.add(
            Author(
              id: '${item['id']}',
              name: a['name'] as String?,
              image: kitsuImage(a['image'], const ['original', 'large']),
            ),
          );
      }
    }
    return SocialFavourites(
      anime: anime,
      manga: manga,
      characters: characters,
      staff: staff,
    );
  }

  @override
  Future<List<Media>> favouriteMedia(
    String userId, {
    required bool anime,
    int page = 1,
  }) async {
    final res = await _client.get(
      '/favorites',
      query: {
        'filter[userId]': userId,
        'filter[itemType]': anime ? 'Anime' : 'Manga',
        'include': 'item',
        'sort': 'favRank',
        'page[limit]': '$_pageSize',
        'page[offset]': '${(page - 1) * _pageSize}',
      },
    );
    final doc = JsonApi(res);
    return [
      for (final fav in doc.data)
        if (doc.one(fav, 'item') case final item?)
          mapKitsuMedia(item, doc: doc),
    ];
  }

  @override
  Future<UserPage> follows(
    String userId, {
    required bool followers,
    int page = 1,
  }) async {
    final res = await _client.get(
      '/follows',
      query: {
        'filter[${followers ? 'followed' : 'follower'}]': userId,
        'include': followers ? 'follower' : 'followed',
        'page[limit]': '$_pageSize',
        'page[offset]': '${(page - 1) * _pageSize}',
      },
    );
    final doc = JsonApi(res);
    return UserPage([
      for (final f in doc.data)
        if (doc.one(f, followers ? 'follower' : 'followed') case final u?)
          _brief(u),
    ], hasNext: doc.next != null);
  }

  @override
  Future<bool?> toggleFollow(String userId) async {
    final me = currentUserId;
    if (me == null) return null;
    try {
      final res = await _client.get(
        '/follows',
        query: {
          'filter[follower]': me,
          'filter[followed]': userId,
          'page[limit]': '1',
        },
      );
      final existing = JsonApi(res).data;
      if (existing.isNotEmpty) {
        await _client.delete('/follows/${existing.first['id']}');
        return false;
      }
      await _client.post('/follows', {
        'data': {
          'type': 'follows',
          'relationships': {
            'follower': {
              'data': {'type': 'users', 'id': me},
            },
            'followed': {
              'data': {'type': 'users', 'id': userId},
            },
          },
        },
      });
      return true;
    } catch (_) {
      return null;
    }
  }

  Activity? _post(Map<String, dynamic> node, JsonApi doc, Set<String> liked) {
    final a = attrs(node);
    if (a['deletedAt'] != null) return null;
    if (a['nsfw'] == true && KitsuPref.hideNsfw.value) return null;
    final mediaNode = doc.one(node, 'media');
    final id = '${node['id']}';
    return Activity(
      id: id,
      kind: ActivityKind.text,
      user: _brief(doc.one(node, 'user')),
      text: a['content'] as String?,
      html: a['contentFormatted'] as String?,
      media: mediaNode == null ? null : mapKitsuMedia(mediaNode, doc: doc),
      mediaType: mediaNode?['type'] == 'manga' ? 'MANGA' : 'ANIME',
      replyCount: (a['commentsCount'] as num?)?.toInt() ?? 0,
      likeCount: (a['postLikesCount'] as num?)?.toInt() ?? 0,
      isLiked: liked.contains(id),
      isLocked: a['lockedAt'] != null,
      createdAt: kitsuEpoch(a['createdAt']) ?? 0,
      siteUrl: 'https://kitsu.app/posts/$id',
    );
  }

  Future<Set<String>> _likedPosts(List<String> ids) async {
    final me = currentUserId;
    if (me == null || ids.isEmpty) return {};
    try {
      final res = await _client.get(
        '/post-likes',
        query: {
          'filter[postId]': ids.join(','),
          'filter[userId]': me,
          'include': 'post',
          'fields[posts]': 'id',
          'page[limit]': '$_pageSize',
        },
      );
      final doc = JsonApi(res);
      return {
        for (final l in doc.data)
          if (doc.one(l, 'post') case final p?) '${p['id']}',
      };
    } catch (_) {
      return {};
    }
  }

  Future<List<Activity>> _postsById(List<String> ids) async {
    if (ids.isEmpty) return [];
    final (res, liked) = await (
      _client.get(
        '/posts',
        query: {
          'filter[id]': ids.join(','),
          'include': 'user,media',
          'page[limit]': '$_pageSize',
        },
      ),
      _likedPosts(ids),
    ).wait;
    final doc = JsonApi(res);
    final posts = [for (final n in doc.data) ?_post(n, doc, liked)];
    final byId = {for (final a in posts) a.id: a};
    return [for (final id in ids) ?byId[id]];
  }

  Future<ActivityPage> _feed(String feed, String key, int page) async {
    final cursor = page > 1 ? _cursors['$key|$page'] : null;
    final res = await _client.get(
      '/feeds/$feed',
      query: {
        'page[limit]': '$_pageSize',
        'page[cursor]': ?cursor,
        'include': 'activities',
      },
    );
    final doc = JsonApi(res);
    final next = doc.next == null
        ? null
        : Uri.tryParse(doc.next!)?.queryParameters['page[cursor]'];
    if (next != null) _cursors['$key|${page + 1}'] = next;
    final ids = <String>[
      for (final group in doc.data)
        for (final act in doc.many(group, 'activities'))
          if ('${attrs(act)['foreignId']}'.startsWith('Post:'))
            '${attrs(act)['foreignId']}'.substring(5),
    ];
    return ActivityPage(await _postsById(ids), hasNext: next != null);
  }

  @override
  Future<ActivityPage> activities(
    ActivityScope scope, {
    String? userId,
    String? activityId,
    int page = 1,
  }) async {
    switch (scope) {
      case ActivityScope.single:
        if (activityId == null) return const ActivityPage([]);
        return ActivityPage(await _postsById([activityId]));
      case ActivityScope.user:
        if (userId == null) return const ActivityPage([]);
        return _feed('user/$userId', 'user$userId', page);
      case ActivityScope.following:
        final me = currentUserId;
        if (me == null) return const ActivityPage([]);
        return _feed('timeline/$me', 'timeline', page);
      case ActivityScope.global:
        final res = await _client.get(
          '/posts',
          query: {
            'sort': '-createdAt',
            'include': 'user,media',
            'page[limit]': '$_pageSize',
            'page[offset]': '${(page - 1) * _pageSize}',
          },
        );
        final doc = JsonApi(res);
        final liked = await _likedPosts([
          for (final n in doc.data) '${n['id']}',
        ]);
        return ActivityPage([
          for (final n in doc.data) ?_post(n, doc, liked),
        ], hasNext: doc.next != null);
      case ActivityScope.inbox:
      case ActivityScope.sent:
        return const ActivityPage([]);
    }
  }

  @override
  Future<ReplyPage> replies(String activityId, {int page = 1}) async {
    final res = await _client.get(
      '/comments',
      query: {
        'filter[postId]': activityId,
        'include': 'user',
        'sort': 'createdAt',
        'page[limit]': '$_pageSize',
        'page[offset]': '${(page - 1) * _pageSize}',
      },
    );
    final doc = JsonApi(res);
    return ReplyPage([
      for (final c in doc.data)
        if (attrs(c)['deletedAt'] == null)
          ActivityReply(
            id: '${c['id']}',
            activityId: activityId,
            user: _brief(doc.one(c, 'user')),
            text: attrs(c)['content'] as String? ?? '',
            html: attrs(c)['contentFormatted'] as String?,
            likeCount: (attrs(c)['likesCount'] as num?)?.toInt() ?? 0,
            createdAt: kitsuEpoch(attrs(c)['createdAt']) ?? 0,
          ),
    ], hasNext: doc.next != null);
  }

  @override
  Future<bool> toggleLike(String id, {bool reply = false}) async {
    final me = currentUserId;
    if (me == null) return false;
    final collection = reply ? 'comment-likes' : 'post-likes';
    final target = reply ? 'comment' : 'post';
    try {
      final res = await _client.get(
        '/$collection',
        query: {
          'filter[${target}Id]': id,
          'filter[userId]': me,
          'page[limit]': '1',
        },
      );
      final existing = JsonApi(res).data;
      if (existing.isNotEmpty) {
        await _client.delete('/$collection/${existing.first['id']}');
        return true;
      }
      await _client.post('/$collection', {
        'data': {
          'type': reply ? 'commentLikes' : 'postLikes',
          'relationships': {
            'user': {
              'data': {'type': 'users', 'id': me},
            },
            target: {
              'data': {'type': reply ? 'comments' : 'posts', 'id': id},
            },
          },
        },
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> postActivity(String text, {String? edit}) async {
    final me = currentUserId;
    if (me == null) return false;
    try {
      if (edit != null) {
        await _client.patch('/posts/$edit', {
          'data': {
            'type': 'posts',
            'id': edit,
            'attributes': {'content': text},
          },
        });
      } else {
        await _client.post('/posts', {
          'data': {
            'type': 'posts',
            'attributes': {'content': text},
            'relationships': {
              'user': {
                'data': {'type': 'users', 'id': me},
              },
            },
          },
        });
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> postReply(String activityId, String text, {String? edit}) async {
    final me = currentUserId;
    if (me == null) return false;
    try {
      if (edit != null) {
        await _client.patch('/comments/$edit', {
          'data': {
            'type': 'comments',
            'id': edit,
            'attributes': {'content': text},
          },
        });
      } else {
        await _client.post('/comments', {
          'data': {
            'type': 'comments',
            'attributes': {'content': text},
            'relationships': {
              'user': {
                'data': {'type': 'users', 'id': me},
              },
              'post': {
                'data': {'type': 'posts', 'id': activityId},
              },
            },
          },
        });
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> deleteActivity(String id) async {
    try {
      await _client.delete('/posts/$id');
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> deleteReply(String id) async {
    try {
      await _client.delete('/comments/$id');
      return true;
    } catch (_) {
      return false;
    }
  }
}
