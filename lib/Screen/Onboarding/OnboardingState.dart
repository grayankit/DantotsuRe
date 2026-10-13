import 'package:flutter/material.dart';

import '../../Core/State/State.dart';
import '../../Core/ThemeManager/ThemeController.dart';
import '../../Utils/Animation/WidgetAnimations.dart';
import '../../Widgets/Components/ScreenState.dart';
import '../Login/LoginScreen.dart';

class OnboardingState extends ScreenState {
  static const pageCount = 4;

  ThemeController get theme => find();

  final controller = PageController();
  final page = 0.live;

  bool get isFirst => page.value == 0;
  bool get isLast => page.value == pageCount - 1;

  void next() {
    if (isLast) return finish();
    go(page.value + 1);
  }

  void back() {
    if (!isFirst) go(page.value - 1);
  }

  void go(int index) => controller.animateToPage(
    index,
    duration: animDuration(420),
    curve: Curves.easeOutCubic,
  );

  void finish() => Navigator.of(
    context,
  ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));

  @override
  void onClose() {
    controller.dispose();
    super.onClose();
  }
}
