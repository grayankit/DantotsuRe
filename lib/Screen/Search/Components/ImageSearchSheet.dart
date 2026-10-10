import '../../../Widgets/Components/ScrollConfig.dart';
import '../../../Utils/Functions/NavigateToScreen.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../Core/Services/Api/TraceMoe.dart';
import '../../../Core/State/State.dart';
import '../../../Core/ThemeManager/LanguageSwitcher.dart';
import '../../../Utils/Extensions/ContextExtensions.dart';
import '../../../Utils/Extensions/Responsive.dart';
import '../../../Utils/Function.dart';
import '../../../Widgets/Components/AppSheet.dart';
import '../../../Widgets/Components/CachedNetworkImage.dart';
import '../../../Widgets/Components/Clickable.dart';
import '../../../Widgets/Components/CustomBottomDialog.dart';
import '../../../Widgets/Components/EmptyState.dart';
import '../../../Widgets/Components/ScreenState.dart';
import 'ImageSearchState.dart';

Future<TraceHit?> showImageSearch(BuildContext context) =>
    showCustomBottomDialog<TraceHit>(context, const ImageSearchSheet());

class ImageSearchSheet extends StatefulWidget {
  const ImageSearchSheet({super.key});

  @override
  State<ImageSearchSheet> createState() => _ImageSearchSheetState();
}

class _ImageSearchSheetState extends State<ImageSearchSheet>
    with ScreenStateHost<ImageSearchSheet, ImageSearchState> {
  @override
  ImageSearchState buildState() => ImageSearchState();

  @override
  Widget build(BuildContext context) => Watch(() => _build(context));

  Widget _build(BuildContext context) {
    final scheme = context.colorScheme;
    final hits = state.hits.value;
    final busy = state.busy.value;
    final error = state.error.value;
    return AppSheet(
      title: getString.imageSearchTitle,
      heightFactor: 0.9,
      child: ScrollConfig(
        context,
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            Dimens.pagePad,
            0,
            Dimens.pagePad,
            Dimens.gapXl,
          ),
          children: [
            Text(
              getString.imageSearchIntro,
              style: context.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: Dimens.gap),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: state.link,
                    enabled: !busy,
                    keyboardType: TextInputType.url,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => unawaited(state.submitLink()),
                    decoration: InputDecoration(
                      hintText: getString.imageSearchLinkHint,
                      prefixIcon: const Icon(Icons.link_rounded),
                    ),
                  ),
                ),
                SizedBox(width: Dimens.gapSm),
                IconButton.filled(
                  tooltip: getString.imageSearchGo,
                  onPressed: busy ? null : () => unawaited(state.submitLink()),
                  icon: const Icon(Icons.search_rounded),
                ),
              ],
            ),
            SizedBox(height: Dimens.gapSm),
            SizedBox(
              width: double.infinity,
              child: FilledButton.tonalIcon(
                onPressed: busy ? null : () => unawaited(state.pick()),
                icon: const Icon(Icons.image_search_rounded),
                label: Text(getString.imageSearchPick),
              ),
            ),
            if (state.bytes.value != null || state.url.value != null) ...[
              SizedBox(height: Dimens.gap),
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 180),
                  child: SizedBox(
                    width: double.infinity,
                    child: state.bytes.value != null
                        ? Image.memory(state.bytes.value!, fit: BoxFit.cover)
                        : cachedNetworkImage(
                            imageUrl: state.url.value,
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
              ),
            ],
            SizedBox(height: Dimens.gap),
            if (busy)
              Skeletonizer(
                child: Column(
                  children: [
                    for (var i = 0; i < 3; i++) ...[
                      const _HitTile(hit: _placeholder),
                      SizedBox(height: Dimens.gapSm),
                    ],
                  ],
                ),
              )
            else if (error != null)
              EmptyState(
                icon: Icons.error_outline_rounded,
                failed: true,
                title: error,
              )
            else if (hits != null && hits.isEmpty)
              EmptyState(
                icon: Icons.search_off_rounded,
                title: getString.imageSearchEmpty,
              )
            else if (hits != null)
              for (final hit in hits) ...[
                _HitTile(hit: hit),
                SizedBox(height: Dimens.gapSm),
              ],
            SizedBox(height: Dimens.gapSm),
            Center(
              child: Text(
                getString.imageSearchCredit,
                style: context.textTheme.labelSmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

const _placeholder = TraceHit(
  anilistId: 0,
  title: 'Loading the title of the match',
  episode: '12',
  from: 600,
  similarity: 0.95,
);

class _HitTile extends StatelessWidget {
  final TraceHit hit;

  const _HitTile({required this.hit});

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    final text = context.textTheme;
    final percent = (hit.similarity * 100).round();
    final low = hit.similarity < 0.87;
    final detail = [
      if (hit.episode != null) getString.imageSearchEpisode(hit.episode!),
      getString.imageSearchAt(hit.time),
    ].join(' · ');
    return Clickable(
      onTap: () => popPage(context, hit),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 128,
                  height: 72,
                  child: cachedNetworkImage(
                    imageUrl: hit.image,
                    fit: BoxFit.cover,
                    width: 128,
                    height: 72,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hit.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: text.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      detail,
                      style: text.labelMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        _chip(
                          context,
                          getString.imageSearchSimilarity(percent),
                          low ? scheme.errorContainer : scheme.primaryContainer,
                          low
                              ? scheme.onErrorContainer
                              : scheme.onPrimaryContainer,
                        ),
                        if (hit.adult)
                          _chip(
                            context,
                            getString.imageSearchAdult,
                            scheme.tertiaryContainer,
                            scheme.onTertiaryContainer,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              if (hit.video != null)
                IconButton(
                  tooltip: getString.imageSearchPreview,
                  icon: const Icon(Icons.play_circle_outline_rounded),
                  onPressed: () => unawaited(openLinkInBrowser(hit.video!)),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chip(BuildContext context, String label, Color bg, Color fg) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: context.textTheme.labelSmall?.copyWith(
            color: fg,
            fontWeight: FontWeight.w800,
          ),
        ),
      );
}
