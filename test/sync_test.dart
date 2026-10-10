import 'package:dartotsu/Api/Services/Anilist/Sync.dart';
import 'package:dartotsu/Api/Services/Simkl/Sync.dart';
import 'package:dartotsu/Core/Services/Model/Date.dart';
import 'package:dartotsu/Core/Sync/SyncAdapter.dart';
import 'package:dartotsu/Core/Sync/SyncAhead.dart';
import 'package:dartotsu/Core/Sync/SyncBudget.dart';
import 'package:dartotsu/Core/Sync/SyncCompute.dart';
import 'package:dartotsu/Core/Sync/SyncIdIndex.dart';
import 'package:dartotsu/Core/Sync/SyncMemory.dart';
import 'package:dartotsu/Core/Sync/SyncModels.dart';
import 'package:dartotsu/Core/Sync/SyncPlanner.dart';
import 'package:flutter_test/flutter_test.dart';

class _Fake extends SyncAdapter {
  @override
  String get key => SyncKey.kitsu;
  @override
  bool supports({required bool anime}) => true;
  @override
  List<SyncLimit> get limits => const [];
  @override
  Future<List<SyncItem>> library({required bool anime}) async => const [];
  @override
  String? targetId(int native, {required bool anime}) => 'anime/$native';
  @override
  int? nativeId(String id) => null;
  @override
  Future<int> write(List<SyncOp> batch, {required bool anime}) async => 1;
}

SyncItem _main(
  int al,
  int mal, {
  String? status = 'CURRENT',
  int progress = 3,
}) => SyncItem(
  id: '$al',
  ids: {SyncKey.anilist: al, SyncKey.mal: mal},
  title: 'T$al',
  status: status,
  progress: progress,
  score: 80,
);

