import 'package:flutter/material.dart';

import '../../../../Core/Services/Model/Media.dart';
import '../../../../Core/ThemeManager/LanguageSwitcher.dart';
import '../../../../Core/Watch/EpisodeUnits.dart';
import '../../../../Utils/Extensions/ContextExtensions.dart';
import '../../../../Utils/Extensions/Responsive.dart';
import '../../../../Widgets/Components/CachedNetworkImage.dart';
import '../../../../Widgets/Components/Clickable.dart';
import 'UnitTile.dart';

class ContinueCard extends StatelessWidget {
  final WatchUnit unit;
  final bool anime;
  final bool started;
  final Media media;
  final VoidCallback onTap;

  const ContinueCard({
    super.key,
    required this.unit,
    required this.anime,
    required this.started,
    required this.media,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    final total = media.totalUnits;
    final progress = media.userProgress ?? 0;
    return Clickable(
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: scheme.primaryContainer,
          borderRadius: Dimens.borderSm,
        ),
        child: Padding(
          padding: EdgeInsets.all(Dimens.gapSm),
          child: Row(
            children: [
              if (anime && unit.thumbnail != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(Dimens.radiusSm - 6),
                  child: cachedNetworkImage(
                    imageUrl: unit.thumbnail,
                    width: 112,
                    height: 63,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(width: Dimens.gap),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      started ? getString.watchContinue : getString.watchStart,
                      style: context.textTheme.labelMedium?.copyWith(
                        color: scheme.onPrimaryContainer,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      unitTitle(unit, anime),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.titleSmall?.copyWith(
                        color: scheme.onPrimaryContainer,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      total == null || total <= 0
                          ? unitLabel(unit, anime)
                          : '${unitLabel(unit, anime)} · $progress/$total',
                      style: context.textTheme.labelSmall?.copyWith(
                        color: scheme.onPrimaryContainer.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                anime
                    ? Icons.play_circle_fill_rounded
                    : Icons.menu_book_rounded,
                size: 36,
                color: scheme.onPrimaryContainer,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
