import 'package:flutter/material.dart';

import '../../../Utils/Extensions/ContextExtensions.dart';

class PlayerLevelIndicator extends StatelessWidget {
  final double value;
  final IconData icon;
  final bool shown;
  final bool left;

  const PlayerLevelIndicator({
    super.key,
    required this.value,
    required this.icon,
    required this.shown,
    required this.left,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return Positioned(
      top: 0,
      bottom: 0,
      left: left ? 28 : null,
      right: left ? null : 28,
      child: IgnorePointer(
        child: Center(
          child: AnimatedOpacity(
            opacity: shown ? 1 : 0,
            duration: const Duration(milliseconds: 200),
            child: Container(
              width: 44,
              height: 180,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: RotatedBox(
                        quarterTurns: 3,
                        child: LinearProgressIndicator(
                          value: value.clamp(0.0, 1.0),
                          minHeight: 8,
                          backgroundColor: Colors.white24,
                          color: scheme.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Icon(icon, color: Colors.white, size: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class PlayerSeekRipple extends StatelessWidget {
  final int seconds;
  final bool forward;

  const PlayerSeekRipple({
    super.key,
    required this.seconds,
    required this.forward,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      bottom: 0,
      left: forward ? null : 0,
      right: forward ? 0 : null,
      width: MediaQuery.sizeOf(context).width * 0.28,
      child: IgnorePointer(
        child: AnimatedOpacity(
          opacity: seconds > 0 ? 1 : 0,
          duration: const Duration(milliseconds: 180),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.horizontal(
                left: Radius.circular(forward ? 400 : 0),
                right: Radius.circular(forward ? 0 : 400),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  forward
                      ? Icons.fast_forward_rounded
                      : Icons.fast_rewind_rounded,
                  color: Colors.white,
                  size: 36,
                ),
                const SizedBox(height: 6),
                Text(
                  '${seconds}s',
                  style: context.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PlayerChip extends StatelessWidget {
  final String? text;
  final IconData icon;
  final Alignment alignment;
  final EdgeInsets margin;

  const PlayerChip({
    super.key,
    required this.text,
    required this.icon,
    this.alignment = Alignment.topCenter,
    this.margin = const EdgeInsets.only(top: 24),
  });

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return Positioned.fill(
      child: IgnorePointer(
        child: Align(
          alignment: alignment,
          child: Padding(
            padding: margin,
            child: AnimatedOpacity(
              opacity: text == null ? 0 : 1,
              duration: const Duration(milliseconds: 200),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: scheme.primary.withValues(alpha: 0.5),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, color: scheme.primary, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      text ?? '',
                      style: context.textTheme.labelLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
