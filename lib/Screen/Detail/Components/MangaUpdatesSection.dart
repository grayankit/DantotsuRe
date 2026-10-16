import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../Core/Services/Api/MangaUpdates.dart';
import '../../../Core/Services/MediaService.dart';
import '../../../Core/Services/Model/Media.dart';
import '../../../Core/State/State.dart';
import '../../../Core/ThemeManager/LanguageSwitcher.dart';
import '../../../Utils/Extensions/ContextExtensions.dart';
import '../../../Utils/Extensions/Responsive.dart';
import '../../../Widgets/Components/Clickable.dart';
import '../../../Widgets/Components/ScreenState.dart';
import '../../../Widgets/Components/SectionCard.dart';
import 'MangaUpdatesState.dart';

class MangaUpdatesSection extends StatefulWidget {
  final MediaService service;
  final Media media;

  const MangaUpdatesSection({
    super.key,
    required this.service,
    required this.media,
  });

  @override
  State<MangaUpdatesSection> createState() => _MangaUpdatesSectionState();
}

class _MangaUpdatesSectionState extends State<MangaUpdatesSection>
    with ScreenStateHost<MangaUpdatesSection, MangaUpdatesState> {
  @override
  MangaUpdatesState buildState() =>
      MangaUpdatesState(widget.service, widget.media);

  @override
  Widget build(BuildContext context) => Watch(() => _build(context));

  Widget _build(BuildContext context) {
    final info = state.info.value;
    final scheme = context.colorScheme;
    final text = context.textTheme;
    if (info == null) {
      return Padding(
        padding: EdgeInsets.fromLTRB(
          Dimens.pagePad,
          Dimens.gapLg,
          Dimens.pagePad,
          0,
        ),
        child: SectionCard(
          title: getString.muTitle,
          child: state.loading.value
              ? const LinearProgressIndicator()
              : Text(
                  getString.muNotFound,
                  style: text.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
        ),
      );
    }
    final s = info.series;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        Dimens.pagePad,
        Dimens.gapLg,
        Dimens.pagePad,
        0,
      ),
      child: SectionCard(
        title: getString.muTitle,
        trailing: IconButton(
          tooltip: getString.muOpen,
          visualDensity: VisualDensity.compact,
          onPressed: state.open,
          icon: const Icon(Icons.open_in_new_rounded, size: 20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                if (s.status != null)
                  _chip(
                    context,
                    s.status!,
                    scheme.primaryContainer,
                    scheme.onPrimaryContainer,
                  ),
                if (s.latestChapter != null)
                  _chip(
                    context,
                    getString.muLatest('${s.latestChapter}'),
                    scheme.secondaryContainer,
                    scheme.onSecondaryContainer,
                  ),
                if (s.licensed)
                  _chip(
                    context,
                    getString.muLicensed,
                    scheme.tertiaryContainer,
                    scheme.onTertiaryContainer,
                  ),
                if (s.rating != null)
                  _chip(
                    context,
                    getString.muRating(
                      s.rating!.toStringAsFixed(2),
                      '${s.votes ?? 0}',
                    ),
                    scheme.surfaceContainerHighest,
                    scheme.onSurface,
                  ),
              ],
            ),
            if (s.publishers.isNotEmpty) ...[
              SizedBox(height: Dimens.gap),
              Text(
                '${getString.muPublishers}: ${s.publishers.take(3).join(', ')}',
                style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
              ),
            ],
            SizedBox(height: Dimens.gap),
            Text(
              getString.muReleases,
              style: text.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            SizedBox(height: Dimens.gapSm),
            if (info.releases.isEmpty)
              Text(
                getString.muNoReleases,
                style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
              )
            else
              for (final r in info.releases.take(8)) _release(context, r),
            SizedBox(height: Dimens.gapSm),
            Text(
              getString.muCredit,
              style: text.labelSmall?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(BuildContext context, String label, Color bg, Color fg) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: context.textTheme.labelMedium?.copyWith(color: fg),
        ),
      );

  Widget _release(BuildContext context, MuRelease r) {
    final scheme = context.colorScheme;
    final text = context.textTheme;
    final group = r.groups.isEmpty ? null : r.groups.first;
    final date = r.date == null ? '' : DateFormat.yMMMd().format(r.date!);
    return Clickable(
      onTap: group == null ? null : () => state.openGroup(group),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          children: [
            SizedBox(
              width: 92,
              child: Text(
                r.number.isEmpty ? '–' : r.number,
                style: text.labelLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            Expanded(
              child: Text(
                group?.name ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: text.bodyMedium?.copyWith(
                  color: group == null
                      ? scheme.onSurfaceVariant
                      : scheme.primary,
                ),
              ),
            ),
            Text(
              date,
              style: text.labelSmall?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
