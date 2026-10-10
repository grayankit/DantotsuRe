import 'package:flutter/material.dart';

import '../../Core/Services/MediaService.dart';
import '../../Core/State/State.dart';
import '../../Core/ThemeManager/LanguageSwitcher.dart';
import '../../Core/ThemeManager/ThemeController.dart';
import '../../Utils/Extensions/ContextExtensions.dart';
import '../../Utils/Extensions/Responsive.dart';
import '../../Widgets/Components/AppBars.dart';
import '../../Widgets/Components/AppTabs.dart';
import '../../Widgets/Components/BaseScreen.dart';
import '../../Widgets/Components/CachedNetworkImage.dart';
import '../../Widgets/Components/EmptyState.dart';
import '../../Widgets/Components/MarkupText.dart';
import '../../Widgets/Components/ProfileCard.dart';
import '../../Widgets/Components/ScreenState.dart';
import '../../Widgets/Components/ScrollConfig.dart';
import '../../Widgets/Components/SectionCard.dart';
import '../../Widgets/Components/UserAvatar.dart';
import 'Components/ActivityComposer.dart';
import 'Components/ActivityList.dart';
import 'Components/GroupCard.dart';
import 'Components/GroupMembersTab.dart';
import 'GroupState.dart';
import 'GroupsState.dart';
import 'package:skeletonizer/skeletonizer.dart';

class GroupScreen extends StatefulWidget {
  final MediaService service;
  final String idOrSlug;
  final SocialGroup? seed;

  const GroupScreen({
    super.key,
    required this.service,
    required this.idOrSlug,
    this.seed,
  });

  @override
  State<GroupScreen> createState() => _GroupScreenState();
}

