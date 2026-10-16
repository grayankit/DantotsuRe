import 'package:flutter/material.dart';

import '../../Core/State/State.dart';
import '../../Utils/Animation/WidgetAnimations.dart';

class ScrollReveal extends StatefulWidget {
  final Widget child;
  final int delay;

  const ScrollReveal({super.key, required this.child, this.delay = 0});

  @override
  State<ScrollReveal> createState() => _ScrollRevealState();
}

class _ScrollRevealState extends State<ScrollReveal> {
  ScrollPosition? _position;
  final _shown = false.live;
  int _tries = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final next = Scrollable.maybeOf(context)?.position;
    if (next == _position) return;
    _position?.removeListener(_check);
    _position = next?..addListener(_check);
    _tries = 0;
    WidgetsBinding.instance.addPostFrameCallback((_) => _check());
  }

  @override
  void dispose() {
    _position?.removeListener(_check);
    super.dispose();
  }

  void _check() {
    if (_shown.value || !mounted) return;
    final box = context.findRenderObject();
    final viewport = _position?.context.notificationContext?.findRenderObject();
    if (box is! RenderBox ||
        !box.attached ||
        viewport is! RenderBox ||
        !viewport.attached ||
        !box.hasSize ||
        !viewport.hasSize) {
      _retry();
      return;
    }
    final top = box.localToGlobal(Offset.zero, ancestor: viewport).dy;
    if (top < viewport.size.height) {
      _shown.value = true;
    } else {
      _retry();
    }
  }

  void _retry() {
    if (_tries++ > 40 || !mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) => _check());
    WidgetsBinding.instance.scheduleFrame();
  }

  @override
  Widget build(BuildContext context) => Watch(() {
    if (!_shown.value) return Opacity(opacity: 0, child: widget.child);
    return widget.child.animateFadeUp(
      begin: 0.08,
      delay: Duration(milliseconds: widget.delay),
      duration: 320,
    );
  });
}
