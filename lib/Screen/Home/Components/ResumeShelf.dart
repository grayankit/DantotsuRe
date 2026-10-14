import 'dart:async';

import 'package:flutter/material.dart';

import '../../Detail/Watch/Data/Media/ResumeStore.dart';
import '../../../Core/Services/MediaService.dart';
import '../../../Core/State/State.dart';
import '../../../Core/ThemeManager/LanguageSwitcher.dart';
import '../../../Core/ThemeManager/CardStyleController.dart';
import '../../../Model/CardStyle.dart';
import '../../../Widgets/Components/Clickable.dart';
import '../../../Widgets/Shelf/CardShelf.dart';
import '../../../Widgets/Shelf/CardShelfState.dart';
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
    final base = tryFind<CardStyleController>()?.current ?? CardStyle.cozy;
    final style = base.copyWith(
      size: CardSize.custom,
      customScale: base.scale * 1.7,
      aspect: 9 / 16,
      titleLines: 1,
    );
    return CardShelf(
      title: getString.resumeTitle,
      dataKey: list,
      styleOverride: style,
      items: [for (final entry in list) _item(entry)],
    );
  }

  ShelfCardItem _item(ResumeEntry entry) {
    final number = entry.number == entry.number.roundToDouble()
        ? '${entry.number.toInt()}'
        : '${entry.number}';
    final unit = entry.isWatch
        ? getString.watchEpisodeNumber(number)
        : getString.watchChapterNumber(number);
    final left = entry.isWatch
        ? getString.resumeAt(formatClock(entry.duration - entry.position))
        : getString.resumePage(entry.position + 1, entry.duration);
    return ShelfCardItem(
      id: entry.slot.toString(),
      title: entry.mediaTitle,
      subtitle: '$unit • $left',
      imageUrl: entry.thumbnail,
      progress: entry.fraction.clamp(0.0, 1.0),
      progressText: left,
      onTap: () => openResume(context, widget.service, entry),
      onLongPress: () => ResumeStore.remove(entry),
      cardBuilder: (card) => Stack(
        children: [
          card,
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
}
