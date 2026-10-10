import '../../Widgets/Components/Clickable.dart';
import 'package:flutter/material.dart';

import '../../Api/Services/Anilist/AnilistService.dart';
import '../../Core/Comments/CommentsApi.dart';
import '../../Core/Services/MediaServiceController.dart';
import '../../Core/Services/Model/Media.dart';
import '../../Core/State/State.dart';
import '../../Core/ThemeManager/LanguageSwitcher.dart';
import '../../Utils/Extensions/ContextExtensions.dart';
import '../../Utils/Extensions/Responsive.dart';
import '../../Widgets/Components/EmptyState.dart';
import '../../Widgets/Components/ScreenState.dart';
import 'CommentsState.dart';
import '../../Widgets/Components/SectionCard.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../Core/Comments/CommentModels.dart';
import 'CommentNode.dart';
import 'Components/CommentComposer.dart';
import 'Components/CommentTile.dart';

class CommentsSection extends StatefulWidget {
  final MediaService service;
  final Live<Media> media;
  final ScrollController scroll;
  final int? focusId;

  const CommentsSection({
    super.key,
    required this.service,
    required this.media,
    required this.scroll,
    this.focusId,
  });

  @override
  State<CommentsSection> createState() => _CommentsSectionState();
}

class _CommentsSectionState extends State<CommentsSection>
    with ScreenStateHost<CommentsSection, CommentsState> {
  @override
  CommentsState buildState() => CommentsState(
    service: widget.service,
    media: widget.media,
    scroll: widget.scroll,
    focusId: widget.focusId,
  );

  @override
  Widget build(BuildContext context) => Watch(() => _build(context));

  Widget _build(BuildContext context) {
    final phase = state.phase.value;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Dimens.pagePad),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header(context, phase),
          SizedBox(height: Dimens.gapSm),
          switch (phase) {
            CommentsPhase.loading => _skeleton(context),
            CommentsPhase.disabled => EmptyState(
              icon: Icons.comments_disabled_rounded,
              title: getString.commentsDisabled,
              message: getString.commentsDisabledMessage,
            ),
            CommentsPhase.signedOut => EmptyState(
              icon: Icons.lock_outline_rounded,
              title: getString.commentsSignIn,
              message: getString.commentsSignInMessage,
              actionLabel: getString.signIn,
              onAction: _signIn,
            ),
            CommentsPhase.unavailable => EmptyState(
              icon: Icons.link_off_rounded,
              title: getString.commentsUnavailable,
              message: getString.commentsUnavailableMessage,
            ),
            CommentsPhase.failed => EmptyState(
              icon: Icons.cloud_off_rounded,
              failed: true,
              title: getString.commentsOffline,
              message: state.failure.value,
              actionLabel: getString.retry,
              onAction: state.start,
            ),
            CommentsPhase.ready => _list(context),
          },
        ],
      ),
    );
  }

  Widget _skeleton(BuildContext context) {
    final holder = <CommentNode>[];
    final node = CommentNode(
      Comment(
        id: 0,
        userId: '0',
        mediaId: 0,
        content: 'Loading the comment text so this placeholder has some body.',
        timestamp: DateTime.now().toIso8601String(),
        username: 'Loading user',
        replyCount: 1,
      ),
      0,
      holder.liveList,
    );
    return Skeletonizer(
      child: Column(
        children: [
          for (var i = 0; i < 3; i++)
            SizedBox(
              width: double.infinity,
              child: SectionCard(
                margin: EdgeInsets.only(bottom: Dimens.gapSm),
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                child: CommentTile(state: state, node: node),
              ),
            ),
        ],
      ),
    );
  }

  void _signIn() {
    final anilist = find<MediaServiceController>().services.firstWhere(
      (s) => s.id == anilistServiceId,
    );
    anilist.auth?.login();
  }

  Widget _header(BuildContext context, CommentsPhase phase) {
    final scheme = context.colorScheme;
    return Row(
      children: [
        Expanded(
          child: Text(
            getString.comments,
            style: context.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        IconButton(
          tooltip: getString.commentsRules,
          icon: Icon(Icons.gavel_rounded, color: scheme.onSurfaceVariant),
          onPressed: state.showRules,
        ),
        if (phase == CommentsPhase.ready)
          PopupMenuButton<String>(
            tooltip: getString.sort,
            icon: Icon(Icons.sort_rounded, color: scheme.onSurfaceVariant),
            initialValue: state.sort.value,
            onSelected: state.setSort,
            itemBuilder: (_) => [
              for (final (key, label) in [
                ('newest', getString.commentsSortNewest),
                ('oldest', getString.commentsSortOldest),
                ('highest_rated', getString.commentsSortHighest),
                ('lowest_rated', getString.commentsSortLowest),
              ])
                CheckedPopupMenuItem(
                  value: key,
                  checked: state.sort.value == key,
                  child: Text(label),
                ),
            ],
          ),
      ],
    );
  }

  Widget _filters(BuildContext context) {
    final progress = state.progress;
    final tag = state.filterTag.value;
    final manual = tag != null && tag != progress;
    final auto = state.autoFilter.value;
    String short(int n) => state.isAnime
        ? getString.commentsEpisodeShort(n)
        : getString.commentsChapterShort(n);
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: [
        if (progress > 0)
          Clickable(
            press: false,
            onLongPress: state.pickEpisode,
            child: FilterChip(
              avatar: const Icon(Icons.label_rounded, size: 16),
              label: Text(manual ? '${short(tag)}  ✕' : short(progress)),
              selected: manual || auto,
              onSelected: (_) => state.toggleProgress(),
            ),
          ),
        ActionChip(
          avatar: const Icon(Icons.filter_list_rounded, size: 18),
          label: Text(getString.filter),
          onPressed: state.askFilter,
        ),
      ],
    );
  }

  Widget _list(BuildContext context) {
    final api = find<CommentsApi>();
    final session = api.session.value;
    final nodes = state.nodes.toList();
    final loading = state.loadingList.value;
    final filtered = state.effectiveFilter != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _filters(context),
        SizedBox(height: Dimens.gapSm),
        if (state.single.value)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    getString.commentsSingleTitle,
                    style: context.textTheme.labelLarge,
                  ),
                ),
                TextButton(
                  onPressed: state.showAll,
                  child: Text(getString.commentsShowAll),
                ),
              ],
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: CommentComposer(
              hint: getString.commentsPlaceholder,
              avatar: session?.avatar,
              name: session?.username ?? '',
              tagging: true,
              tag: state.topTag,
              pickTag: () =>
                  state.askTag(initial: state.topTag.value, sending: false),
              onSend: (text, tag) => state.postTop(
                text,
                tag,
                askForTag: state.topTag.value == null,
              ),
            ),
          ),
        if (loading)
          _skeleton(context)
        else if (nodes.isEmpty)
          EmptyState(
            icon: Icons.forum_outlined,
            title: filtered
                ? getString.commentsEmptyFiltered
                : getString.commentsEmpty,
          )
        else
          for (final node in nodes)
            SizedBox(
              key: ValueKey('card${node.comment.id}'),
              width: double.infinity,
              child: SectionCard(
                margin: EdgeInsets.only(bottom: Dimens.gapSm),
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                child: CommentTile(
                  key: ValueKey('c${node.comment.id}'),
                  state: state,
                  node: node,
                ),
              ),
            ),
        if (state.loadingMore.value)
          const Padding(
            padding: EdgeInsets.all(20),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (state.hasMore && !loading)
          Center(
            child: TextButton(
              onPressed: state.loadMore,
              child: Text(getString.commentsLoadMore),
            ),
          ),
      ],
    );
  }
}
