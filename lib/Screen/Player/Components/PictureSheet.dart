import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../Core/Player/ColorPresets.dart';
import '../../../Core/Player/PlayerSettings.dart';
import '../../../Core/State/State.dart';
import '../../../Core/ThemeManager/LanguageSwitcher.dart';
import '../../../Widgets/Components/AppControls.dart';
import '../../../Widgets/Components/AppSheet.dart';
import 'ColorSheet.dart';
import 'ShaderSheet.dart';

class PictureSheet extends StatefulWidget {
  final PlayerSettings Function() settings;
  final ShaderPick onPick;
  final Future<void> Function() onPreview;
  final Uint8List? frame;
  final Future<void> Function(ColorValues values) onColor;
  final Live<String?>? problem;

  const PictureSheet({
    super.key,
    required this.settings,
    required this.onPick,
    required this.onPreview,
    required this.frame,
    required this.onColor,
    this.problem,
  });

  @override
  State<PictureSheet> createState() => _PictureSheetState();
}

class _PictureSheetState extends State<PictureSheet> {
  final _tab = 0.live;

  @override
  Widget build(BuildContext context) => AppSheet(
    title: getString.playerPicture,
    heightFactor: 0.85,
    child: Watch(() {
      final tab = _tab.value;
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: AppSegmented<int>(
              value: tab,
              onChanged: (v) => _tab.value = v,
              segments: [
                AppSegment(0, label: getString.playerShaders),
                AppSegment(1, label: getString.playerColors),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.tonalIcon(
                onPressed: widget.onPreview,
                icon: const Icon(Icons.preview_rounded),
                label: Text(getString.playerShadersPreview),
              ),
            ),
          ),
          Expanded(
            child: tab == 0
                ? ShaderSheet(
                    key: const ValueKey('picture-shaders'),
                    embedded: true,
                    settings: widget.settings,
                    onPick: widget.onPick,
                    problem: widget.problem,
                  )
                : ColorSheet(
                    key: const ValueKey('picture-colors'),
                    embedded: true,
                    initial: widget.settings().color,
                    frame: widget.frame,
                    onChange: widget.onColor,
                  ),
          ),
        ],
      );
    }),
  );
}
