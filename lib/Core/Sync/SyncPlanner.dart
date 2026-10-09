import 'SyncAdapter.dart';
import 'SyncIdIndex.dart';
import 'SyncModels.dart';

List<SyncItem> expandItems(
  List<SyncItem> items,
  SyncIdIndex? index,
  String key,
) => index == null
    ? items
    : [for (final i in items) i.withIds(index.expand(i.ids, prefer: key))];

SyncTargetPlan planTarget({
  required List<SyncItem> main,
  required List<SyncItem> target,
  required SyncAdapter adapter,
  SyncAdapter? mainAdapter,
  required bool anime,
  required bool onlyForward,
}) {
  final byNative = {for (final t in target) t.id: t};
  final byAny = <String, SyncItem>{};
  for (final t in target) {
    for (final e in t.ids.entries) {
      byAny.putIfAbsent('${e.key}:${e.value}', () => t);
    }
  }
  final matched = <String>{};
  final pairs = <SyncPair>[];
  for (final m in main) {
    final native = m.ids[adapter.key];
    SyncItem? found;
    if (native != null) {
      final id = adapter.targetId(native, anime: anime);
      found = id == null ? null : byNative[id];
    }
    if (found == null) {
      for (final e in m.ids.entries) {
        found = byAny['${e.key}:${e.value}'];
        if (found != null) break;
      }
    }
    final targetId =
        found?.id ??
        (native == null ? null : adapter.targetId(native, anime: anime));
    final shared = found != null && !matched.add(found.id);
    final resolvable =
        targetId == null && adapter.canResolve && m.ids[SyncKey.mal] != null;
    final pair = SyncPair(
      dates: adapter.syncsDates && (mainAdapter?.syncsDates ?? true),
      repeat: adapter.syncsRepeat && (mainAdapter?.syncsRepeat ?? true),
      main: m,
      targetId: targetId,
      target: shared ? null : found,
      error: shared ? syncSharedEntry : null,
      state: (targetId == null && !resolvable) || shared
          ? SyncStatus.unmapped
          : found == null
          ? SyncStatus.missing
          : SyncStatus.synced,
    );
    if (found != null && pair.diffs.isNotEmpty) {
      final ahead =
          onlyForward &&
          syncCanonStatus(m.status) == syncCanonStatus(found.status) &&
          found.progress > m.progress &&
          pair.diffs.every((d) => d == 'progress');
      if (!ahead) pair.state = SyncStatus.outdated;
    }
    pairs.add(pair);
  }
  return SyncTargetPlan(
    pairs,
    onlyInTarget: target.where((t) => !matched.contains(t.id)).length,
  );
}
