import 'dart:async';

import 'package:flutter/material.dart';

import '../../../Core/Media/ResumeStore.dart';
import '../../../Core/Services/MediaService.dart';
import '../../../Core/State/State.dart';
import '../../../Core/ThemeManager/LanguageSwitcher.dart';
import '../../../Utils/Extensions/Responsive.dart';
import '../../../Utils/Nav/DpadLayers.dart';
import '../../../Core/ThemeManager/CardStyleController.dart';
import '../../../Model/CardStyle.dart';
import '../../../Utils/Extensions/CardStyleMetrics.dart';
import '../../../Widgets/Shelf/PosterCard.dart';
import '../../../Widgets/Components/Clickable.dart';
import '../../../Widgets/Shelf/ShelfFrame.dart';
import '../../Feed/ResumeLauncher.dart';
import '../../Player/Components/PlayerSeekBar.dart';

class ResumeShelf extends StatefulWidget {
  final MediaService service;

  const ResumeShelf({super.key, required this.service});

  @override
  State<ResumeShelf> createState() => _ResumeShelfState();
}

class _ResumeShelfState extends State<ResumeShelf> {
  @override
  void initState() {
    super.initState();
    unawaited(ResumeStore.verify(widget.service));
  }

  @override
  Widget build(BuildContext context) => Watch(() => _build(context));

  Widget _build(BuildContext context) {
    ResumeStore.entries.length;
    final list = ResumeStore.visible(widget.service);
    if (list.isEmpty) return const SizedBox.shrink();
    final base = tryFind<CardStyleController>()?.current ?? const CardStyle();
    final style = base.copyWith(
      size: CardSize.custom,
      customScale: base.scale * 1.7,
      aspect: 9 / 16,
      titleLines: 1,
    );
    return ShelfFrame(
      title: getString.resumeTitle,
      child: DpadRow(
        child: SizedBox(
          height: style.itemHeight,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: Dimens.cardPad),
            itemCount: list.length,
            separatorBuilder: (_, _) => SizedBox(width: Dimens.gap),
            itemBuilder: (context, i) => _ResumeCard(
              key: ValueKey(list[i].slot),
              entry: list[i],
              style: style,
              onTap: () => openResume(context, widget.service, list[i]),
            ),
          ),
        ),
      ),
    );
  }
}

class _ResumeCard extends StatelessWidget {
  final ResumeEntry entry;
  final CardStyle style;
  final VoidCallback onTap;

  const _ResumeCard({
    super.key,
    required this.entry,
    required this.style,
    required this.onTap,
  });

  String _number() => entry.number == entry.number.roundToDouble()
      ? '${entry.number.toInt()}'
      : '${entry.number}';

  String _unit() => entry.isWatch
      ? getString.watchEpisodeNumber(_number())
      : getString.watchChapterNumber(_number());

  String _left() => entry.isWatch
      ? getString.resumeAt(formatClock(entry.duration - entry.position))
      : getString.resumePage(entry.position + 1, entry.duration);

  @override
  Widget build(BuildContext context) => SizedBox(
    width: style.itemWidth,
    child: Stack(
      children: [
        PosterCard(
          title: entry.mediaTitle,
          subtitle: '${_unit()}  •  ${_left()}',
          imageUrl: entry.thumbnail,
          progress: entry.fraction.clamp(0.0, 1.0),
          progressText: _left(),
          style: style,
          onTap: onTap,
          onLongPress: () => ResumeStore.remove(entry),
        ),
        Positioned(
          top: 6,
          right: 6,
          child: Clickable(
            onTap: () => ResumeStore.remove(entry),
            child: Tooltip(
              message: getString.resumeRemove,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: const Padding(
                  padding: EdgeInsets.all(5),
                  child: Icon(
                    Icons.close_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
