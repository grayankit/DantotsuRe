import 'dart:async';

import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../Core/Services/Api/SauceNao.dart';
import '../../../Core/State/State.dart';
import '../../../Core/ThemeManager/LanguageSwitcher.dart';
import '../../../Utils/Animation/WidgetAnimations.dart';
import '../../../Utils/Extensions/ContextExtensions.dart';
import '../../../Utils/Extensions/Responsive.dart';
import '../../../Utils/Function.dart';
import '../../../Utils/Functions/NavigateToScreen.dart';
import '../../../Widgets/Components/AppSheet.dart';
import '../../../Widgets/Components/CachedNetworkImage.dart';
import '../../../Widgets/Components/Clickable.dart';
import '../../../Widgets/Components/CustomBottomDialog.dart';
import '../../../Widgets/Components/EmptyState.dart';
import '../../../Widgets/Components/ScreenState.dart';
import 'SauceState.dart';

Future<SauceHit?> showSauceSearch(BuildContext context) =>
    showCustomBottomDialog<SauceHit>(context, const SauceSheet());

class SauceSheet extends StatefulWidget {
  const SauceSheet({super.key});

  @override
  State<SauceSheet> createState() => _SauceSheetState();
}

class _SauceSheetState extends State<SauceSheet>
    with ScreenStateHost<SauceSheet, SauceState> {
  @override
  SauceState buildState() => SauceState();

  @override
  Widget build(BuildContext context) => Watch(() => _build(context));

  Widget _build(BuildContext context) {
    final scheme = context.colorScheme;
    final hits = state.hits.value;
    final busy = state.busy.value;
    final error = state.error.value;
    return AppSheet(
      title: getString.sauceTitle,
      heightFactor: 0.9,
      trailing: IconButton(
        tooltip: getString.sauceKeyTitle,
        onPressed: state.editKey,
        icon: const Icon(Icons.key_rounded),
      ),
      child: ListView(
        padding: EdgeInsets.fromLTRB(
          Dimens.pagePad,
          0,
          Dimens.pagePad,
          Dimens.gapXl,
        ),
        children: [
          Text(
            getString.sauceIntro,
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
              title: getString.sauceEmpty,
            )
          else if (hits != null)
            for (final (i, hit) in hits.indexed) ...[
              _HitTile(hit: hit).animateStagger(i),
              SizedBox(height: Dimens.gapSm),
            ],
          SizedBox(height: Dimens.gapSm),
          Center(
            child: Text(
              getString.sauceCredit,
              style: context.textTheme.labelSmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

const _placeholder = SauceHit(
  similarity: 90,
  title: 'Loading the title of the match',
  creator: 'Creator',
  site: 'MangaDex',
);

class _HitTile extends StatelessWidget {
  final SauceHit hit;

  const _HitTile({required this.hit});

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    final text = context.textTheme;
    final detail = [
      if (hit.creator != null) hit.creator!,
      if (hit.part != null) hit.part!,
      if (hit.site != null) hit.site!,
    ].join(' · ');
    return Clickable(
      onTap: () => popPage(context, hit),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Padding(
          padding: EdgeInsets.all(Dimens.gap),
          child: Row(
            children: [
              if (hit.thumbnail != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 64,
                    height: 88,
                    child: cachedNetworkImage(
                      imageUrl: hit.thumbnail,
                      fit: BoxFit.cover,
                      width: 64,
                      height: 88,
                    ),
                  ),
                ),
                SizedBox(width: Dimens.gap),
              ],
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
                    if (detail.isNotEmpty)
                      Text(
                        detail,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: text.labelMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    SizedBox(height: Dimens.gapSm),
                    Wrap(
                      spacing: 6,
                      children: [
                        _chip(
                          context,
                          getString.sauceSimilarity(
                            hit.similarity.round().toString(),
                          ),
                          hit.low
                              ? scheme.errorContainer
                              : scheme.primaryContainer,
                          hit.low
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
              if (hit.link != null)
                IconButton(
                  tooltip: getString.sauceOpen,
                  icon: const Icon(Icons.open_in_new_rounded),
                  onPressed: () => unawaited(openLinkInBrowser(hit.link!)),
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
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: context.textTheme.labelSmall?.copyWith(color: fg),
        ),
      );
}
