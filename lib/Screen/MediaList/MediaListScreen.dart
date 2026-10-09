import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../Core/Services/MediaService.dart';
import '../../Core/Services/Model/Media.dart';
import '../../Core/ThemeManager/CardStyleController.dart';
import '../../Model/CardStyle.dart';
import '../../Utils/Extensions/CardStyleMetrics.dart';
import '../../Utils/Extensions/Responsive.dart';
import '../../Widgets/Components/AppBars.dart';
import '../../Widgets/Components/BaseScreen.dart';
import '../../Widgets/Components/ScrollConfig.dart';
import '../../Widgets/Shelf/MediaRows.dart';
import '../../Widgets/Shelf/PosterCard.dart';
import '../Feed/FeedNavigation.dart';
import '../../Widgets/Components/EmptyState.dart';
import '../Detail/ListEditorSheet.dart';
import '../../Widgets/Components/AppTabs.dart';
import '../../Api/Discord/DiscordPresence.dart';
import '../../Core/State/State.dart';
import '../../Core/ThemeManager/LanguageSwitcher.dart';
import '../../Utils/Nav/DpadLayers.dart';
import '../../Widgets/Components/ScreenState.dart';
import 'MediaListState.dart';

class MediaListScreen extends StatefulWidget {
  final MediaService service;
  final bool anime;
  final String? userId;
  final String? userName;

  const MediaListScreen({
    super.key,
    required this.service,
    required this.anime,
    this.userId,
    this.userName,
  });

  @override
  State<MediaListScreen> createState() => _MediaListScreenState();
}

class _MediaListScreenState extends BaseScreen<MediaListScreen>
    with
        TickerProviderStateMixin,
        ScreenStateHost<MediaListScreen, MediaListState> {
  @override
  MediaListState buildState() => MediaListState(
    service: widget.service,
    anime: widget.anime,
    userId: widget.userId,
    userName: widget.userName,
  );

  @override
  DiscordPresence? get presence => state.presence;

  @override
  Widget buildContent(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppScreenBar(title: state.title),
      body: _body(context),
    );
  }

  Widget _body(BuildContext context) {
    final loading = state.loading;
    final lists = state.shown;
    if (lists.isEmpty) return _empty(context);

    final keys = lists.keys.toList();
    final controller = state.controllerFor(keys.length);
    return Column(
      children: [
        ScrollConfig(
          context,
          child: Skeletonizer(
            enabled: loading,
            child: AppTabs(
              controller: controller,
              items: [
                for (final key in keys)
                  AppTabItem(
                    loading ? getString.loadingList : key,
                    count: loading ? 0 : lists[key]!.length,
                  ),
              ],
            ),
          ),
        ),
        Expanded(
          child: ScrollConfig(
            context,
            child: TabBarView(
              controller: controller,
              children: [
                for (final key in keys)
                  _grid(context, lists[key]!, skeleton: loading),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _empty(BuildContext context) {
    return RefreshIndicator(
      onRefresh: state.load,
      child: ListView(
        children: [
          SizedBox(
            height: 360,
            child: EmptyState(
              icon: state.failed.value
                  ? Icons.cloud_off_rounded
                  : Icons.inbox_rounded,
              failed: state.failed.value,
              title: state.failed.value
                  ? getString.couldNotLoadList
                  : getString.nothingHereYet,
            ),
          ),
        ],
      ),
    );
  }

  Widget _grid(
    BuildContext context,
    List<Media> media, {
    required bool skeleton,
  }) {
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
        itemCount: media.length,
        itemBuilder: (_, i) => Align(
          alignment: Alignment.topCenter,
          child: _card(media[i], i, skeleton: skeleton),
        ),
      ),
    );
    final scrolling = ScrollConfig(context, child: grid);
    return skeleton ? Skeletonizer(child: scrolling) : scrolling;
  }

  Widget _card(Media media, int index, {required bool skeleton}) {
    final facts = MediaRowFacts(media);
    final tag = skeleton ? null : 'list:${media.id}';
    return PosterCard(
      heroTag: tag,
      imageUrl: media.cover,
      title: media.mainName,
      subtitle: skeleton
          ? null
          : '${media.userProgress ?? '~'} | ${facts.total ?? '~'}',
      progress: skeleton ? null : facts.progress,
      progressText: skeleton
          ? null
          : '${media.userProgress ?? '~'} · ${facts.total ?? '~'}',
      score: skeleton
          ? null
          : (media.userScore ?? 0) > 0
          ? media.userScore! / 10
          : facts.score,
      scoreHighlight: (media.userScore ?? 0) > 0,
      airing: !skeleton && media.status == 'RELEASING',
      onTap: skeleton
          ? null
          : () => openDetail(context, widget.service, media, heroTag: tag),
      onLongPress: skeleton
          ? null
          : () => showQuickListEditor(context, widget.service, media),
    );
  }
}
