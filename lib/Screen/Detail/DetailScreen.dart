import 'package:flutter/material.dart';

import '../../Core/Offline/OfflineMode.dart';
import '../../Core/State/State.dart';

import 'package:skeletonizer/skeletonizer.dart';

import '../../Core/Services/MediaServiceController.dart';
import '../../Core/Services/Model/Media.dart';
import '../../Widgets/Components/BaseScreen.dart';
import '../../Utils/Extensions/ContextExtensions.dart';
import '../../Utils/Animation/WidgetAnimations.dart';
import '../../Utils/Extensions/IntExtensions.dart';
import '../../Utils/Extensions/Responsive.dart';
import '../../Utils/Nav/DpadNav.dart';
import '../Navbar.dart';
import '../../Widgets/Components/ScrollConfig.dart';
import '../Widgets/ScreenWidgetView.dart';
import '../../Core/ThemeManager/ThemeController.dart';
import '../Widgets/Components/DataSection.dart';
import 'Comments/CommentsSection.dart';
import 'Watch/WatchSection.dart';
import 'Components/DetailHeader.dart';
import '../../Api/Discord/DiscordPresence.dart';
import '../../Core/ThemeManager/LanguageSwitcher.dart';
import '../../Widgets/Components/ScreenState.dart';
import 'DetailState.dart';

class DetailScreen extends StatefulWidget {
  final Media media;
  final DetailScreenView view;
  final Mutations? mutations;
  final String? heroTag;
  final int? commentId;

  const DetailScreen({
    super.key,
    required this.media,
    required this.view,
    this.mutations,
    this.heroTag,
    this.commentId,
  });

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends BaseScreen<DetailScreen>
    with ScreenStateHost<DetailScreen, DetailState> {
  @override
  bool get safeArea => false;

  @override
  DetailState buildState() => DetailState(
    media: widget.media,
    view: widget.view,
    mutations: widget.mutations,
    heroTag: widget.heroTag,
    commentId: widget.commentId,
  );

  @override
  String? get glassBackgroundUrl =>
      state.glassImage ?? super.glassBackgroundUrl;

  @override
  DiscordPresence? get presence => state.presence;

  @override
  Widget buildContent(BuildContext context) {
    final content = RefreshIndicator(
      onRefresh: () => state.load(force: true),
      child: Watch(
        () => CustomScrollConfig(
          context,
          physics: const AlwaysScrollableScrollPhysics(),
          controller: state.scroll,
          children: [
            SliverPersistentHeader(
              pinned: true,
              delegate: DetailHeaderDelegate(
                host: state.host,
                top: MediaQuery.paddingOf(context).top,
                glass: find<ThemeController>().useGlassMode.value,
                listLabel: (m) => state.statusLabel(m.userStatus),
                sourceName: state.view.sourceName,
                onEditList: state.mutations == null ? null : state.editList,
                actionFocus: state.actionFocus,
                toolbarLane: state.lane(0),
                actionsLane: state.lane(1),
                onLaneEdge: state.laneEdge,
                horizontalEdge: state.horizontalEdge,
              ),
            ),
            SliverToBoxAdapter(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight:
                      MediaQuery.sizeOf(context).height -
                      MediaQuery.paddingOf(context).top -
                      56,
                ),
                child: _sheet(context),
              ),
            ),
          ],
        ),
      ),
    );

