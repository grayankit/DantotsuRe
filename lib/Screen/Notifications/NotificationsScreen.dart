import '../../Utils/Nav/DpadNav.dart';

import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../Core/Services/MediaServiceController.dart';
import '../../Utils/Extensions/ContextExtensions.dart';
import '../../Utils/Extensions/Responsive.dart';
import '../../Widgets/Components/AppBars.dart';
import '../../Widgets/Components/BaseScreen.dart';
import '../../Widgets/Components/CachedNetworkImage.dart';
import '../../Widgets/Components/SectionCard.dart';
import '../../Widgets/Components/ScrollConfig.dart';
import '../../Widgets/Components/EmptyState.dart';
import '../../Api/Discord/DiscordPresence.dart';
import '../../Core/State/State.dart';
import '../../Core/ThemeManager/LanguageSwitcher.dart';
import '../../Widgets/Components/ScreenState.dart';
import 'NotificationsState.dart';

class NotificationsScreen extends StatefulWidget {
  final NotificationScreenView view;
  const NotificationsScreen({super.key, required this.view});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends BaseScreen<NotificationsScreen>
    with ScreenStateHost<NotificationsScreen, NotificationsState> {
  @override
  NotificationsState buildState() => NotificationsState(widget.view);

  @override
  DiscordPresence? get presence => state.presence;

  @override
  Widget buildContent(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppScreenBar(title: getString.notifications),
      body: RefreshIndicator(
        onRefresh: state.load,
        child: Watch(() {
          if (state.loading.value && state.items.isEmpty) return _skeleton();
          if (state.items.isEmpty) {
            return EmptyState(
              icon: Icons.notifications_off_rounded,
              title: getString.nothingNew,
            );
          }
          return NotificationListener<ScrollNotification>(
            onNotification: state.onScroll,
            child: ScrollConfig(
              context,
              child: ListView(
                padding: EdgeInsets.fromLTRB(
                  Dimens.gap,
                  Dimens.gapXs,
                  Dimens.gap,
                  Dimens.gapXl,
                ),
                children: [
                  for (final group in state.grouped()) ...[
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        Dimens.gapSm,
                        Dimens.gap,
                        Dimens.gapSm,
                        Dimens.gapSm,
                      ),
                      child: Text(
                        group.$1,
                        style: context.textTheme.labelLarge?.copyWith(
                          color: context.colorScheme.primary,
                        ),
                      ),
                    ),
                    for (final n in group.$2) _row(n),
                  ],
                  if (state.loadingMore.value)
                    const Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _row(ServiceNotification n) {
    final scheme = context.colorScheme;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: Dimens.gapXs),
      child: SectionCard(
        padding: EdgeInsets.zero,
        child: Material(
          color: Colors.transparent,
          borderRadius: Dimens.border,
          clipBehavior: Clip.antiAlias,
          child: DpadTap(
            borderRadius: Dimens.border,
            onTap: state.canOpen(n) ? () => state.open(n) : null,
            child: Padding(
              padding: EdgeInsets.all(Dimens.gapSm + 2),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: SizedBox(
                      width: 44,
                      height: 58,
                      child: n.imageUrl == null
                          ? ColoredBox(
                              color: scheme.surfaceContainerHighest,
                              child: Icon(
                                Icons.notifications_rounded,
                                color: scheme.onSurfaceVariant,
                                size: 20,
                              ),
                            )
                          : cachedNetworkImage(
                              imageUrl: n.imageUrl,
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          n.text,
                          style: context.textTheme.bodyMedium,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          NotificationsState.ago(n.createdAt),
                          style: context.textTheme.labelSmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (n.mediaId != null)
                    Icon(
                      Icons.chevron_right_rounded,
                      color: scheme.onSurfaceVariant,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _skeleton() => Skeletonizer(
    child: ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
      itemCount: 8,
      itemBuilder: (_, i) => _row(
        ServiceNotification(
          id: '$i',
          text: 'A new episode of something has just aired somewhere',
          createdAt: DateTime.now(),
        ),
      ),
    ),
  );
}
