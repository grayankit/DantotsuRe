import 'package:flutter/material.dart';

import '../../Core/Preferences/PrefManager.dart';
import '../../Widgets/Components/ScreenState.dart';
import '../MainScreen.dart';

class LoginState extends ScreenState {
  void enter() {
    PrefName.hasCompletedOnboarding.value = true;
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const MainScreen()));
  }
}
