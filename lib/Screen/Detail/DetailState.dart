import 'dart:async';

import '../../Core/Media/ResumeStore.dart';
import '../../Utils/Animation/WidgetAnimations.dart';

import 'package:flutter/material.dart';

import '../../Api/Discord/DiscordPresence.dart';
import '../../Core/Services/MediaService.dart';
import '../../Core/Services/Model/Author.dart';
import '../../Core/Services/Model/Character.dart';
import '../../Core/Services/Model/Media.dart';
import '../../Core/Services/Screens/DetailCache.dart';
import '../../Core/State/State.dart';
import '../../Core/ThemeManager/LanguageSwitcher.dart';
import '../../Core/ThemeManager/ThemeController.dart';
import '../../Utils/Extensions/ContextExtensions.dart';
import '../../Utils/Functions/AppShortcuts.dart';
import '../../Utils/Functions/NavigateToScreen.dart';
import '../../Utils/Nav/DpadNav.dart';
import '../../Widgets/Components/ScreenState.dart';
import '../Feed/FeedNavigation.dart';
import 'Components/DetailHeader.dart';
import 'DetailScreen.dart';
import 'ListEditorSheet.dart';

class DetailState extends ScreenState {
  final Media media;
  final DetailScreenView view;
  final Mutations? mutations;
  final String? heroTag;
  final int? commentId;

  DetailState({
    required this.media,
    required this.view,
    this.mutations,
    this.heroTag,
    this.commentId,
  });

  late final DetailHost host = DetailHost(
    media: media,
    loading: true.live,
    heroTag: heroTag,
    open: open,
    search: search,
    refresh: () => load(force: true),
  );
  Disposer? _coverSub;
  Disposer? _sessionSub;
  final widgets = <ScreenWidget>[].liveList;
  final ready = false.live;
  late final tab = (commentId == null ? 0 : 2).live;
  late final visited = <int>[0, tab.value].liveList;

  void selectTab(int index) {
    if (!visited.contains(index)) visited.add(index);
    tab.value = index;
  }

  final error = Live<String?>(null);
  bool _focusedOnce = false;
  final scroll = ScrollController();
  Timer? _snapTimer;
  final actionFocus = FocusNode();
  final _lanes = <GlobalKey<DpadRegionState>>[];
  final navLane = GlobalKey<DpadRegionState>();

  GlobalKey<DpadRegionState> lane(int i) {
    while (_lanes.length <= i) {
      _lanes.add(GlobalKey<DpadRegionState>());
    }
    return _lanes[i];
  }

  DpadEdgeBehavior get horizontalEdge =>
      context.isPhone ? DpadEdgeBehavior.stop : DpadEdgeBehavior.leave;

  void laneEdge(int from, TraversalDirection direction) {
    final step = switch (direction) {
      TraversalDirection.up => -1,
      TraversalDirection.down => 1,
      _ => 0,
    };
    if (step == 0) return;
    for (var i = from + step; i >= 0 && i < _lanes.length; i += step) {
      final nodes = _lanes[i].currentState?.focusNodes;
      if (nodes != null && nodes.any((_) => true)) {
        DpadLane.focusFirst(_lanes[i]);
        return;
      }
    }
    if (direction == TraversalDirection.down && context.isPhone) {
      DpadLane.focusFirst(navLane);
    }
  }

  String get cacheKey => '${view.service.id}/${media.id}';

  bool get isAnime => host.media.value.anime != null;

  String? get glassImage => host.media.value.banner ?? host.media.value.cover;

  DiscordPresence get presence => DiscordPresence.viewing(media);

  @override
  void onInit() {
    FocusManager.instance.addListener(_keepFocusVisible);
    scroll.addListener(_scheduleSnap);
    final theme = find<ThemeController>();
    theme.cover.set(this, host.media.value.cover);
    _coverSub = onChange(host.media, (m) => theme.cover.set(this, m.cover));
    _sessionSub = onChange(ResumeStore.sessionTick, (_) {
      if (ResumeStore.sessionKey == '${view.service.id}/${media.id}') {
        unawaited(load(force: true));
      }
    });
    unawaited(load());
  }

  @override
  void onClose() {
    _coverSub?.dispose();
    _sessionSub?.dispose();
    find<ThemeController>().cover.clear(this);
    FocusManager.instance.removeListener(_keepFocusVisible);
    _snapTimer?.cancel();
    scroll.dispose();
    actionFocus.dispose();
  }

