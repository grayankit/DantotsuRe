import 'package:flutter/material.dart';

import '../../Core/Services/MediaService.dart';
import '../../Core/ThemeManager/ThemeController.dart';
import '../../Utils/Extensions/ContextExtensions.dart';
import '../../Widgets/Components/AppBars.dart';
import '../../Widgets/Components/AppTabs.dart';
import '../../Widgets/Components/BaseScreen.dart';
import '../../Widgets/Components/EmptyState.dart';
import '../../Widgets/Components/ScrollConfig.dart';
import 'Components/ActivityComposer.dart';
import 'Components/ActivityList.dart';
import 'Components/ProfileHeader.dart';
import 'Components/ProfileInfoTab.dart';
import 'Components/ProfileStatsTab.dart';
import '../../Api/Discord/DiscordPresence.dart';
import '../../Core/State/State.dart';
import '../../Core/ThemeManager/LanguageSwitcher.dart';
import '../../Widgets/Components/ScreenState.dart';
import 'ProfileState.dart';

class ProfileScreen extends StatefulWidget {
  final MediaService service;
  final String? id;
  final String? name;
  final UserBrief? seed;
  final int initialTab;
  final Object? heroTag;

  const ProfileScreen({
    super.key,
    required this.service,
    this.id,
    this.name,
    this.seed,
    this.initialTab = 0,
    this.heroTag,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends BaseScreen<ProfileScreen>
    with
        SingleTickerProviderStateMixin,
        ScreenStateHost<ProfileScreen, ProfileState> {
  @override
  ProfileState buildState() => ProfileState(
    service: widget.service,
    id: widget.id,
    name: widget.name,
    seedArg: widget.seed,
    initialTab: widget.initialTab,
    onPresenceChanged: refreshPresence,
  );

  @override
  String? get glassBackgroundUrl => state.glassBackgroundUrl;

  @override
  DiscordPresence? get presence => state.presence;

  @override
  Widget buildContent(BuildContext context) {
    if (state.failed.value && state.user.value == null) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: const AppScreenBar(),
        body: EmptyState(
          icon: Icons.person_off_rounded,
          failed: true,
          title: getString.couldntLoadProfile,
          onAction: state.load,
        ),
      );
    }
    final top = MediaQuery.paddingOf(context).top;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Watch(() {
        final glass = find<ThemeController>().useGlassMode.value;
        final userId = state.userId;
        return ScrollConfig(
          context,
          child: NestedScrollView(
            controller: state.scroll,
            headerSliverBuilder: (context, _) => [
              SliverPersistentHeader(
                pinned: true,
                delegate: ProfileHeaderDelegate(
                  service: widget.service,
                  heroTag: widget.heroTag,
                  seed: state.seed,
                  user: state.user,
                  top: top,
                  glass: glass,
                  isSelf: state.isSelf,
                  canFollow: state.view.canInteract,
                  followBusy: state.followBusy,
                  onFollow: state.toggleFollow,
                  onFollowers: state.openFollowers,
                  onFollowing: state.openFollowing,
                  onAnime: () => state.openList(true),
                  onManga: () => state.openList(false),
                ),
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: _TabsDelegate(
                  controller: state.tabs,
                  items: [
                    AppTabItem(getString.profile),
                    if (state.hasActivity) AppTabItem(getString.feed),
                    AppTabItem(getString.stats),
                  ],
                  glass: glass,
                ),
              ),
            ],
            body: userId.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: state.tabs,
                    children: [
                      ProfileInfoTab(
                        service: widget.service,
                        user: state.user.value,
                        userId: userId,
                        bundle: state.bundle,
                      ),
                      if (state.hasActivity)
                        ActivityList(
                          service: widget.service,
                          scope: ActivityScope.user,
                          userId: userId,
                          filterable: true,
                          composer: state.isSelf
                              ? ComposerKind.activity
                              : ComposerKind.message,
                        ),
                      ProfileStatsTab(
                        service: widget.service,
                        userId: userId,
                        bundle: state.bundle,
                      ),
                    ],
                  ),
          ),
        );
      }),
    );
  }
}

class _TabsDelegate extends SliverPersistentHeaderDelegate {
  final TabController controller;
  final List<AppTabItem> items;
  final bool glass;

  _TabsDelegate({
    required this.controller,
    required this.items,
    required this.glass,
  });

  @override
  double get maxExtent => 56;

  @override
  double get minExtent => 56;

  @override
  bool shouldRebuild(_TabsDelegate old) =>
      old.glass != glass || old.controller != controller;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlaps) {
    return ColoredBox(
      color: context.colorScheme.surface.withValues(alpha: glass ? 0.4 : 1),
      child: Align(
        alignment: Alignment.centerLeft,
        child: AppTabs(controller: controller, items: items),
      ),
    );
  }
}
