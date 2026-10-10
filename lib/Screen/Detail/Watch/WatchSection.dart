import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../Core/Services/MediaService.dart';
import '../../../Core/Services/Model/Media.dart';
import '../../../Core/State/State.dart';
import '../../../Core/ThemeManager/LanguageSwitcher.dart';
import '../../../Core/Watch/EpisodeMetaService.dart';
import '../../../Core/Watch/EpisodeUnits.dart';
import '../../../Core/Watch/WatchPrefs.dart';
import '../../../Utils/Animation/WidgetAnimations.dart';
import '../../../Utils/Extensions/ContextExtensions.dart';
import '../../../Utils/Extensions/Responsive.dart';
import '../../../Widgets/Components/ChoiceSheet.dart';
import '../../../Widgets/Components/CustomBottomDialog.dart';
import '../../../Widgets/Components/EmptyState.dart';
import '../../../Widgets/Components/ScreenState.dart';
import '../../../Widgets/Components/ScrollReveal.dart';
import 'Components/ContinueCard.dart';
import 'Components/RangeBar.dart';
import 'Components/SourceBar.dart';
import 'Components/SourceToolsSheet.dart';
import 'Components/UnitSheet.dart';
import 'Components/UnitTile.dart';
import 'Components/WatchOptionsSheet.dart';
import 'Components/WrongTitleSheet.dart';
import 'WatchState.dart';

class WatchSection extends StatefulWidget {
  final MediaService service;
  final Live<Media> media;
  final Mutations? mutations;

  const WatchSection({
    super.key,
    required this.service,
    required this.media,
    this.mutations,
  });

  @override
  State<WatchSection> createState() => _WatchSectionState();
}

