import 'package:flutter/material.dart';

import '../../../Core/Preferences/PrefManager.dart';
import '../../../Core/Services/MediaService.dart';
import '../../../Core/State/State.dart';
import '../../../Core/Sync/SyncController.dart';
import '../../../Core/Sync/SyncModels.dart';
import '../../../Core/ThemeManager/LanguageSwitcher.dart';
import '../../../Utils/Functions/SnackBar.dart';
import '../../../Widgets/Components/ScreenState.dart';

class SyncState extends ScreenState {
  final controller = find<SyncController>();
  TabController? tabs;

  @override
  void onClose() {
    tabs?.dispose();
    super.onClose();
  }

  TabController tabsFor(int length) {
    final current = tabs;
    if (current != null && current.length == length) return current;
    final next = TabController(
      length: length,
      vsync: vsync,
      initialIndex: targets
          .indexWhere((s) => s.id == selected.value)
          .clamp(0, length - 1),
    );
    next.addListener(() {
      if (next.indexIsChanging) return;
      final all = targets;
      if (next.index < all.length && all[next.index].id != selected.value) {
        selected.value = all[next.index].id;
        filter.value = SyncStatus.outdated;
      }
    });
    tabs?.dispose();
    return tabs = next;
  }

  MediaService? get mainService => controller.mainService;

  final selected = Live<String?>(null);
  final filter = Live<SyncStatus?>(SyncStatus.outdated);

  String get mainId => controller.mainId;

  bool get isAnime => controller.anime.value;

  List<MediaService> get candidates => controller.candidates;

  SyncPlan? get plan {
    final p = controller.plan.value;
    return p != null && p.main == mainId && p.anime == isAnime ? p : null;
  }

  List<MediaService> get targets {
    final p = plan;
    if (p == null) return const [];
    return [
      for (final s in controller.candidates)
        if (p.targets.containsKey(s.id)) s,
    ];
  }

  MediaService? get selectedService {
    final all = targets;
    if (all.isEmpty) return null;
    return all.firstWhere(
      (s) => s.id == selected.value,
      orElse: () => all.first,
    );
  }

  SyncTargetPlan? get current {
    final s = selectedService;
    return s == null ? null : plan?.targets[s.id];
  }

  SyncStatus? get effectiveFilter {
    final f = filter.value;
    final cur = current;
    return f != null && cur != null && cur.count(f) == 0 ? null : f;
  }

  List<SyncPair> get pairs {
    final cur = current;
    if (cur == null) return const [];
    final f = effectiveFilter;
    if (f != null) {
      return [
        for (final p in cur.pairs)
          if (p.state == f) p,
      ];
    }
    int rank(SyncPair p) => p.op == SyncOpState.failed
        ? 0
        : switch (p.state) {
            SyncStatus.outdated => 1,
            SyncStatus.missing => 2,
            SyncStatus.synced => 3,
            SyncStatus.unmapped => 4,
          };
    return [...cur.pairs]..sort((a, b) => rank(a).compareTo(rank(b)));
  }

  int pendingOf(String id) {
    final t = plan?.targets[id];
    if (t == null) return 0;
    final addMissing = PrefName.syncAddMissing.rx.value;
    return t.pairs
        .where(
          (p) =>
              p.pending &&
              (p.state == SyncStatus.outdated ||
                  addMissing && p.state == SyncStatus.missing),
        )
        .length;
  }

  void setMain(String id) {
    if (controller.busy) return;
    PrefName.syncMain.rx.value = id;
    selected.value = null;
    filter.value = SyncStatus.outdated;
  }

  void setType(bool anime) {
    if (controller.busy) return;
    controller.anime.value = anime;
    selected.value = null;
    filter.value = SyncStatus.outdated;
  }

  Future<void> fetch() => controller.fetch();

  Future<void> syncAll() => controller.start();

  Future<void> syncSelected() {
    final s = selectedService;
    return s == null ? Future.value() : controller.start(only: s.id);
  }

  void stop() => controller.stop();

  void clear() {
    controller.clear();
    snackString(getString.syncCleared);
  }

  String statusLabel(String? status) => switch (status) {
    'CURRENT' ||
    'REPEATING' => isAnime ? getString.watching : getString.reading,
    'PLANNING' => getString.planning,
    'COMPLETED' => getString.completed,
    'DROPPED' => getString.dropped,
    'PAUSED' => getString.paused,
    _ => '-',
  };
}
