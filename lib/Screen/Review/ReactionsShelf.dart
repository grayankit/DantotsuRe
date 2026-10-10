import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../Core/Services/MediaServiceController.dart';
import '../../Core/Services/Model/Media.dart';
import '../../Core/Services/Model/User.dart';
import '../../Core/State/State.dart';
import '../../Core/ThemeManager/LanguageSwitcher.dart';
import '../../Utils/Extensions/ContextExtensions.dart';
import '../../Utils/Extensions/Responsive.dart';
import '../../Widgets/Components/ScreenState.dart';
import '../../Widgets/Components/SectionCard.dart';
import '../../Widgets/Components/UserAvatar.dart';
import '../../Widgets/Shelf/ShelfFrame.dart';
import 'ReactionsState.dart';

class ReactionsShelf extends StatefulWidget {
  final Media media;
  final DetailScreenView view;

  const ReactionsShelf({super.key, required this.media, required this.view});

  @override
  State<ReactionsShelf> createState() => _ReactionsShelfState();
}

class _ReactionsShelfState extends State<ReactionsShelf>
    with ScreenStateHost<ReactionsShelf, ReactionsState> {
  static final _placeholder = MediaReaction(
    id: '0',
    text: 'A short reaction written by a reader about this title.',
    votes: 12,
    user: User(id: 0, name: 'Reader name'),
  );

  @override
  ReactionsState buildState() =>
      ReactionsState(media: widget.media, view: widget.view);

  @override
  Widget build(BuildContext context) => Watch(() => _build(context));

  Widget _build(BuildContext context) {
    final loading = state.loading.value;
    final items = state.items.toList();
    if (!loading && items.isEmpty) return const SizedBox.shrink();
    final shown = loading ? [_placeholder, _placeholder] : items.take(5);
    return ShelfFrame(
      title: getString.reactionsTitle,
      child: Skeletonizer(
        enabled: loading,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: Dimens.pagePad),
          child: Column(
            children: [
              for (final r in shown)
                Padding(
                  padding: EdgeInsets.only(bottom: Dimens.gapSm),
                  child: _tile(context, r),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tile(BuildContext context, MediaReaction r) {
    final scheme = context.colorScheme;
    return SectionCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          UserAvatar(url: r.user?.pfp, name: r.user?.name ?? '?', size: 34),
          SizedBox(width: Dimens.gapSm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  r.user?.name ?? '',
                  style: context.textTheme.titleSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: Dimens.gapXs),
                Text(r.text, style: context.textTheme.bodyMedium),
              ],
            ),
          ),
          SizedBox(width: Dimens.gapSm),
          Column(
            children: [
              Icon(
                Icons.thumb_up_alt_rounded,
                size: 16,
                color: scheme.onSurfaceVariant,
              ),
              SizedBox(height: Dimens.gapXs),
              Text(
                '${r.votes}',
                style: context.textTheme.labelMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
