import 'package:flutter/material.dart';

import '../../../Core/State/State.dart';
import '../../../Core/Watch/EpisodeUnits.dart';
import '../../../Core/Watch/LocalProgress.dart';
import '../../../Core/Watch/WatchPrefs.dart';
import '../../../Utils/Extensions/Responsive.dart';
import '../../Detail/Watch/Components/RangeBar.dart';
import '../../Detail/Watch/Components/UnitLayout.dart';
import '../../Detail/Watch/Components/UnitTile.dart';
import '../PlayerState.dart';
import 'EpisodePanel.dart';

class PlayerEpisodes extends StatelessWidget {
  final PlayerState state;

  const PlayerEpisodes({super.key, required this.state});

  @override
  Widget build(BuildContext context) => Watch(() => _build(context));

  Widget _build(BuildContext context) {
    final record = state.record;
    final items = state.items;
    final current = state.index.value;
    if (record == null || items.any((i) => i.unit == null)) {
      return Column(
        children: [
          for (var i = 0; i < items.length; i++)
            EpisodeTile(state: state, index: i),
        ],
      );
    }
    final settings = record.watch;
    final view = settings.view;
    state.progressTick.value;
    final units = [for (final i in items) i.unit!];
    final progress = effectiveProgress(
      state.request.media?.userProgress ?? 0,
      units,
      record.playback,
    );
    final chunks = chunkUnits(units, watchChunkSizePref.rx.value);
    final playing = units[current];
    var chunk = state.chunk.value ?? 0;
    final home = chunks.indexWhere((c) => c.contains(playing));
    if (state.chunk.value == null && home >= 0) chunk = home;
    chunk = chunk.clamp(0, chunks.length - 1);
    final shown = settings.reverse
        ? chunks[chunk].reversed.toList()
        : chunks[chunk];
    final blur = watchBlurUnwatchedPref.rx.value;
    final description = watchShowDescriptionPref.rx.value;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (chunks.length > 1) ...[
          RangeBar(
            selected: chunk,
            onChanged: (i) => state.chunk.value = i,
            labels: [
              for (final c in chunks) '${c.first.number}-${c.last.number}',
            ],
          ),
          SizedBox(height: Dimens.gap),
        ],
        UnitLayout(
          units: shown,
          view: view,
          builder: (u) => UnitTile(
            key: ValueKey('player-unit-${u.number}-${u.scanlator}'),
            unit: u,
            anime: true,
            view: view,
            watched: u.isWatched(progress),
            progress: partialFraction(record.playback[u.number]),
            next: identical(u, playing),
            blur: blur,
            showDescription: description,
            onTap: () {
              final at = units.indexOf(u);
              if (at != state.index.value) state.loadItem(at);
            },
          ),
        ),
      ],
    );
  }
}