  void _keepFocusVisible() {
    if (!mounted || !usingKeyboard || !scroll.hasClients) return;
    final ctx = FocusManager.instance.primaryFocus?.context;
    if (ctx == null || !ctx.mounted) return;
    if (Scrollable.maybeOf(ctx)?.position != scroll.position) return;
    if (DetailHeaderScope.contains(ctx)) return;
    final box = ctx.findRenderObject();
    if (box is! RenderBox || !box.attached || !box.hasSize) return;
    final rect = box.localToGlobal(Offset.zero) & box.size;
    final mq = MediaQuery.of(context);
    final topInset = mq.padding.top + 56 + 12;
    final bottomInset = context.isPhone ? 110.0 + mq.padding.bottom : 24.0;
    final limit = mq.size.height - bottomInset;
    var delta = 0.0;
    if (rect.top < topInset) {
      delta = rect.top - topInset;
    } else if (rect.bottom > limit) {
      delta = rect.bottom - limit;
    }
    if (delta == 0) return;
    final pos = scroll.position;
    unawaited(
      scroll.animateTo(
        (pos.pixels + delta).clamp(pos.minScrollExtent, pos.maxScrollExtent),
        duration: animDuration(180),
        curve: Curves.easeOut,
      ),
    );
  }

  Future<void> load({bool force = false}) async {
    final cached = force ? null : DetailCache.get(cacheKey);
    host.cached = cached != null;
    if (cached != null) host.update(cached);
    host.loading.value = cached == null;
    if (cached == null && widgets.isEmpty) ready.value = false;
    var failed = false;
    error.value = null;
    try {
      await for (final list in view.screenStream(host)) {
        widgets.value = list;
      }
    } catch (e) {
      failed = true;
      error.value = e.toString();
    } finally {
      if (!failed) {
        DetailCache.put(cacheKey, host.media.value);
        ResumeStore.noteProgress(
          view.service,
          host.media.value,
          host.media.value.userProgress,
        );
      }
      host.loading.value = false;
      ready.value = true;
      if (usingKeyboard && !_focusedOnce) {
        _focusedOnce = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && actionFocus.canRequestFocus) {
            actionFocus.requestFocus();
          }
        });
      }
    }
  }

  void search(String query) => openSearch(
    context,
    view.service,
    type: isAnime ? MediaType.anime : MediaType.manga,
    query: query,
  );

  void open(Media next, String? tag) => navigateToPage(
    context,
    DetailScreen(media: next, view: view, mutations: mutations, heroTag: tag),
    hero: true,
  );

  void openCharacter(Character c) => openEntity(
    context,
    view.service,
    EntityKind.character,
    c.id,
    name: c.name,
    image: c.image,
  );

  void openStaff(Author s) => openEntity(
    context,
    view.service,
    EntityKind.staff,
    s.id,
    name: s.name,
    image: s.image,
  );

  void _scheduleSnap() {
    _snapTimer?.cancel();
    _snapTimer = Timer(const Duration(milliseconds: 140), _snapHeader);
  }

  void _snapHeader() {
    if (!mounted || !scroll.hasClients) return;
    final position = scroll.position;
    if (position.isScrollingNotifier.value) return _scheduleSnap();
    final range = detailHeaderCollapseRange();
    final pixels = position.pixels;
    if (pixels <= 0 || pixels >= range) return;
    unawaited(
      scroll.animateTo(
        pixels < range / 2 ? 0 : range,
        duration: animDuration(180),
        curve: Curves.easeOut,
      ),
    );
  }

  void editList() {
    final m = mutations;
    if (m == null) return;
    showListEditor(
      context,
      media: host.media.value,
      view: view.listEditor,
      mutations: m,
      onSaved: load,
    );
  }

  String statusLabel(String? status) => switch (status) {
    'CURRENT' => isAnime ? getString.watching : getString.reading,
    'PLANNING' => getString.planned,
    'COMPLETED' => getString.completed,
    'PAUSED' => getString.paused,
    'DROPPED' => getString.dropped,
    'REPEATING' => isAnime ? getString.rewatching : getString.rereading,
    _ => getString.addToList,
  };
}