void main() {
  test('plan classifies synced, outdated, missing and unmapped', () {
    final index = SyncIdIndex([1, 10, 100, 0, 2, 20, 200, 0, 3, 30, 300, 0]);
    final main = expandItems(
      [_main(1, 10), _main(2, 20), _main(3, 30), _main(4, 40)],
      index,
      SyncKey.anilist,
    );
    final target = [
      const SyncItem(
        id: 'anime/100',
        ids: {SyncKey.kitsu: 100},
        title: 'a',
        status: 'CURRENT',
        progress: 3,
        score: 80,
      ),
      const SyncItem(
        id: 'anime/200',
        ids: {SyncKey.kitsu: 200},
        title: 'b',
        status: 'CURRENT',
        progress: 1,
        score: 80,
      ),
      const SyncItem(
        id: 'anime/999',
        ids: {SyncKey.kitsu: 999},
        title: 'c',
        status: 'CURRENT',
        progress: 1,
      ),
    ];
    final plan = planTarget(
      main: main,
      target: expandItems(target, index, SyncKey.kitsu),
      adapter: _Fake(),
      anime: true,
      onlyForward: true,
    );
    expect(plan.pairs.map((p) => p.state), [
      SyncStatus.synced,
      SyncStatus.outdated,
      SyncStatus.missing,
      SyncStatus.unmapped,
    ]);
    expect(plan.pairs[1].diffs, ['progress']);
    expect(plan.pairs[2].targetId, 'anime/300');
    expect(plan.onlyInTarget, 1);
  });

  test('a target that is ahead stays synced when only moving forward', () {
    final target = const SyncItem(
      id: 'anime/100',
      ids: {SyncKey.kitsu: 100},
      title: 'a',
      status: 'CURRENT',
      progress: 9,
      score: 80,
    );
    final main = [
      _main(1, 10).withIds({SyncKey.anilist: 1, SyncKey.kitsu: 100}),
    ];
    for (final forward in [true, false]) {
      final plan = planTarget(
        main: main,
        target: [target],
        adapter: _Fake(),
        anime: true,
        onlyForward: forward,
      );
      expect(
        plan.pairs.single.state,
        forward ? SyncStatus.synced : SyncStatus.outdated,
      );
    }
  });

  test('plan survives a json round trip', () {
    final main = _main(1, 10);
    final plan = SyncPlan(
      main: 'anilist',
      anime: true,
      mainCount: 1,
      targets: {
        'kitsu': SyncTargetPlan([
          SyncPair(
            main: main,
            targetId: 'anime/100',
            target: null,
            state: SyncStatus.missing,
            op: SyncOpState.failed,
            error: 'boom',
          ),
        ]),
        'mal': SyncTargetPlan([
          SyncPair(
            main: main,
            targetId: 'anime/10',
            target: main.asTarget('anime/10'),
            state: SyncStatus.synced,
          ),
        ]),
      },
    );
    final back = SyncPlan.fromJson(plan.toJson());
    expect(back.targets['kitsu']!.pairs.single.error, 'boom');
    expect(back.targets['kitsu']!.pairs.single.state, SyncStatus.missing);
    expect(back.targets['mal']!.pairs.single.target!.progress, 3);
    expect(
      identical(
        back.targets['kitsu']!.pairs.single.main,
        back.targets['mal']!.pairs.single.main,
      ),
      isTrue,
    );
  });

  test(
    'completed entries use the target total; dates and repeat are tracked',
    () {
      final main = SyncItem(
        id: '1',
        ids: {SyncKey.anilist: 1},
        title: 'a',
        status: 'COMPLETED',
        progress: 12,
        score: 80,
        repeat: 2,
        started: Date(year: 2020, month: 1, day: 5),
      );
      final target = const SyncItem(
        id: 'x',
        ids: {SyncKey.kitsu: 1},
        title: 'a',
        status: 'COMPLETED',
        progress: 13,
        score: 80,
        total: 13,
      );
      final pair = SyncPair(
        main: main,
        targetId: 'x',
        target: target,
        state: SyncStatus.synced,
        dates: true,
        repeat: true,
      );
      expect(pair.want.progress, 13);
      expect(pair.diffs, ['dates', 'repeat']);
      expect(
        SyncPair(
          main: main,
          targetId: 'x',
          target: target,
          state: SyncStatus.synced,
        ).diffs,
        isEmpty,
      );
    },
  );

  test(
    'manga without a native id is missing, not unmapped, when resolvable',
    () {
      final adapter = _Resolver();
      final main = [
        const SyncItem(
          id: '1',
          ids: {SyncKey.anilist: 1, SyncKey.mal: 2},
          title: 'Berserk',
          status: 'CURRENT',
        ),
      ];
      final plan = planTarget(
        main: main,
        target: const [],
        adapter: adapter,
        anime: false,
        onlyForward: true,
      );
      expect(plan.pairs.single.state, SyncStatus.missing);
      expect(plan.pairs.single.targetId, isNull);
    },
  );
  group('SyncBudget', () {
    final t0 = DateTime(2026, 1, 1, 12);
    const minute = SyncLimit(3, Duration(minutes: 1));

    test('waits until the oldest request leaves the window', () {
      final b = SyncBudget();
      for (var i = 0; i < 3; i++) {
        b.stamp('s', 1, now: t0.add(Duration(seconds: i * 10)));
      }
      final wait = b.waitFor(
        's',
        [minute],
        1,
        now: t0.add(const Duration(seconds: 30)),
      );
      expect(wait.inSeconds, inInclusiveRange(30, 31));
      expect(
        b.waitFor('s', [minute], 1, now: t0.add(const Duration(seconds: 61))),
        Duration.zero,
      );
    });

    test('every limit is honoured and the longest wait wins', () {
      final b = SyncBudget();
      b.stamp('s', 5, now: t0);
      const day = SyncLimit(5, Duration(days: 1));
      final wait = b.waitFor(
        's',
        [const SyncLimit(50, Duration(minutes: 1)), day],
        1,
        now: t0.add(const Duration(minutes: 5)),
      );
      expect(wait.inHours, greaterThanOrEqualTo(23));
      expect(b.usedIn('s', day, now: t0.add(const Duration(minutes: 5))), 5);
    });

    test('a batch that needs several requests counts them all', () {
      final b = SyncBudget();
      b.stamp('s', 2, now: t0);
      expect(b.waitFor('s', [minute], 1, now: t0), Duration.zero);
      expect(b.waitFor('s', [minute], 2, now: t0) > Duration.zero, isTrue);
    });

    test('repeated rate limits back off and success resets', () {
      final b = SyncBudget();
      b.hold('s', const Duration(seconds: 1), now: t0);
      final first = b.waitFor('s', const [], 1, now: t0);
      b.hold('s', const Duration(seconds: 1), now: t0);
      final second = b.waitFor('s', const [], 1, now: t0);
      expect(second > first, isTrue);
      b.succeeded('s');
      b.hold('s', const Duration(seconds: 1), now: t0);
      expect(b.waitFor('s', const [], 1, now: t0).inSeconds, first.inSeconds);
    });

    test('a long Retry-After is kept, a huge one is capped', () {
      final b = SyncBudget();
      b.hold('s', const Duration(minutes: 5), now: t0);
      expect(b.waitFor('s', const [], 1, now: t0).inMinutes, 5);
      b.hold('s', const Duration(hours: 5), now: t0);
      expect(b.waitFor('s', const [], 1, now: t0).inMinutes, 15);
    });

    test('old stamps are dropped after a day', () {
      final b = SyncBudget();
      b.stamp('s', 4, now: t0);
      b.stamp('s', 1, now: t0.add(const Duration(days: 2)));
      expect(b.stamps['s'], hasLength(1));
    });
  });

  group('SyncIdIndex', () {
    final index = SyncIdIndex([1, 10, 100, 1000, 2, 20, 0, 0, 3, 0, 300, 0]);

    test('fills every known id from whichever one is given', () {
      expect(index.expand({SyncKey.kitsu: 300}), {
        SyncKey.kitsu: 300,
        SyncKey.anilist: 3,
      });
      expect(
        index.expand({SyncKey.mal: 10}),
        containsPair(SyncKey.simkl, 1000),
      );
    });

    test('keeps ids it was given and ignores unknown ones', () {
      expect(index.expand({SyncKey.anilist: 99}), {SyncKey.anilist: 99});
      expect(
        index.expand({SyncKey.anilist: 2, SyncKey.mal: 77})[SyncKey.mal],
        77,
      );
    });

    test('prefers the pivot column when ids disagree', () {
      final out = index.expand({
        SyncKey.anilist: 1,
        SyncKey.mal: 20,
      }, prefer: SyncKey.mal);
      expect(out[SyncKey.anilist], 1);
      expect(out.containsKey(SyncKey.kitsu), isFalse);
    });
  });

  group('SyncMemory', () {
    test('remembers lookups and skips per service and type', () {
      final m = SyncMemory()
        ..remember('kitsu', false, 2, 77)
        ..setIgnored('kitsu', false, '5', true);
      expect(m.native('kitsu', false, 2), 77);
      expect(m.native('kitsu', true, 2), isNull);
      expect(m.isIgnored('kitsu', false, '5'), isTrue);
      expect(m.isIgnored('mal', false, '5'), isFalse);
      final back = SyncMemory.fromJson(m.toJson());
      expect(back.native('kitsu', false, 2), 77);
      expect(back.isIgnored('kitsu', false, '5'), isTrue);
      back.setIgnored('kitsu', false, '5', false);
      expect(back.isIgnored('kitsu', false, '5'), isFalse);
    });

    test('fingerprint changes with progress, not with order', () {
      final a = _main(1, 10);
      final b = _main(2, 20);
      expect(syncFingerprint([a, b]), syncFingerprint([b, a]));
      expect(
        syncFingerprint([a, b]),
        isNot(syncFingerprint([a, _main(2, 20, progress: 4)])),
      );
    });
  });

  test('skipped pairs are not pending', () {
    final pair = SyncPair(
      main: _main(1, 10),
      targetId: 'anime/1',
      target: null,
      state: SyncStatus.missing,
    );
    expect(pair.pending, isTrue);
    pair.op = SyncOpState.skipped;
    expect(pair.pending, isFalse);
    expect(
      SyncPlan.fromJson(
        SyncPlan(
          main: 'a',
          anime: true,
          mainCount: 1,
          targets: {
            't': SyncTargetPlan([pair]),
          },
        ).toJson(),
      ).targets['t']!.skipped,
      1,
    );
  });
  group('batch building', () {
    SyncOp op(
      String id, {
      required String status,
      int progress = 0,
      int score = 0,
      SyncItem? have,
      int repeat = 0,
    }) => SyncOp(
      SyncItem(
        id: 'x',
        ids: const {},
        title: 't',
        status: status,
        progress: progress,
        score: score,
        repeat: repeat,
        started: Date(year: 2020, month: 2, day: 3),
      ),
      have,
      id,
    );

    test('AniList stacks one aliased mutation per entry', () {
      final q = anilistSaveBatch([
        op('1', status: 'CURRENT', progress: 4, score: 85, repeat: 1),
        op('x', status: 'COMPLETED'),
        op('2', status: 'PLANNING'),
      ])!;
      expect(q, startsWith('mutation {'));
      expect(q, contains('m0: SaveMediaListEntry(mediaId: 1, status: CURRENT'));
      expect(q, contains('progress: 4'));
      expect(q, contains('scoreRaw: 85'));
      expect(q, contains('repeat: 1'));
      expect(q, contains('startedAt: {year: 2020, month: 2, day: 3}'));
      expect(q, contains('m2: SaveMediaListEntry(mediaId: 2'));
      expect(q, isNot(contains('m1:')));
      expect(anilistSaveBatch([op('x', status: 'CURRENT')]), isNull);
    });

    test('Simkl folds a batch into one request per endpoint', () {
      final requests = simklRequests([
        op('anime/10', status: 'CURRENT', progress: 3, score: 80),
        op('anime/11', status: 'CURRENT', progress: 5),
        op('anime/12', status: 'PLANNING'),
        op(
          'anime/13',
          status: 'COMPLETED',
          progress: 2,
          score: 90,
          have: const SyncItem(
            id: 'a',
            ids: {},
            title: 't',
            status: 'COMPLETED',
            progress: 2,
          ),
        ),
        op(
          'anime/14',
          status: 'CURRENT',
          progress: 1,
          have: const SyncItem(
            id: 'a',
            ids: {},
            title: 't',
            status: 'CURRENT',
            progress: 4,
          ),
        ),
      ]);
      final paths = requests.map((r) => r.$1).toList();
      expect(paths, [
        '/sync/history/remove',
        '/sync/history',
        '/sync/add-to-list',
        '/sync/ratings',
      ]);
      final history = requests[1].$2['anime']! as List;
      expect(history, hasLength(2));
      expect((history.first as Map)['episodes'], hasLength(3));
      expect((history.first as Map)['rating'], 8);
      final removed = (requests[0].$2['anime']! as List).single as Map;
      expect(removed['episodes'], [
        {'number': 2},
        {'number': 3},
        {'number': 4},
      ]);
      expect((requests[3].$2['anime']! as List).single, {
        'ids': {'simkl': 13},
        'rating': 9,
      });
    });
  });
  group('whichever is ahead', () {
    SyncItem item(
      String id,
      Map<String, int> ids, {
      String status = 'CURRENT',
      int progress = 0,
      int score = 0,
      int? total,
    }) => SyncItem(
      id: id,
      ids: ids,
      title: 't',
      status: status,
      progress: progress,
      score: score,
      total: total,
    );

    test(
      'the furthest entry wins, ties go to completed, then the one with a score',
      () {
        final winners = mergeAhead([
          (
            'anilist',
            [
              item('1', {SyncKey.anilist: 1, SyncKey.mal: 10}, progress: 5),
              item('2', {SyncKey.anilist: 2, SyncKey.mal: 20}, progress: 3),
              item('3', {SyncKey.anilist: 3, SyncKey.mal: 30}, progress: 12),
            ],
          ),
          (
            'kitsu',
            [
              item('anime/100', {
                SyncKey.kitsu: 100,
                SyncKey.mal: 10,
              }, progress: 8),
              item(
                'anime/200',
                {SyncKey.kitsu: 200, SyncKey.mal: 20},
                progress: 3,
                score: 70,
              ),
              item(
                'anime/300',
                {SyncKey.kitsu: 300, SyncKey.mal: 30},
                status: 'COMPLETED',
                progress: 12,
              ),
              item('anime/400', {
                SyncKey.kitsu: 400,
                SyncKey.mal: 40,
              }, progress: 1),
            ],
          ),
        ]);
        expect(winners.map((w) => w.source), [
          'kitsu',
          'kitsu',
          'kitsu',
          'kitsu',
        ]);
        expect(winners[0].progress, 8);
        expect(winners[0].ids[SyncKey.anilist], 1);
        expect(winners[1].score, 70);
        expect(winners.map((w) => w.id).toSet(), hasLength(4));
      },
    );

    test('a completed entry counts as having reached the total', () {
      final winners = mergeAhead([
        (
          'a',
          [
            item('1', {SyncKey.mal: 1}, progress: 10, total: 12),
          ],
        ),
        (
          'b',
          [
            item(
              'x',
              {SyncKey.mal: 1},
              status: 'COMPLETED',
              progress: 0,
              total: 12,
            ),
          ],
        ),
      ]);
      expect(winners.single.source, 'b');
    });

    test('one entry never absorbs two from the same service', () {
      final winners = mergeAhead([
        (
          'anilist',
          [
            item('1', {SyncKey.anilist: 1, SyncKey.simkl: 9}),
            item('2', {SyncKey.anilist: 2, SyncKey.simkl: 9}),
          ],
        ),
        (
          'simkl',
          [
            item('anime/9', {SyncKey.simkl: 9}, progress: 4),
          ],
        ),
      ]);
      expect(winners, hasLength(2));
    });

    test('every service is planned against the winners', () {
      final al = [
        item('1', {SyncKey.anilist: 1, SyncKey.mal: 10}, progress: 5),
      ];
      final ki = [
        item('anime/100', {SyncKey.kitsu: 100, SyncKey.mal: 10}, progress: 8),
      ];
      final winners = mergeAhead([('anilist', al), ('kitsu', ki)]);
      final forKitsu = planTarget(
        main: winners,
        target: ki,
        adapter: _Fake(),
        anime: true,
        onlyForward: false,
      );
      expect(forKitsu.pairs.single.state, SyncStatus.synced);
      final forAnilist = planTarget(
        main: winners,
        target: al,
        adapter: _FakeAnilist(),
        anime: true,
        onlyForward: false,
      );
      final pair = forAnilist.pairs.single;
      expect(pair.state, SyncStatus.outdated);
      expect(pair.want.progress, 8);
      expect(pair.targetId, '1');
    });
  });
  group('off the UI thread', () {
    test('target spec reproduces the adapter ids', () {
      for (final a in [_Fake(), _FakeAnilist(), _Resolver()]) {
        final spec = SyncTarget.of(a, anime: true);
        expect(spec.targetId(123), a.targetId(123, anime: true));
      }
    });

    test('isolate planning matches in-thread planning', () async {
      final flat = [1, 10, 100, 0, 2, 20, 200, 0];
      final main = [_main(1, 10), _main(2, 20, progress: 9), _main(3, 30)];
      final target = [
        const SyncItem(
          id: 'anime/100',
          ids: {SyncKey.kitsu: 100},
          title: 'a',
          status: 'CURRENT',
          progress: 3,
          score: 80,
        ),
      ];
      final prepared = await syncPrepareMain(main, flat, SyncKey.anilist);
      final planned = await syncPlanFromMain(
        main: prepared.items,
        targets: {'kitsu': (SyncTarget.of(_Fake(), anime: true), target)},
        flat: flat,
        mainDates: true,
        mainRepeat: true,
        onlyForward: true,
        failed: const {},
      );
      final local = planTarget(
        main: expandItems(main, SyncIdIndex(flat), SyncKey.anilist),
        target: expandItems(target, SyncIdIndex(flat), SyncKey.kitsu),
        adapter: _Fake(),
        anime: true,
        onlyForward: true,
      );
      expect(
        planned.plans['kitsu']!.pairs.map((p) => (p.state, p.targetId)),
        local.pairs.map((p) => (p.state, p.targetId)),
      );
      expect(prepared.fingerprint, syncFingerprint(prepared.items));
      expect(
        await syncExpandIds({SyncKey.anilist: 2}, flat, SyncKey.anilist),
        containsPair(SyncKey.kitsu, 200),
      );
    });
  });
}

class _Resolver extends _Fake {
  @override
  String? targetId(int native, {required bool anime}) => 'manga/$native';
  @override
  bool get canResolve => true;
}

class _FakeAnilist extends _Fake {
  @override
  String get key => SyncKey.anilist;
  @override
  String? targetId(int native, {required bool anime}) => '$native';
}