class _WatchSectionState extends State<WatchSection>
    with ScreenStateHost<WatchSection, WatchState> {
  @override
  WatchState buildState() => WatchState(
    service: widget.service,
    media: widget.media,
    mutations: widget.mutations,
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
          SourceBar(
            source: state.source.value,
            status: state.status.value,
            busy: phase == WatchPhase.searching || phase == WatchPhase.loading,
            canFix: state.source.value != null,
            selectable: !state.fixedSource,
            onPick: _pickSource,
            onWrongTitle: _wrongTitle,
            onReset: state.resetMatch,
            onTools: _tools,
          ),
          SizedBox(height: Dimens.gap),
          _titleRow(context),
          SizedBox(height: Dimens.gapSm),
          AppSwitcher(
            child: KeyedSubtree(
              key: ValueKey(phase),
              child: switch (phase) {
                WatchPhase.sources ||
                WatchPhase.searching ||
                WatchPhase.loading => _skeleton(context),
                WatchPhase.ready => _units(context),
                WatchPhase.noSource => EmptyState(
                  icon: Icons.extension_off_rounded,
                  title: state.fixedSource
                      ? getString.watchSourceMissing
                      : getString.watchInstallSource(
                          state.anime ? getString.watching : getString.reading,
                        ),
                ),
                WatchPhase.empty => EmptyState(
                  icon: Icons.search_off_rounded,
                  title: state.match.value == null
                      ? getString.watchNothingFound
                      : (state.anime
                            ? getString.watchNoEpisodes
                            : getString.watchNoChapters),
                  actionLabel: state.fixedSource
                      ? null
                      : getString.watchWrongTitle,
                  onAction: state.fixedSource ? null : _wrongTitle,
                ),
                WatchPhase.failed => EmptyState(
                  icon: Icons.cloud_off_rounded,
                  failed: true,
                  title: getString.watchLoadFailed,
                  message: state.failure.value,
                  actionLabel: getString.retry,
                  onAction: state.start,
                ),
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _titleRow(BuildContext context) {
    final scheme = context.colorScheme;
    final count = state.units.length;
    return Row(
      children: [
        Expanded(
          child: Text(
            state.anime
                ? getString.watchEpisodeCount(count)
                : getString.watchChapterCount(count),
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        if (state.metaLoading.value)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: scheme.primary,
              ),
            ),
          ),
        if (state.anime)
          IconButton(
            tooltip: getString.watchMetaSource,
            onPressed: _pickMeta,
            icon: Icon(
              state.settings.value.metaSource == null
                  ? Icons.auto_awesome_rounded
                  : state.settings.value.metaSource == 'off'
                  ? Icons.hide_image_outlined
                  : Icons.image_search_rounded,
            ),
          ),
        IconButton(
          tooltip: getString.watchOptions,
          onPressed: () => showCustomBottomDialog<void>(
            context,
            WatchOptionsSheet(state: state),
          ),
          icon: const Icon(Icons.tune_rounded),
        ),
      ],
    );
  }

  Widget _units(BuildContext context) {
    final chunks = state.chunks;
    if (chunks.isEmpty) {
      return EmptyState(
        icon: Icons.search_off_rounded,
        title: state.anime
            ? getString.watchNoEpisodes
            : getString.watchNoChapters,
      );
    }
    final settings = state.settings.value;
    final index = state.chunk.value.clamp(0, chunks.length - 1);
    final shown = settings.reverse
        ? chunks[index].reversed.toList()
        : chunks[index];
    final next = state.next;
    final progress = state.progress;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (next != null) ...[
          ContinueCard(
            unit: next,
            anime: state.anime,
            started: progress > 0,
            media: state.current,
            onTap: () => _open(next),
          ),
          SizedBox(height: Dimens.gap),
        ],
        if (chunks.length > 1) ...[
          RangeBar(
            selected: index,
            onChanged: state.selectChunk,
            labels: [
              for (final c in chunks) '${c.first.number}-${c.last.number}',
            ],
          ),
          SizedBox(height: Dimens.gap),
        ],
        _layout(context, shown, settings.view, progress, next),
      ],
    );
  }

  Widget _tile(WatchUnit u, int view, int progress, WatchUnit? next) =>
      UnitTile(
        key: ValueKey('unit-${u.number}-${u.scanlator}'),
        unit: u,
        anime: state.anime,
        view: view,
        watched: u.isWatched(progress),
        next: identical(u, next),
        blur: watchBlurUnwatchedPref.rx.value,
        showDescription: watchShowDescriptionPref.rx.value,
        onTap: () => _open(u),
        onLongPress: watchMarkOnLongPressPref.rx.value
            ? () => u.isWatched(progress)
                  ? state.markUnwatched(u)
                  : state.markWatched(u)
            : null,
      );

  Widget _layout(
    BuildContext context,
    List<WatchUnit> shown,
    int view,
    int progress,
    WatchUnit? next,
  ) {
    if (view == 0) {
      return Column(
        children: [
          for (final (i, u) in shown.indexed)
            Padding(
              padding: EdgeInsets.only(bottom: Dimens.gapSm),
              child: ScrollReveal(
                delay: 30 * (i % 6),
                child: _tile(u, view, progress, next),
              ),
            ),
        ],
      );
    }
    return LayoutBuilder(
      builder: (context, box) {
        final gap = Dimens.gapSm;
        final target = view == 1 ? 190.0 : 64.0;
        final columns = (box.maxWidth / target).floor().clamp(
          view == 1 ? 2 : 4,
          16,
        );
        final width = (box.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final (i, u) in shown.indexed)
              SizedBox(
                width: width,
                height: view == 2 ? 48 : null,
                child: ScrollReveal(
                  delay: 30 * (i % 6),
                  child: _tile(u, view, progress, next),
                ),
              ),
          ],
        );
      },
    );
  }

  void _open(WatchUnit unit) => showCustomBottomDialog<void>(
    context,
    UnitSheet(state: state, unit: unit),
  );

  Future<void> _pickSource() async {
    final list = state.sources.toList();
    final current = state.source.value;
    if (list.isEmpty) return;
    final names = <String, int>{};
    for (final s in list) {
      names[s.name ?? ''] = (names[s.name ?? ''] ?? 0) + 1;
    }
    final picked = await showChoiceSheet<String>(
      context,
      title: getString.watchSource,
      selected: current?.id ?? '',
      options: [
        for (final s in list)
          ChoiceOption(
            s.id ?? '',
            (names[s.name ?? ''] ?? 0) > 1
                ? '${s.name} (${(s.lang ?? '').toUpperCase()})'
                : (s.name ?? ''),
          ),
      ],
    );
    if (picked == null || picked == current?.id) return;
    final next = list.where((s) => s.id == picked).firstOrNull;
    if (next != null) await state.selectSource(next);
  }

  Future<void> _pickMeta() async {
    final current = state.settings.value.metaSource ?? 'auto';
    final picked = await showChoiceSheet<String>(
      context,
      title: getString.watchMetaSource,
      selected: current,
      options: [
        ChoiceOption('auto', getString.watchMetaAuto),
        for (final p in EpisodeMetaService.ordered())
          if (EpisodeMetaService.enabled(p.id)) ChoiceOption(p.id, p.name),
        ChoiceOption('off', getString.watchMetaOff),
      ],
    );
    if (picked == null || picked == current) return;
    await state.setMetaSource(picked == 'auto' ? null : picked);
  }

  void _tools() {
    final source = state.source.value ?? state.current.sourceData;
    if (source == null) return;
    showCustomBottomDialog<void>(context, SourceToolsSheet(source: source));
  }

  void _wrongTitle() =>
      showCustomBottomDialog<void>(context, WrongTitleSheet(state: state));

  Widget _skeleton(BuildContext context) => Skeletonizer(
    child: Column(
      children: [
        for (var i = 0; i < 4; i++)
          Padding(
            padding: EdgeInsets.only(bottom: Dimens.gapSm),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: context.colorScheme.surfaceContainerLow,
                borderRadius: Dimens.borderSm,
              ),
              child: Padding(
                padding: EdgeInsets.all(Dimens.gapSm),
                child: Row(
                  children: [
                    const Bone.square(size: 72),
                    SizedBox(width: Dimens.gap),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Episode 12'),
                          Text('A loading episode title goes here'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    ),
  );
}
