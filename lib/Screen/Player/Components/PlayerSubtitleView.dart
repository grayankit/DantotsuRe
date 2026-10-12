import 'package:flutter/material.dart';

import '../../../Core/Fonts/AppFonts.dart';
import '../../../Core/Player/PlayerSettings.dart';
import '../../../Core/State/State.dart';
import '../../../Utils/Animation/WidgetAnimations.dart';

class PlayerSubtitleView extends StatelessWidget {
  final List<String> lines;
  final PlayerSettings settings;
  final bool controlsVisible;

  const PlayerSubtitleView({
    super.key,
    required this.lines,
    required this.settings,
    required this.controlsVisible,
  });

  @override
  Widget build(BuildContext context) => Watch(() => _build(context));

  Widget _build(BuildContext context) {
    fontsTick.value;
    final family = fontFamilyOf(settings.subtitleFont);
    final text = [
      for (final line in lines)
        if (line.trim().isNotEmpty) line.trim(),
    ].join('\n');
    if (text.isEmpty || !settings.showSubtitle) return const SizedBox.shrink();
    final outline = Color(settings.subtitleOutlineColor);
    return AnimatedPositioned(
      duration: animDuration(200),
      left: 16,
      right: 16,
      top: 0,
      bottom: controlsVisible
          ? 110 + settings.subtitleBottomPadding.toDouble()
          : 28 + settings.subtitleBottomPadding.toDouble(),
      child: IgnorePointer(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Color(settings.subtitleBackgroundColor),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: settings.subtitleSize.toDouble(),
                fontWeight:
                    FontWeight.values[settings.subtitleWeight.clamp(0, 8)],
                fontFamily: family,
                color: Color(settings.subtitleColor),
                shadows: [
                  Shadow(
                    offset: const Offset(1, 1),
                    blurRadius: 6,
                    color: outline,
                  ),
                  Shadow(
                    offset: const Offset(-1, -1),
                    blurRadius: 6,
                    color: outline,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
