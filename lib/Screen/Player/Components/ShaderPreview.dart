import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:path/path.dart' as p;

import '../../../Core/Player/MpvFiles.dart';
import '../../../Core/Player/PlayerSettings.dart';
import '../../../Core/State/State.dart';
import '../../../Core/ThemeManager/LanguageSwitcher.dart';
import '../../../Logger.dart';
import '../../../Utils/Functions/NavigateToScreen.dart';
import '../../../Core/Player/ColorPresets.dart';
import '../../../Core/Player/ColorShader.dart';
import 'ColorSheet.dart';
import 'ShaderSheet.dart';
import '../../../Utils/Animation/WidgetAnimations.dart';
import '../../../Utils/Extensions/ContextExtensions.dart';

class ShaderPreview extends StatefulWidget {
  final Uint8List frame;
  final PlayerSettings settings;
  final ShaderPick onUse;
  final Future<void> Function(ColorValues values) onColor;
  final VoidCallback? onManage;

  const ShaderPreview({
    super.key,
    required this.frame,
    required this.settings,
    required this.onUse,
    required this.onColor,
    this.onManage,
  });

  @override
  State<ShaderPreview> createState() => _ShaderPreviewState();
}

class _ShaderPreviewState extends State<ShaderPreview> {
  late final Player _player;
  late final VideoController _video;
  late final Player _plain;
  late final VideoController _plainVideo;
  final _split = 0.5.live;
  final _problem = Live<String?>(null);
  StreamSubscription<PlayerLog>? _log;
  final _profile = 'MID-END'.live;
  final _chosen = ''.live;
  late final _color = widget.settings.color.live;
  final _ready = false.live;
  final _controls = true.live;
  final _adjust = false.live;
  Timer? _colorTimer;
  File? _file;

  @override
  void initState() {
    super.initState();
    final s = widget.settings;
    _profile.value = shaderProfiles.containsKey(s.shaderProfile)
        ? s.shaderProfile
        : 'MID-END';
    _chosen.value =
        s.shaders && shaderProfiles[_profile.value]!.containsKey(s.shader)
        ? s.shader
        : '';
    _player = Player(
      configuration: const PlayerConfiguration(logLevel: MPVLogLevel.warn),
    );
    _video = VideoController(
      _player,
      configuration: const VideoControllerConfiguration(hwdec: 'no'),
    );
    _plain = Player(
      configuration: const PlayerConfiguration(logLevel: MPVLogLevel.warn),
    );
    _plainVideo = VideoController(
      _plain,
      configuration: const VideoControllerConfiguration(hwdec: 'no'),
    );
    _log = _player.stream.log.listen((e) {
      final text = e.text.toLowerCase();
      if ((e.level == 'error' || e.level == 'warn') &&
          (text.contains('shader') ||
              text.contains('glsl') ||
              text.contains('hook'))) {
        _problem.value = e.text.trim();
      }
    });
    unawaited(_start());
  }

  @override
  void dispose() {
    _colorTimer?.cancel();
    unawaited(_log?.cancel());
    unawaited(_player.dispose());
    unawaited(_plain.dispose());
    final file = _file;
    if (file != null) unawaited(file.delete().catchError((_) => file));
    super.dispose();
  }

  NativePlayer? get _native {
    final platform = _player.platform;
    return platform is NativePlayer ? platform : null;
  }

  Future<void> _start() async {
    try {
      final dir = Directory.systemTemp;
      final file = File(
        p.join(
          dir.path,
          'dartotsu_shader_preview_${DateTime.now().millisecondsSinceEpoch}.png',
        ),
      );
      await file.writeAsBytes(widget.frame, flush: true);
      _file = file;
      final mpv = _native;
      await mpv?.setProperty('image-display-duration', 'inf');
      await mpv?.setProperty('keep-open', 'yes');
      await mpv?.setProperty('vf', 'scale=w=iw/2:h=ih/2');
      final plain = _plain.platform;
      if (plain is NativePlayer) {
        await plain.setProperty('image-display-duration', 'inf');
        await plain.setProperty('keep-open', 'yes');
        await plain.setProperty('vf', 'scale=w=iw/2:h=ih/2');
        await plain.setProperty('glsl-shaders', '');
      }
      await _apply();
      await _plain.open(Media(file.path), play: true);
      await _player.open(Media(file.path), play: true);
      if (mounted) _ready.value = true;
    } catch (e) {
      logger('Shader preview failed: $e', tag: 'MPV');
    }
  }