class _GroupScreenState extends BaseScreen<GroupScreen>
    with
        SingleTickerProviderStateMixin,
        ScreenStateHost<GroupScreen, GroupState> {
  @override
  GroupState buildState() => GroupState(
    service: widget.service,
    idOrSlug: widget.idOrSlug,
    seed: widget.seed,
  );

  @override
  String? get glassBackgroundUrl =>
      state.group.value?.cover ?? super.glassBackgroundUrl;

  @override
  Widget buildContent(BuildContext context) {
    return Watch(() {
      state.version.track();
      final group = state.group.value;
      if (group == null) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          appBar: const AppScreenBar(),
          body: state.failed.value
              ? EmptyState(
                  icon: Icons.groups_rounded,
                  failed: true,
                  title: getString.groupsCouldntLoad,
                  actionLabel: getString.retry,
                  onAction: state.load,
                )
              : Skeletonizer(
                  child: ListView(
                    physics: const NeverScrollableScrollPhysics(),
                    children: [_header(context, GroupsState.placeholder)],
                  ),
                ),
        );
      }
      final glass = find<ThemeController>().useGlassMode.value;
      return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppScreenBar(
          title: group.name,
          actions: [
            if (group.siteUrl != null)
              IconButton(
                tooltip: getString.groupsOpenInBrowser,
                icon: const Icon(Icons.open_in_new_rounded),
                onPressed: state.openInBrowser,
              ),
          ],
        ),
        body: ScrollConfig(
          context,
          child: NestedScrollView(
            headerSliverBuilder: (context, _) => [
              SliverToBoxAdapter(child: _header(context, group)),
              SliverPersistentHeader(
                pinned: true,
                delegate: _TabsDelegate(
                  controller: state.tabs,
                  glass: glass,
                  items: [
                    AppTabItem(getString.groupsPosts),
                    if (state.view.hasGroupMembers)
                      AppTabItem(getString.groupsMembersTab),
                    AppTabItem(getString.groupsAbout),
                  ],
                ),
              ),
            ],
            body: TabBarView(
              controller: state.tabs,
              children: [
                ActivityList(
                  service: widget.service,
                  scope: ActivityScope.global,
                  groupId: group.id,
                  composer: group.isMember ? ComposerKind.group : null,
                ),
                if (state.view.hasGroupMembers)
                  GroupMembersTab(service: widget.service, groupId: group.id),
                _about(context, group),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _header(BuildContext context, SocialGroup group) {
    final scheme = context.colorScheme;
    final text = context.textTheme;
    final cover = group.cover ?? group.avatar;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            SizedBox(
              height: 132,
              width: double.infinity,
              child: cover == null
                  ? ColoredBox(color: scheme.secondaryContainer)
                  : cachedNetworkImage(imageUrl: cover, fit: BoxFit.cover),
            ),
            Positioned(
              left: Dimens.pagePad,
              bottom: -34,
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: scheme.surface,
                ),
                child: UserAvatar(
                  url: group.avatar,
                  name: group.name,
                  size: 72,
                ),
              ),
            ),
          ],
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(
            Dimens.pagePad,
            Dimens.gapSm,
            Dimens.pagePad,
            0,
          ),
          child: Row(
            children: [
              const SizedBox(width: 84),
              const Spacer(),
              if (state.canJoin)
                Watch(
                  () => group.isMember
                      ? OutlinedButton(
                          onPressed: state.busy.value ? null : state.toggle,
                          child: Text(getString.groupsJoined),
                        )
                      : FilledButton(
                          onPressed: state.busy.value ? null : state.toggle,
                          child: Text(getString.groupsJoin),
                        ),
                ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(
            Dimens.pagePad,
            Dimens.gapXs,
            Dimens.pagePad,
            Dimens.gapSm,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                group.name,
                style: text.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (group.tagline != null && group.tagline!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    group.tagline!,
                    style: text.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
              SizedBox(height: Dimens.gapSm),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  if (group.members >= 0)
                    ProfilePill(
                      getString.groupsMembersCount(group.members),
                      color: scheme.primary,
                    ),
                  if (group.leaders > 0)
                    ProfilePill(
                      getString.groupsLeaders(group.leaders),
                      color: scheme.secondary,
                    ),
                  ProfilePill(
                    groupPrivacyLabel(group.privacy),
                    color: scheme.onSurfaceVariant,
                  ),
                  if (group.category != null)
                    ProfilePill(group.category!, color: scheme.tertiary),
                  if (group.nsfw)
                    ProfilePill(getString.groupsAdult, color: scheme.error),
                  if (group.isMember)
                    ProfilePill(groupRoleLabel(group), color: scheme.primary),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _about(BuildContext context, SocialGroup group) {
    final scheme = context.colorScheme;
    final text = context.textTheme;
    Widget row(String label, String value) => Padding(
      padding: EdgeInsets.symmetric(vertical: Dimens.gapXs),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ),
          Text(value, style: text.bodyMedium),
        ],
      ),
    );
    final created = group.createdAt <= 0
        ? null
        : DateTime.fromMillisecondsSinceEpoch(group.createdAt * 1000);
    return ScrollConfig(
      context,
      child: ListView(
        padding: EdgeInsets.fromLTRB(
          Dimens.pagePad,
          Dimens.gapSm,
          Dimens.pagePad,
          120,
        ),
        children: [
          if (group.about != null && group.about!.isNotEmpty)
            SectionCard(
              title: getString.groupsAbout,
              child: MarkupText(text: group.about!),
            ),
          if (group.rules != null && group.rules!.isNotEmpty) ...[
            SizedBox(height: Dimens.gapSm),
            SectionCard(
              title: getString.groupsRules,
              child: MarkupText(text: group.rules!),
            ),
          ],
          SizedBox(height: Dimens.gapSm),
          SectionCard(
            child: Column(
              children: [
                if (group.members >= 0)
                  row(getString.groupsMembersTab, '${group.members}'),
                row(getString.groupsPrivacy, groupPrivacyLabel(group.privacy)),
                if (group.category != null)
                  row(getString.groupsCategory, group.category!),
                if (group.locale != null)
                  row(getString.groupsLanguage, group.locale!),
                if (created != null)
                  row(
                    getString.groupsCreated,
                    MaterialLocalizations.of(context).formatMediumDate(created),
                  ),
              ],
            ),
          ),
        ],
      ),
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
