import 'dart:io';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../Core/State/State.dart';
import '../../Core/ThemeManager/ThemeController.dart';
import '../../Utils/Animation/WidgetAnimations.dart';
import '../../Widgets/Components/ScreenState.dart';
import '../Login/LoginScreen.dart';

class OnboardingState extends ScreenState {
  static final pageCount = Platform.isAndroid ? 5 : 4;

  static final permissions = <Permission>[
    Permission.notification,
    Permission.manageExternalStorage,
    Permission.requestInstallPackages,
    Permission.ignoreBatteryOptimizations,
  ];

  final granted = <Permission, bool>{}.liveMap;

  @override
  void onInit() {
    super.onInit();
    if (Platform.isAndroid) refreshPermissions();
  }

  Future<void> refreshPermissions() async {
    for (final p in permissions) {
      granted[p] = await p.isGranted;
    }
  }

  Future<void> grant(Permission p) async {
    final status = await p.request();
    granted[p] = status.isGranted;
    if (!status.isGranted && status.isPermanentlyDenied) await openAppSettings();
  }

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