  Future<void> _apply() async {
    final mpv = _native;
    if (mpv == null) return;
    final name = _chosen.value;
    final files = name.isEmpty
        ? const <String>[]
        : shaderFilesOf(_profile.value, name, const []);
    final dir = await MpvFiles.shadersDir();
    final paths = shaderPaths(dir.path, files);
    final color = await colorShaderPath(_color.value);
    if (color != null) paths.add(color);
    try {
      await mpv.setProperty('glsl-shaders', joinShaders(paths));
    } catch (e) {
      logger('Shader preview apply failed: $e', tag: 'MPV');
    }
  }

  void _pick(String name) {
    _chosen.value = name;
    unawaited(_reload());
  }

  void _pickColor(ColorValues values) {
    _color.value = values;
    _colorTimer?.cancel();
    _colorTimer = Timer(const Duration(milliseconds: 90), () {
      if (mounted) unawaited(_reload());
    });
  }

  Widget _slider(
    String label,
    int value,
    ColorValues Function(int v) build,
  ) => Row(
    children: [
      SizedBox(
        width: 92,
        child: Text(
          label,
          style: context.textTheme.bodySmall?.copyWith(color: Colors.white70),
        ),
      ),
      Expanded(
        child: Slider(
          value: value.toDouble(),
          min: -100,
          max: 100,
          divisions: 100,
          onChanged: (v) => _pickColor(build(v.round())),
        ),
      ),
      SizedBox(
        width: 34,
        child: Text(
          '$value',
          textAlign: TextAlign.end,
          style: context.textTheme.bodySmall?.copyWith(color: Colors.white70),
        ),
      ),
    ],
  );

  Future<void> _reload() async {
    await _apply();
    final file = _file;
    if (file == null || !mounted) return;
    _problem.value = null;
    await _player.open(Media(file.path), play: true);
  }

  Future<void> _use() async {
    await widget.onUse(_profile.value, _chosen.value, null);
    await widget.onColor(_color.value);
    if (mounted) popPage(context);
  }

  @override
  Widget build(BuildContext context) => Watch(() => _build(context));

