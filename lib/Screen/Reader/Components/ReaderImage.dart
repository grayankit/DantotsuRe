import 'dart:async';

import 'package:dartotsu_extension_bridge/dartotsu_extension_bridge.dart';
import 'package:flutter/material.dart';

import '../../../Core/Reader/ReaderImageLoader.dart';
import '../../../Core/State/State.dart';
import '../../../Core/ThemeManager/LanguageSwitcher.dart';
import '../../../Logger.dart';

class ReaderImage extends StatefulWidget {
  final PageUrl page;
  final BoxFit fit;
  final double? width;
  final double? height;
  final double placeholderHeight;

  const ReaderImage({
    super.key,
    required this.page,
    this.fit = BoxFit.contain,
    this.width,
    this.height,
    this.placeholderHeight = 480,
  });

  @override
  State<ReaderImage> createState() => _ReaderImageState();
}

class _ReaderImageState extends State<ReaderImage> {
  final attempt = 0.live;
  final slow = false.live;
  Timer? _slowTimer;
  bool _shown = false;
  bool _logged = false;

  @override
  void initState() {
    super.initState();
    _watch();
  }

  @override
  void didUpdateWidget(ReaderImage old) {
    super.didUpdateWidget(old);
    if (old.page.url != widget.page.url) {
      _shown = false;
      _logged = false;
      _watch();
    }
  }

  @override
  void dispose() {
    _slowTimer?.cancel();
    super.dispose();
  }

  void _watch() {
    slow.value = false;
    _slowTimer?.cancel();
    _slowTimer = Timer(const Duration(seconds: 8), () {
      if (mounted && !_shown) slow.value = true;
    });
  }

  Future<void> _retry() async {
    _shown = false;
    await ReaderImageLoader.forget(widget.page);
    if (!mounted) return;
    attempt.value++;
    _watch();
  }

  @override
  Widget build(BuildContext context) => Watch(() => _build(context));

  Widget _build(BuildContext context) {
    final media = MediaQuery.of(context);
    final decode = widget.fit == BoxFit.fitWidth
        ? (media.size.width * media.devicePixelRatio).round().clamp(320, 2400)
        : null;
    final base = ReaderImageLoader.providerFor(widget.page);
    final provider = decode == null
        ? base
        : ResizeImage(base, width: decode, policy: ResizeImagePolicy.fit);
    return Image(
      key: ValueKey('${widget.page.url}#${attempt.value}'),
      image: provider,
      fit: widget.fit,
      width: widget.width,
      height: widget.height,
      gaplessPlayback: true,
      filterQuality: FilterQuality.medium,
      frameBuilder: (context, child, frame, sync) {
        if (frame == null) return _box(_loading());
        _shown = true;
        if (!_logged) {
          _logged = true;
          logger('Reader image shown: ${widget.page.url}', tag: 'READER');
        }
        return child;
      },
      errorBuilder: (context, error, _) {
        _shown = true;
        return _box(
          _failure(context, ReaderImageLoader.errorOf(widget.page) ?? '$error'),
        );
      },
    );
  }

  Widget _loading() => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      const SizedBox(
        width: 40,
        height: 40,
        child: CircularProgressIndicator(strokeWidth: 4, color: Colors.white),
      ),
      if (slow.value) ...[
        const SizedBox(height: 12),
        Text(
          getString.readerSlowPage,
          style: const TextStyle(color: Colors.white54, fontSize: 12),
        ),
        const SizedBox(height: 8),
        _reload(),
      ],
    ],
  );

  Widget _reload() => FilledButton.tonalIcon(
    onPressed: _retry,
    icon: const Icon(Icons.refresh_rounded),
    label: Text(getString.retry),
  );

  Widget _failure(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.broken_image_rounded,
            color: Colors.white70,
            size: 40,
          ),
          const SizedBox(height: 8),
          Text(
            getString.readerPageFailed,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            text,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white60, fontSize: 12),
          ),
          const SizedBox(height: 12),
          _reload(),
        ],
      ),
    );
  }

  Widget _box(Widget child) => SizedBox(
    width: widget.width ?? double.infinity,
    height: widget.height ?? widget.placeholderHeight,
    child: Center(child: child),
  );
}
