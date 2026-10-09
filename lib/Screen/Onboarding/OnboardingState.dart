import 'package:flutter/material.dart';

import '../../Core/State/State.dart';
import '../../Core/ThemeManager/ThemeController.dart';
import '../../Widgets/Components/ScreenState.dart';
import '../Login/LoginScreen.dart';

class OnboardingState extends ScreenState {
  ThemeController get theme => find();

  final page = 0.live;

  void finish() => Navigator.of(
    context,
  ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
}
