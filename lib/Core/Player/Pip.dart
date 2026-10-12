import 'dart:io';

import 'package:flutter/services.dart';
import 'package:window_manager/window_manager.dart';

import '../../Logger.dart';

class PlayerPip {
  PlayerPip._();

  static const _channel = MethodChannel('dartotsu/pip');
  static void Function(bool active)? _onChanged;
  static bool _androidSupported = false;
  static bool _probed = false;

  static bool get isDesktop =>
      Platform.isLinux || Platform.isWindows || Platform.isMacOS;

  static bool get supported =>
      (Platform.isAndroid && _androidSupported) || isDesktop;

  static Rect? _saved;
  static bool _wasMaximized = false;

  static Future<void> init(void Function(bool active) onChanged) async {
    _onChanged = onChanged;
    if (!Platform.isAndroid) return;
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'changed') _onChanged?.call(call.arguments == true);
    });
    if (_probed) return;
    _probed = true;
    try {
      _androidSupported =
          await _channel.invokeMethod<bool>('supported') ?? false;
    } catch (e, st) {
      logError('PlayerPip', e, st, 'supported check failed');
    }
  }

  static void detach() {
    _onChanged = null;
    if (Platform.isAndroid) _channel.setMethodCallHandler(null);
  }

  static Future<bool> enter({int width = 16, int height = 9}) async {
    try {
      if (Platform.isAndroid) {
        return await _channel.invokeMethod<bool>('enter', {
              'width': width,
              'height': height,
            }) ??
            false;
      }
      if (!isDesktop) return false;
      _wasMaximized = await windowManager.isMaximized();
      _saved = await windowManager.getBounds();
      if (await windowManager.isFullScreen()) {
        await windowManager.setFullScreen(false);
      }
      if (_wasMaximized) await windowManager.unmaximize();
      await windowManager.setTitleBarStyle(
        TitleBarStyle.hidden,
        windowButtonVisibility: false,
      );
      await windowManager.setAlwaysOnTop(true);
      await windowManager.setAspectRatio(width / height);
      await windowManager.setSize(Size(480, 480 * height / width));
      _onChanged?.call(true);
      return true;
    } catch (e, st) {
      logError('PlayerPip', e, st, 'enter failed');
      return false;
    }
  }

  static Future<void> exit() async {
    if (!isDesktop) return;
    try {
      await windowManager.setAspectRatio(0);
      await windowManager.setAlwaysOnTop(false);
      await windowManager.setTitleBarStyle(TitleBarStyle.normal);
      final bounds = _saved;
      if (bounds != null) await windowManager.setBounds(bounds);
      if (_wasMaximized) await windowManager.maximize();
    } catch (e, st) {
      logError('PlayerPip', e, st, 'exit failed');
    }
    _saved = null;
    _onChanged?.call(false);
  }

  static Future<void> setAuto(bool on) async {
    if (!Platform.isAndroid || !_androidSupported) return;
    try {
      await _channel.invokeMethod<void>('setAuto', on);
    } catch (e, st) {
      logError('PlayerPip', e, st, 'setAuto failed');
    }
  }

  static Future<void> setRatio(int width, int height) async {
    if (!Platform.isAndroid || !_androidSupported) return;
    try {
      await _channel.invokeMethod<void>('setRatio', {
        'width': width,
        'height': height,
      });
    } catch (e, st) {
      logError('PlayerPip', e, st, 'setRatio failed');
    }
  }
}
