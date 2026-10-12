import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../Core/Fonts/AppFonts.dart';
import '../Engine/NovelText.dart';
import '../Engine/ReaderRequest.dart';
import '../Engine/ReaderSettings.dart';
import '../../../Core/State/State.dart';
import '../../../Core/ThemeManager/LanguageSwitcher.dart';
import '../../../Model/Setting.dart';
import '../../../Utils/Extensions/ContextExtensions.dart';
import '../../../Utils/Extensions/Responsive.dart';
import '../../../Utils/Functions/NavigateToScreen.dart';
import '../../../Widgets/Components/AppSheet.dart';
import '../../../Widgets/Components/CachedNetworkImage.dart';
import '../../../Widgets/Components/CustomBottomDialog.dart';
import '../../../Widgets/Components/EmptyState.dart';
import '../../../Widgets/Components/ScreenState.dart';
import '../../Settings/Categories/ReaderSettings.dart';
import '../../Settings/Widgets/SettingsGroup.dart';
import '../Components/BookmarksSheet.dart';
import '../Components/ReaderSheets.dart';
import 'NovelState.dart';
import '../../../Utils/Animation/WidgetAnimations.dart';

class NovelScreen extends StatefulWidget {
  final ReaderRequest request;

  const NovelScreen({super.key, required this.request});

  @override
  State<NovelScreen> createState() => _NovelScreenState();
}

