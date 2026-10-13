import 'dart:io';

import 'package:flutter_displaymode/flutter_displaymode.dart';

import '../../Core/Preferences/PrefManager.dart';
import '../../Logger.dart';

Future<void> applyRefreshRate() async {
  if (!Platform.isAndroid) return;
  try {
    if (PrefName.highRefreshRate.value) {
      await FlutterDisplayMode.setHighRefreshRate();
    } else {
      await FlutterDisplayMode.setPreferredMode(DisplayMode.auto);
    }
  } catch (e, st) {
    logError('DisplayMode', e, st);
  }
}
