import 'package:dartotsu_extension_bridge/dartotsu_extension_bridge.dart';
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../Api/Services/Extension/Widgets/SourceBadge.dart';
import '../../Core/Services/Model/Media.dart';
import '../../Core/ThemeManager/CardStyleController.dart';
import '../../Model/CardStyle.dart';
import '../../Utils/Extensions/CardStyleMetrics.dart';
import '../../Utils/Extensions/ContextExtensions.dart';
import '../../Utils/Extensions/Responsive.dart';
import '../../Widgets/Components/AppControls.dart';
import '../../Widgets/Components/AppBars.dart';
import '../../Widgets/Components/BaseScreen.dart';
import '../../Widgets/Components/CachedNetworkImage.dart';
import '../../Widgets/Components/ScrollConfig.dart';
import '../../Widgets/Shelf/PosterCard.dart';
import '../../Widgets/Components/EmptyState.dart';
import '../../Core/State/State.dart';
import '../../Core/ThemeManager/LanguageSwitcher.dart';
import '../../Utils/Nav/DpadLayers.dart';
import '../../Widgets/Components/ScreenState.dart';
import 'SourceBrowseState.dart';

class SourceBrowseScreen extends StatefulWidget {
  final Source source;
  final ItemType type;

  const SourceBrowseScreen({
    super.key,
    required this.source,
    required this.type,
  });

  @override
  State<SourceBrowseScreen> createState() => _SourceBrowseScreenState();
}

class _SourceBrowseScreenState extends BaseScreen<SourceBrowseScreen>
    with ScreenStateHost<SourceBrowseScreen, SourceBrowseState> {
  @override
  SourceBrowseState buildState() =>
      SourceBrowseState(source: widget.source, type: widget.type);

  @override
  Widget buildContent(BuildContext context) {
    final scheme = context.colorScheme;
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppScreenBar(
        titleWidget: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: 34,
                height: 34,
                child: cachedNetworkImage(
                  imageUrl: widget.source.iconUrl ?? '',
                  fit: BoxFit.cover,
                  errorWidget: (_, _, _) => ColoredBox(
                    color: scheme.secondaryContainer,
                    child: Icon(
                      Icons.extension_rounded,
                      size: 20,
                      color: scheme.onSecondaryContainer,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: Dimens.gap),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.source.name ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    state.anime ? getString.animeSource : getString.mangaSource,
                    style: context.textTheme.labelMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              Dimens.pagePad,
              Dimens.gapXs,
              Dimens.pagePad,
              Dimens.gap,
            ),
            child: Watch(
              () => SearchBar(
                controller: state.controller,
                hintText: getString.searchSource(widget.source.name ?? ''),
                elevation: const WidgetStatePropertyAll(0),
                backgroundColor: WidgetStatePropertyAll(
                  scheme.surfaceContainerHigh,
                ),
                padding: const WidgetStatePropertyAll(
                  EdgeInsets.symmetric(horizontal: 16),
                ),
                leading: const Icon(Icons.search_rounded),
                trailing: [
                  if (state.searching.value)
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: state.clearSearch,
                    ),
                ],
                onChanged: state.onQueryChanged,
                textInputAction: TextInputAction.search,
              ),
            ),
          ),
          Watch(
            () => state.searching.value
                ? const SizedBox.shrink()
                : Padding(
                    padding: EdgeInsets.fromLTRB(
                      Dimens.pagePad,
                      0,
                      Dimens.pagePad,
                      Dimens.gapSm,
                    ),
                    child: AppSegmented<SourceFeed>(
                      value: state.feed.value,
                      onChanged: state.selectFeed,
                      segments: [
                        AppSegment(
                          SourceFeed.popular,
                          label: getString.popular,
                          icon: Icons.local_fire_department_rounded,
                        ),
                        AppSegment(
                          SourceFeed.latest,
                          label: getString.latest,
                          icon: Icons.update_rounded,
                        ),
                        AppSegment(
                          SourceFeed.saved,
                          label: getString.saved,
                          icon: Icons.bookmark_rounded,
                        ),
                      ],
                    ),
                  ),
          ),
          Watch(
            () => state.loading.value && state.items.isNotEmpty
                ? const LinearProgressIndicator(minHeight: 2)
                : const SizedBox(height: 2),
          ),
          Expanded(
            child: Watch(() {
              if (state.loading.value && state.items.isEmpty) {
                return _grid(_skeletons(), skeleton: true);
              }
              if (state.items.isEmpty) return _empty();
              return RefreshIndicator(
                onRefresh: () async => state.reload(),
                child: NotificationListener<ScrollNotification>(
                  onNotification: state.onScroll,
                  child: _grid([for (final m in state.items) _card(m)]),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _card(Media media, {bool skeleton = false}) {
    return PosterCard(
      imageUrl: media.cover,
      title: media.mainName,
      overlay: skeleton ? null : extensionSourceBadge(media),
      progressText: media.userProgress == null ? null : '${media.userProgress}',
      onTap: skeleton ? null : () => state.open(media),
    );
  }

  Widget _grid(List<Widget> children, {bool skeleton = false}) {
    final style = tryFind<CardStyleController>()?.current ?? const CardStyle();
    final grid = DpadColumn(
      child: GridView.builder(
        padding: EdgeInsets.fromLTRB(
          Dimens.pagePad,
          Dimens.gapSm,
          Dimens.pagePad,
          Dimens.gapXl,
        ),
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: style.itemWidth + Dimens.cardGap + 6,
          childAspectRatio: style.itemWidth / style.itemHeight,
          crossAxisSpacing: Dimens.cardGap,
          mainAxisSpacing: Dimens.gap,
        ),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: children.length,
        itemBuilder: (_, i) =>
            Align(alignment: Alignment.topCenter, child: children[i]),
      ),
    );
    final scrolling = ScrollConfig(context, child: grid);
    return skeleton ? Skeletonizer(child: scrolling) : scrolling;
  }

  List<Widget> _skeletons() => [
    for (var i = 0; i < 12; i++) _card(Media.skeleton(), skeleton: true),
  ];

  Widget _empty() {
    final failed = state.failed;
    return EmptyState(
      icon: failed ? Icons.cloud_off_rounded : Icons.inbox_rounded,
      failed: failed,
      title: state.emptyTitle,
      message: state.emptyMessage,
      onAction: failed ? state.reload : null,
    );
  }
}
