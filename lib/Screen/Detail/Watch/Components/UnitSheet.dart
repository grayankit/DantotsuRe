import 'package:flutter/material.dart';

import '../../../../Core/State/State.dart';
import '../../../../Core/ThemeManager/LanguageSwitcher.dart';
import '../../../../Core/Watch/EpisodeUnits.dart';
import '../../../../Utils/Extensions/ContextExtensions.dart';
import '../../../../Utils/Extensions/Responsive.dart';
import '../../../../Utils/Functions/NavigateToScreen.dart';
import '../../../../Widgets/Components/AppSheet.dart';
import '../../../../Widgets/Components/CachedNetworkImage.dart';
import '../WatchState.dart';
import 'UnitTile.dart';

class UnitSheet extends StatelessWidget {
  final WatchState state;
  final WatchUnit unit;
  final VoidCallback? onPlay;

  const UnitSheet({
    super.key,
    required this.state,
    required this.unit,
    this.onPlay,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    final anime = state.anime;
    return AppSheet(
      title: unitLabel(unit, anime),
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          Dimens.pagePad,
          0,
          Dimens.pagePad,
          Dimens.gapLg,
        ),
        child: Watch(() {
          final watched = unit.isWatched(state.progress);
          final meta = [
            if (unit.date != null) formatUnitDate(unit.date!),
            if (unit.runtime != null) '${unit.runtime} min',
            if (unit.rating != null && unit.rating! > 0)
              unit.rating!.toStringAsFixed(1),
            if (unit.scanlator != null) unit.scanlator!,
          ].join(' · ');
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (anime && unit.thumbnail != null) ...[
                ClipRRect(
                  borderRadius: Dimens.borderSm,
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: cachedNetworkImage(
                      imageUrl: unit.thumbnail,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  ),
                ),
                SizedBox(height: Dimens.gap),
              ],
              Text(
                unitTitle(unit, anime),
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (meta.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    meta,
                    style: context.textTheme.labelMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
              if (unit.filler || unit.recap)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Wrap(
                    spacing: 8,
                    children: [
                      if (unit.filler)
                        Chip(
                          label: Text(getString.watchFiller),
                          backgroundColor: scheme.tertiaryContainer,
                        ),
                      if (unit.recap)
                        Chip(
                          label: Text(getString.watchRecap),
                          backgroundColor: scheme.secondaryContainer,
                        ),
                    ],
                  ),
                ),
              if (unit.description?.isNotEmpty ?? false)
                Padding(
                  padding: EdgeInsets.only(top: Dimens.gap),
                  child: Text(
                    unit.description!,
                    style: context.textTheme.bodyMedium,
                  ),
                ),
              SizedBox(height: Dimens.gapLg),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () {
                        popPage(context);
                        onPlay?.call();
                      },
                      icon: Icon(
                        anime
                            ? Icons.play_arrow_rounded
                            : Icons.menu_book_rounded,
                      ),
                      label: Text(
                        anime ? getString.watchPlay : getString.watchRead,
                      ),
                    ),
                  ),
                  SizedBox(width: Dimens.gapSm),
                  Expanded(
                    child: FilledButton.tonalIcon(
                      onPressed: () {
                        popPage(context);
                        watched
                            ? state.markUnwatched(unit)
                            : state.markWatched(unit);
                      },
                      icon: Icon(
                        watched
                            ? Icons.remove_done_rounded
                            : Icons.done_all_rounded,
                      ),
                      label: Text(
                        watched
                            ? (anime
                                  ? getString.watchMarkUnwatched
                                  : getString.watchMarkUnread)
                            : (anime
                                  ? getString.watchMarkWatched
                                  : getString.watchMarkRead),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        }),
      ),
    );
  }
}