class _NovelScreenState extends State<NovelScreen>
    with ScreenStateHost<NovelScreen, NovelState> {
  final _focus = FocusNode();

  @override
  NovelState buildState() => NovelState(widget.request);

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Watch(() => _build(context));

  (Color, Color) _colors(BuildContext context, String id) => switch (id) {
    'light' => (const Color(0xFFFAFAFA), const Color(0xFF1E1E1E)),
    'sepia' => (const Color(0xFFF4ECD8), const Color(0xFF5B4636)),
    'dark' => (const Color(0xFF1B1B1F), const Color(0xFFD7D7DC)),
    'black' => (Colors.black, const Color(0xFFBDBDBD)),
    _ => (context.colorScheme.surface, context.colorScheme.onSurface),
  };

  Widget _build(BuildContext context) {
    state.settingsVersion.value;
    fontsTick.value;
    final settings = state.settings;
    final (background, foreground) = _colors(context, settings.novelTheme);
    final body = state.loading.value
        ? const Center(child: CircularProgressIndicator())
        : state.error.value != null
        ? EmptyState(
            icon: Icons.error_outline_rounded,
            failed: true,
            title: getString.readerFailed,
            message: state.error.value,
            actionLabel: getString.retry,
            onAction: state.retry,
          )
        : _text(context, settings, foreground);
    return Theme(
      data: Theme.of(context).copyWith(
        iconTheme: IconThemeData(color: foreground),
        textTheme: Theme.of(
          context,
        ).textTheme.apply(bodyColor: foreground, displayColor: foreground),
      ),
      child: Scaffold(
        backgroundColor: background,
        body: KeyboardListener(
          focusNode: _focus,
          autofocus: true,
          onKeyEvent: _key,
          child: Stack(
            children: [
              Positioned.fill(child: body),
              if (!state.loading.value && state.error.value == null)
                Positioned.fill(
                  child: LayoutBuilder(
                    builder: (context, box) => GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTapUp: (d) {
                        if (!settings.novelTapPaging ||
                            state.controlsVisible.value) {
                          state.toggleControls();
                          return;
                        }
                        final x = d.localPosition.dx / box.maxWidth;
                        if (x < 0.25) {
                          state.pageBy(-1);
                        } else if (x > 0.75) {
                          state.pageBy(1);
                        } else {
                          state.toggleControls();
                        }
                      },
                    ),
                  ),
                ),
              _bar(context, background, foreground, top: true),
              _bar(context, background, foreground, top: false),
            ],
          ),
        ),
      ),
    );
  }

  Widget _text(BuildContext context, ReaderSettings s, Color foreground) {
    final blocks = state.blocks.toList();
    final base = TextStyle(
      fontFamily: fontFamilyOf(s.novelFont),
      fontSize: s.novelSize.toDouble(),
      height: s.novelLineHeight,
      color: foreground,
      fontWeight: s.novelBold ? FontWeight.w600 : FontWeight.w400,
      letterSpacing: s.novelLetterSpacing / 10,
    );
    final margin = s.novelMargin.toDouble();
    return SelectionArea(
      child: ListView.builder(
        controller: state.scroll,
        padding: EdgeInsets.fromLTRB(
          margin,
          MediaQuery.paddingOf(context).top + 56,
          margin,
          MediaQuery.paddingOf(context).bottom + 96,
        ),
        itemCount: blocks.length + 2,
        itemBuilder: (context, i) {
          if (i == 0) return _heading(context, base);
          if (i == blocks.length + 1) return _end(context);
          return _block(context, blocks[i - 1], base, s);
        },
      ),
    );
  }

  Widget _heading(BuildContext context, TextStyle base) => Padding(
    padding: EdgeInsets.only(bottom: Dimens.gapLg),
    child: Text(
      state.title,
      style: base.copyWith(
        fontSize: base.fontSize! * 1.4,
        fontWeight: FontWeight.w800,
      ),
    ),
  );

  Widget _block(
    BuildContext context,
    NovelBlock block,
    TextStyle base,
    ReaderSettings s,
  ) {
    final gap = s.novelParagraph.toDouble();
    switch (block) {
      case NovelParagraph p:
        final scale = switch (p.heading) {
          1 => 1.5,
          2 => 1.35,
          3 => 1.2,
          0 => 1.0,
          _ => 1.1,
        };
        return Padding(
          padding: EdgeInsets.only(bottom: gap, top: p.heading > 0 ? gap : 0),
          child: Text(
            p.heading == 0 && s.novelIndent ? '\u2003\u2003${p.text}' : p.text,
            textAlign: s.novelJustify ? TextAlign.justify : TextAlign.start,
            style: p.heading > 0
                ? base.copyWith(
                    fontSize: base.fontSize! * scale,
                    fontWeight: FontWeight.w700,
                  )
                : base,
          ),
        );
      case NovelPicture p:
        return Padding(
          padding: EdgeInsets.only(bottom: gap),
          child: cachedNetworkImage(
            imageUrl: p.url,
            fit: BoxFit.fitWidth,
            width: double.infinity,
          ),
        );
      case NovelRule():
        return Padding(
          padding: EdgeInsets.symmetric(vertical: gap),
          child: Divider(color: base.color?.withValues(alpha: 0.3)),
        );
    }
  }

  Widget _end(BuildContext context) => Padding(
    padding: EdgeInsets.only(top: Dimens.gapLg),
    child: Center(
      child: state.hasNext
          ? FilledButton.icon(
              onPressed: state.next,
              icon: const Icon(Icons.skip_next_rounded),
              label: Text(getString.readerNextChapter),
            )
          : Text(getString.readerLastChapter),
    ),
  );

  Widget _bar(
    BuildContext context,
    Color background,
    Color foreground, {
    required bool top,
  }) {
    final visible = state.controlsVisible.value;
    final bar = Material(
      color: background.withValues(alpha: 0.96),
      elevation: 2,
      child: SafeArea(
        top: top,
        bottom: !top,
        child: top ? _topRow(context) : _bottomRow(context),
      ),
    );
    return Positioned(
      top: top ? 0 : null,
      bottom: top ? null : 0,
      left: 0,
      right: 0,
      child: IgnorePointer(
        ignoring: !visible,
        child: AnimatedSlide(
          offset: visible ? Offset.zero : Offset(0, top ? -1 : 1),
          duration: animDuration(200),
          curve: Curves.easeOutCubic,
          child: bar,
        ),
      ),
    );
  }

  Widget _topRow(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 4),
    child: Row(
      children: [
        IconButton(
          onPressed: () => popPage(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                state.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                state.request.media.mainName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.bodySmall,
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: state.autoScrolling.value
              ? getString.readerAutoScrollStop
              : getString.readerAutoScroll,
          onPressed: state.toggleAutoScroll,
          icon: Icon(
            state.autoScrolling.value
                ? Icons.pause_circle_outline_rounded
                : Icons.play_circle_outline_rounded,
          ),
        ),
        IconButton(
          tooltip: state.bookmarked
              ? getString.readerBookmarkRemove
              : getString.readerBookmarkAdd,
          onPressed: state.toggleBookmark,
          icon: Icon(
            state.bookmarked
                ? Icons.bookmark_rounded
                : Icons.bookmark_border_rounded,
          ),
        ),
        if (state.record.bookmarks.isNotEmpty)
          IconButton(
            tooltip: getString.readerBookmarks,
            onPressed: () => showBookmarks(
              context,
              record: state.record,
              tick: state.bookmarkTick,
              detail: (b) => '${(b.position * 100 / b.total).round()}%',
              onOpen: state.openBookmark,
              onRemove: state.removeBookmark,
            ),
            icon: const Icon(Icons.bookmarks_outlined),
          ),
        IconButton(
          tooltip: getString.readerChapters,
          onPressed: () => showChapterList(
            context,
            request: state.request,
            current: state.index.value,
            onPick: state.openChapter,
          ),
          icon: const Icon(Icons.list_rounded),
        ),
        IconButton(
          tooltip: getString.readerSettingsTitle,
          onPressed: () => _options(context),
          icon: const Icon(Icons.tune_rounded),
        ),
      ],
    ),
  );

  Widget _bottomRow(BuildContext context) {
    final minutes = (state.wordsLeft / 230).ceil();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (state.autoScrolling.value) _speed(context),
          Row(
            children: [
              IconButton(
                tooltip: getString.readerPreviousChapter,
                onPressed: state.hasPrevious ? state.previous : null,
                icon: const Icon(Icons.skip_previous_rounded),
              ),
              Expanded(
                child: Slider(
                  value: state.fraction.value.clamp(0.0, 1.0),
                  onChanged: state.seekTo,
                ),
              ),
              IconButton(
                tooltip: getString.readerNextChapter,
                onPressed: state.hasNext ? state.next : null,
                icon: const Icon(Icons.skip_next_rounded),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              '${(state.fraction.value * 100).round()}%  ·  '
              '${getString.novelMinutesLeft(minutes)}',
              style: context.textTheme.labelMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _speed(BuildContext context) {
    final speed = state.settings.autoScrollSpeed.clamp(1, 10);
    void set(int v) =>
        state.updateSettings((s) => s.autoScrollSpeed = v.clamp(1, 10));
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: speed > 1 ? () => set(speed - 1) : null,
          icon: const Icon(Icons.remove_rounded),
        ),
        SizedBox(
          width: 72,
          child: Text(
            '$speed',
            textAlign: TextAlign.center,
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        IconButton(
          onPressed: speed < 10 ? () => set(speed + 1) : null,
          icon: const Icon(Icons.add_rounded),
        ),
      ],
    );
  }

  Future<void> _options(BuildContext context) => showCustomBottomDialog<void>(
    context,
    AppSheet(
      title: getString.readerSettingsTitle,
      heightFactor: 0.85,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(8, 0, 8, 24),
        child: Watch(() {
          state.settingsVersion.value;
          final perTitle = state.perTitle.value;
          return SettingsGroup(
            key: ValueKey(perTitle),
            settings: [
              Setting.switchType(
                name: getString.readerPerTitle,
                description: getString.readerPerTitleDesc,
                icon: Icons.bookmark_rounded,
                isChecked: perTitle,
                onSwitchChange: state.setPerTitle,
              ),
              ...novelReaderRows(
                context,
                settings: state.settings,
                update: state.updateSettings,
              ),
            ],
          );
        }),
      ),
    ),
  );

  void _key(KeyEvent event) {
    if (event is! KeyDownEvent) return;
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.space || key == LogicalKeyboardKey.pageDown) {
      state.pageBy(1);
    } else if (key == LogicalKeyboardKey.pageUp) {
      state.pageBy(-1);
    } else if (key == LogicalKeyboardKey.arrowRight) {
      state.next();
    } else if (key == LogicalKeyboardKey.arrowLeft) {
      state.previous();
    } else if (key == LogicalKeyboardKey.keyM) {
      state.toggleControls();
    }
  }
}
