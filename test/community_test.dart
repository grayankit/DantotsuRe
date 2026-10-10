import 'package:dartotsu/Core/Comments/CommentModels.dart';
import 'package:dartotsu/Core/Services/Api/TraceMoe.dart';
import 'package:dartotsu/Screen/Comments/CommentColors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('comments', () {
    test('parses a comment with numeric booleans', () {
      final c = Comment.fromJson({
        'comment_id': 7,
        'user_id': '42',
        'media_id': 1,
        'parent_comment_id': null,
        'content': 'hi',
        'timestamp': '2026-01-01T00:00:00.000Z',
        'deleted': 0,
        'tag': 3,
        'upvotes': 5,
        'downvotes': 2,
        'user_vote_type': 1,
        'username': 'a',
        'is_mod': 1,
        'is_admin': 0,
        'reply_count': 4,
        'total_votes': 9,
      });
      expect(c.id, 7);
      expect(c.score, 3);
      expect(c.isMod, isTrue);
      expect(c.isAdmin, isFalse);
      expect(c.deleted, isFalse);
      expect(c.vote, 1);
      expect(c.replyCount, 4);
    });

    test('parses a page and notices', () {
      final page = CommentPage.fromJson({
        'comments': [
          {
            'comment_id': 1,
            'user_id': 'u',
            'media_id': 2,
            'content': 'x',
            'timestamp': '',
            'username': 'n',
          },
        ],
        'totalPages': 3,
      });
      expect(page.comments, hasLength(1));
      expect(page.totalPages, 3);
      final n = CommentNotice.fromJson({
        'notification_id': 4,
        'media_id': 1,
        'comment_id': 2,
        'username': 'z',
        'type': 3,
      });
      expect(n.isAnnouncement, isTrue);
      expect(n.isGlobal, isTrue);
      expect(n.isReply, isFalse);
    });

    test('level grows with the square root of votes', () {
      expect(commentLevel(-5), 0);
      expect(commentLevel(0), 0);
      expect(commentLevel(80), 10);
    });

    test('level colour keeps contrast on both backgrounds', () {
      for (final bg in [Colors.black, Colors.white]) {
        for (final votes in [0, 10, 80, 3000]) {
          final c = commentLevelColor(votes, bg);
          final hi = c.computeLuminance() > bg.computeLuminance()
              ? c.computeLuminance()
              : bg.computeLuminance();
          final lo = c.computeLuminance() > bg.computeLuminance()
              ? bg.computeLuminance()
              : c.computeLuminance();
          expect((hi + 0.05) / (lo + 0.05), greaterThanOrEqualTo(4.5));
        }
      }
    });
  });

  group('trace.moe', () {
    test('parses a hit with anilist info', () {
      final hit = TraceHit.fromJson({
        'anilist': {
          'id': 21,
          'idMal': 21,
          'isAdult': false,
          'title': {'romaji': 'One Piece', 'native': 'ワンピース'},
        },
        'episode': [1, 2],
        'from': 125.5,
        'to': 130,
        'similarity': 0.93,
        'image': 'i',
        'video': 'v',
      });
      expect(hit.anilistId, 21);
      expect(hit.title, 'One Piece');
      expect(hit.episode, '1');
      expect(hit.time, '2:06');
    });

    test('accepts a bare anilist id', () {
      final hit = TraceHit.fromJson({'anilist': 5, 'filename': 'f.mkv'});
      expect(hit.anilistId, 5);
      expect(hit.title, 'f.mkv');
    });
  });
}