  Widget _build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final profile = _profile.value;
    final chosen = _chosen.value;
    final names = shaderProfiles[profile]!.keys.toList();
    final controls = _controls.value;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          LayoutBuilder(
            builder: (context, box) => GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _controls.value = !_controls.value,
              onHorizontalDragUpdate: (d) => _split.value =
                  (d.localPosition.dx / box.maxWidth).clamp(0.0, 1.0),
              child: Watch(() {
                final at = _split.value;
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    Video(
                      controller: _video,
                      controls: null,
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.medium,
                    ),
                    ClipRect(
                      clipper: _LeftClip(at),
                      child: Video(
                        controller: _plainVideo,
                        controls: null,
                        fit: BoxFit.contain,
                        filterQuality: FilterQuality.medium,
                      ),
                    ),
                    Positioned(
                      left: box.maxWidth * at - 1,
                      top: 0,
                      bottom: 0,
                      child: Container(width: 2, color: Colors.white),
                    ),
                    Positioned(
                      left: box.maxWidth * at - 20,
                      top: box.maxHeight / 2 - 20,
                      child: const DecoratedBox(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(8),
                          child: Icon(
                            Icons.compare_arrows_rounded,
                            color: Colors.black,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 12,
                      top: 72,
                      child: _tag(getString.playerShadersOriginal),
                    ),
                    Positioned(
                      right: 12,
                      top: 72,
                      child: _tag(
                        _chosen.value.isEmpty
                            ? getString.playerShadersOff
                            : _chosen.value,
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
          if (_problem.value != null)
            Positioned(
              left: 12,
              right: 12,
              top: 110,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Text(
                    _problem.value!,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          if (!_ready.value)
            const Center(child: CircularProgressIndicator(color: Colors.white)),
          AnimatedOpacity(
            opacity: controls ? 1 : 0,
            duration: animDuration(200),
            child: IgnorePointer(
              ignoring: !controls,
              child: Column(
                children: [
                  _top(context, chosen),
                  const Spacer(),
                  _bottom(context, scheme, profile, chosen, names),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tag(String text) => DecoratedBox(
    decoration: BoxDecoration(
      color: Colors.black.withValues(alpha: 0.6),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: Text(
        text,
        style: context.textTheme.bodySmall?.copyWith(color: Colors.white),
      ),
    ),
  );

  Widget _top(BuildContext context, String chosen) => DecoratedBox(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xCC000000), Color(0x00000000)],
      ),
    ),
    child: SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 4, 8, 20),
        child: Row(
          children: [
            IconButton(
              color: Colors.white,
              icon: const Icon(Icons.close_rounded),
              onPressed: () => popPage(context),
            ),
            Expanded(
              child: Text(
                chosen.isEmpty ? getString.playerShadersOff : chosen,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (widget.onManage != null)
              IconButton(
                color: Colors.white,
                tooltip: getString.playerShaders,
                icon: const Icon(Icons.tune_rounded),
                onPressed: widget.onManage,
              ),
            FilledButton.icon(
              onPressed: _use,
              icon: const Icon(Icons.check_rounded),
              label: Text(getString.playerShadersUse),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _bottom(
    BuildContext context,
    ColorScheme scheme,
    String profile,
    String chosen,
    List<String> names,
  ) => DecoratedBox(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0x00000000), Color(0xCC000000)],
      ),
    ),
    child: SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 24, 12, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final key in shaderProfiles.keys)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(key),
                        selected: key == profile,
                        onSelected: (_) {
                          _profile.value = key;
                          _pick('');
                        },
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final name in ['', ...names])
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(
                          name.isEmpty ? getString.playerShadersOff : name,
                        ),
                        selected: chosen == name,
                        onSelected: (_) => _pick(name),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final key in colorPresets.keys)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        avatar: const Icon(Icons.palette_rounded, size: 16),
                        label: Text(colorPresetLabel(key)),
                        selected: presetOf(_color.value) == key,
                        onSelected: (_) => _pickColor(colorPresets[key]!),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ActionChip(
                      avatar: const Icon(Icons.tune_rounded, size: 16),
                      label: Text(getString.playerColorAdjust),
                      onPressed: () => _adjust.value = !_adjust.value,
                    ),
                  ),
                ],
              ),
            ),
            if (_adjust.value) ...[
              const SizedBox(height: 4),
              _slider(
                getString.playerColorBrightness,
                _color.value.brightness,
                (x) => _color.value.copyWith(brightness: x),
              ),
              _slider(
                getString.playerColorContrast,
                _color.value.contrast,
                (x) => _color.value.copyWith(contrast: x),
              ),
              _slider(
                getString.playerColorSaturation,
                _color.value.saturation,
                (x) => _color.value.copyWith(saturation: x),
              ),
              _slider(
                getString.playerColorGamma,
                _color.value.gamma,
                (x) => _color.value.copyWith(gamma: x),
              ),
              _slider(
                getString.playerColorHue,
                _color.value.hue,
                (x) => _color.value.copyWith(hue: x),
              ),
            ],
          ],
        ),
      ),
    ),
  );
}

class _LeftClip extends CustomClipper<Rect> {
  final double fraction;

  const _LeftClip(this.fraction);

  @override
  Rect getClip(Size size) =>
      Rect.fromLTWH(0, 0, size.width * fraction, size.height);

  @override
  bool shouldReclip(_LeftClip old) => old.fraction != fraction;
}
