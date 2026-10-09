import 'dart:ui';

import 'package:flutter/cupertino.dart';

// Only true touch drags scroll. Mouse and trackpad scroll via the wheel /
// two-finger gesture, which works regardless — listing them here makes a
// click with 1px of movement (kPrecisePointerPanSlop) lose the gesture arena
// to the scrollable, so taps silently do nothing.
const _dragDevices = {
  PointerDeviceKind.touch,
  PointerDeviceKind.stylus,
  PointerDeviceKind.invertedStylus,
  PointerDeviceKind.unknown,
  PointerDeviceKind.trackpad,
  PointerDeviceKind.mouse,
};

const bouncingPhysics = BouncingScrollPhysics(
  parent: AlwaysScrollableScrollPhysics(),
);

class AppScrollBehavior extends CupertinoScrollBehavior {
  const AppScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => _dragDevices;

  @override
  Widget buildScrollbar(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) => child;
}

Widget ScrollConfig(
  BuildContext context, {
  required Widget child,
  ScrollPhysics? physics,
}) {
  return ScrollConfiguration(
    behavior: ScrollConfiguration.of(context).copyWith(
      physics: physics ?? bouncingPhysics,
      scrollbars: false,
      dragDevices: _dragDevices,
    ),
    child: child,
  );
}

Widget CustomScrollConfig(
  BuildContext context, {
  required List<Widget> children,
  Axis scrollDirection = Axis.vertical,
  ScrollPhysics? physics,
  ScrollController? controller,
  bool shrinkWrap = false,
}) {
  return CustomScrollView(
    controller: controller,
    scrollBehavior: ScrollConfiguration.of(
      context,
    ).copyWith(scrollbars: false, dragDevices: _dragDevices),
    shrinkWrap: shrinkWrap,
    physics: physics ?? (shrinkWrap ? null : bouncingPhysics),
    scrollDirection: scrollDirection,
    slivers: children,
  );
}
