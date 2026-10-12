import 'package:flutter/material.dart';

import '../../../Core/State/State.dart';
import '../../../Core/ThemeManager/LanguageSwitcher.dart';
import '../../../Utils/Animation/WidgetAnimations.dart';
import '../../../Utils/Extensions/ContextExtensions.dart';
import '../../../Utils/Functions/NavigateToScreen.dart';
import '../ReaderState.dart';
import 'ReaderSheets.dart';

class ReaderControls extends StatelessWidget {
  final ReaderState state;

  const ReaderControls({super.key, required this.state});

  @override
  Widget build(BuildContext context) => Watch(() => _build(context));

  Widget _icon(IconData icon, VoidCallback? onTap, {String? tooltip}) =>
      IconButton(
        onPressed: onTap,
        tooltip: tooltip,
        color: Colors.white,
        disabledColor: Colors.white30,
        style: IconButton.styleFrom(
          backgroundColor: Colors.white.withValues(alpha: 0.14),
          disabledBackgroundColor: Colors.white.withValues(alpha: 0.06),
        ),
        icon: Icon(icon),
      );

  Widget _build(BuildContext context) {
    final visible = state.controlsVisible.value;
    final curve = Curves.easeOutCubic;
    final duration = animDuration(220);
    return Stack(
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: IgnorePointer(
            ignoring: !visible,
            child: AnimatedSlide(
              offset: Offset(0, visible ? 0 : -1),
              duration: duration,
              curve: curve,
              child: _top(context),
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: IgnorePointer(
            ignoring: !visible,
            child: AnimatedSlide(
              offset: Offset(0, visible ? 0 : 1),
              duration: duration,
              curve: curve,
              child: _bottom(context),
            ),
          ),
        ),
      ],
    );
  }

  Widget _top(BuildContext context) {
    state.current.value;
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xE6000000), Color(0x00000000)],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 4, 8, 16),
          child: Row(
            children: [
              _icon(Icons.arrow_back_ios_new_rounded, () => popPage(context)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      state.chapterTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.titleSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      state.request.media.mainName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              _icon(
                state.autoScrolling.value
                    ? Icons.pause_circle_outline_rounded
                    : Icons.play_circle_outline_rounded,
                state.toggleAutoScroll,
                tooltip: state.autoScrolling.value
                    ? getString.readerAutoScrollStop
                    : getString.readerAutoScroll,
              ),
              _icon(
                Icons.format_list_numbered_rounded,
                () => showChapterList(
                  context,
                  request: state.request,
                  current: state.chapter,
                  onPick: state.openChapter,
                ),
                tooltip: getString.readerChapters,
              ),
              _icon(
                Icons.settings_rounded,
                () => showReaderOptions(context, state),
                tooltip: getString.readerSettingsTitle,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bottom(BuildContext context) {
    final count = state.pageCount;
    final page = state.page;
    final rtl = state.settings.reversed;
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0x00000000), Color(0xE6000000)],
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (state.autoScrolling.value) _speed(context),
              Directionality(
                textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
                child: Row(
                  children: [
                    _icon(
                      Icons.skip_previous_rounded,
                      state.hasPreviousChapter
                          ? state.openPreviousChapter
                          : null,
                      tooltip: getString.readerPreviousChapter,
                    ),
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: Text(
                        '${page + 1}',
                        style: context.textTheme.labelLarge?.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Expanded(
                      child: count < 2
                          ? const SizedBox.shrink()
                          : Slider(
                              min: 0,
                              max: (count - 1).toDouble(),
                              divisions: count - 1,
                              value: page.clamp(0, count - 1).toDouble(),
                              onChanged: (v) => state.go(
                                state.flatIndexOf(state.chapter, v.round()),
                              ),
                            ),
                    ),
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: Text(
                        '$count',
                        style: context.textTheme.labelLarge?.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                    ),
                    _icon(
                      Icons.skip_next_rounded,
                      state.hasNextChapter ? state.openNextChapter : null,
                      tooltip: getString.readerNextChapter,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _speed(BuildContext context) {
    final speed = state.settings.autoScrollSpeed.clamp(1, 10);
    void set(int v) =>
        state.updateSettings((s) => s.autoScrollSpeed = v.clamp(1, 10));
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _icon(Icons.remove_rounded, speed > 1 ? () => set(speed - 1) : null),
          SizedBox(
            width: 72,
            child: Text(
              '$speed',
              textAlign: TextAlign.center,
              style: context.textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          _icon(Icons.add_rounded, speed < 10 ? () => set(speed + 1) : null),
        ],
      ),
    );
  }
}