    final nav = Watch(
      () => FloatingBottomNavBar(
        standalone: true,
        laneKey: state.navLane,
        selectedIndex: state.tab.value,
        onTabSelected: state.selectTab,
        items: [
          NavItem(index: 0, icon: Icons.info_rounded, label: getString.navInfo),
          NavItem(
            index: 1,
            icon: state.isAnime
                ? Icons.movie_filter_rounded
                : Icons.import_contacts_rounded,
            label: (state.isAnime ? getString.watch : getString.read)
                .toUpperCase(),
          ),
          if (!find<OfflineMode>().isOffline.value)
            NavItem(
              index: 2,
              icon: Icons.chat_bubble_rounded,
              label: getString.navComments,
            ),
        ],
      ),
    );
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: context.isPhone
          ? Stack(
              children: [
                Positioned.fill(child: content),
                nav,
              ],
            )
          : Row(
              children: [
                SizedBox(width: 100, child: nav),
                Expanded(child: content),
              ],
            ),
    );
  }

  Widget _sheet(BuildContext context) {
    final scheme = context.colorScheme;
    final glass = find<ThemeController>().useGlassMode.value;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: glass ? scheme.surface.withValues(alpha: 0.5) : scheme.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(Dimens.radius),
        ),
      ),
      child: Watch(
        () => Padding(
          padding: EdgeInsets.only(
            top: Dimens.gapLg,
            bottom: context.isPhone ? 120.bottomBar() : Dimens.gapXl * 2,
          ),
          child: _body(),
        ),
      ),
    );
  }

  Widget _body() {
    final current = state.tab.value;
    final visited = state.visited.toList();
    Widget keep(int index, Widget Function() build) => Visibility(
      visible: current == index,
      maintainState: true,
      child: build(),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        keep(0, _info),
        if (visited.contains(1))
          keep(
            1,
            () => WatchSection(
              key: ValueKey('watch-${state.host.media.value.id}'),
              service: state.view.service,
              media: state.host.media,
              mutations: state.mutations,
            ),
          ),
        if (visited.contains(2))
          keep(
            2,
            () => CommentsSection(
              key: ValueKey('comments-${state.host.media.value.id}'),
              service: state.view.service,
              media: state.host.media,
              scroll: state.scroll,
              focusId: state.commentId,
            ),
          ),
      ],
    );
  }

  Widget _info() {
    if (!state.ready.value) return _skeleton();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (state.error.value != null) ...[
          _errorCard(),
          SizedBox(height: Dimens.gapLg),
        ],
        for (final (i, item) in state.widgets.indexed) ...[
          if (i > 0) SizedBox(height: Dimens.gapLg),
          KeyedSubtree(
            key: ValueKey('detail-$i-${item.title ?? item.type}'),
            child: DpadLane(
              laneKey: state.lane(i + 2),
              memoryKey: 'detail-${state.host.media.value.id}-$i',
              verticalEdge: DpadEdgeBehavior.stop,
              horizontalEdge: state.horizontalEdge,
              onEdge: (d) => state.laneEdge(i + 2, d),
              child:
                  ScreenWidgetView(
                    item,
                    heroPrefix: 'detail:${state.host.media.value.id}',
                    onMediaTap: state.open,
                    onCharacterTap: state.openCharacter,
                    onStaffTap: state.openStaff,
                  ).animateFadeUp(
                    begin: 0.06,
                    delay: Duration(milliseconds: 40 * i),
                    duration: 350,
                  ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _errorCard() => Padding(
    padding: EdgeInsets.symmetric(horizontal: Dimens.pagePad),
    child: Material(
      color: context.colorScheme.errorContainer,
      borderRadius: Dimens.borderSm,
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        leading: Icon(
          Icons.cloud_off_rounded,
          color: context.colorScheme.onErrorContainer,
        ),
        title: Text(
          getString.couldntLoadAllDetails,
          style: context.textTheme.bodyLarge?.copyWith(
            color: context.colorScheme.onErrorContainer,
          ),
        ),
        trailing: FilledButton.tonal(
          onPressed: () => state.load(force: true),
          child: Text(getString.retry),
        ),
      ),
    ),
  );

  Widget _skeleton() => Skeletonizer(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: Dimens.pagePad),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: context.colorScheme.surfaceContainerLow,
              borderRadius: Dimens.borderSm,
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: Dimens.gapLg - 2),
              child: Row(
                children: [
                  for (final label in const [
                    'Score',
                    'Popularity',
                    'Favorites',
                    'Duration',
                  ])
                    Expanded(
                      child: Column(
                        children: [
                          Text('8.8', style: context.textTheme.titleLarge),
                          Text(label, style: context.textTheme.labelMedium),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(height: Dimens.gapLg),
        DataSection(
          title: getString.synopsis,
          data: const ScreenData(
            text:
                'Loading the details for this title, this should only take a '
                'moment. Loading the details for this title, this should only '
                'take a moment.',
          ),
        ),
        SizedBox(height: Dimens.gapLg),
        DataSection(
          title: getString.details,
          data: const ScreenData(
            rows: [
              ('Episodes', '12'),
              ('Format', 'TV'),
              ('Source', 'Manga'),
              ('Studio', 'Studio Name'),
              ('Season', 'Summer 2016'),
              ('Aired', 'Jan 1, 2016'),
            ],
          ),
        ),
      ],
    ),
  );
}
