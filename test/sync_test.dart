import 'package:dartotsu/Core/Services/Model/Date.dart';
import 'package:dartotsu/Core/Sync/SyncAdapter.dart';
import 'package:dartotsu/Core/Sync/SyncIdIndex.dart';
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
}

class _Resolver extends _Fake {
  @override
  String? targetId(int native, {required bool anime}) => 'manga/$native';
  @override
  bool get canResolve => true;
}
