import 'dart:async';

import 'package:flutter/material.dart';
import 'package:webview_all/webview_all.dart';

import '../../../Api/Discord/BaseDiscordRPC.dart';
import '../../../Api/Discord/Mobile/MobileRPC.dart';
import '../../../Api/Discord/Mobile/TokenManager.dart';
import '../../../Core/State/State.dart';
import '../../../Core/ThemeManager/LanguageSwitcher.dart';
import '../../../Logger.dart';
import '../../../Utils/Functions/SnackBar.dart';
import '../../../Widgets/Components/ScreenState.dart';

class DiscordLoginState extends ScreenState {
  static const loginUrl = 'https://discord.com/login';

  final controller = WebViewController();
  final progress = 0.0.live;

  bool _done = false;
  bool _checking = false;

  @override
  void onInit() {
    unawaited(_setUp());
  }

  Future<void> _setUp() async {
    final c = controller;
    await c.setJavaScriptMode(JavaScriptMode.unrestricted);
    await c.setBackgroundColor(Colors.transparent);
    try {
      await c.clearLocalStorage();
      await c.clearCache();
    } catch (e, st) {
      logError('DiscordLogin', e, st);
    }
    await c.addUserScript(
      const WebViewUserScript(
        source:
            'try { window.__dartotsuStorage = window.localStorage; } catch (e) {}',
      ),
    );
    await c.setNavigationDelegate(
      NavigationDelegate(
        onProgress: (percent) => progress.value = percent / 100,
        onPageFinished: (url) {
          progress.value = 1;
          unawaited(_check(url));
        },
        onUrlChange: (change) {
          final url = change.url;
          if (url != null) unawaited(_check(url));
        },
      ),
    );
    await c.loadRequest(Uri.parse(loginUrl));
  }

  Future<void> _check(String url) async {
    if (_done || _checking || !mounted) return;
    final uri = Uri.tryParse(url);
    if (uri == null || uri.host != 'discord.com') return;
    if (uri.path.startsWith('/login') || uri.path.startsWith('/register')) {
      return;
    }
    _checking = true;
    try {
      await Future<void>.delayed(const Duration(seconds: 2));
      final token = await _readToken();
      if (token == null || token.isEmpty) return;
      _done = true;
      MobileTokenManager.saveAuthToken(token);
      final rpc = tryFind<BaseDiscordRPC>();
      if (rpc is MobileRPC) await rpc.tokenManager.clear();
      snackString(getString.discordTokenSavedSnack);
      if (mounted) pop();
    } catch (e, st) {
      logError('DiscordLogin', e, st);
    } finally {
      _checking = false;
    }
  }

  Future<String?> _readToken() async {
    const sources = [
      "window.__dartotsuStorage ? window.__dartotsuStorage.getItem('token') : null",
      "(function(){var f=document.createElement('iframe');document.body.appendChild(f);"
          "var v=f.contentWindow.localStorage.getItem('token');f.remove();return v;})()",
    ];
    for (final source in sources) {
      try {
        final result = await controller.runJavaScriptReturningResult(source);
        final token = '$result'.trim().replaceAll('"', '');
        if (token.isNotEmpty && token != 'null' && token != 'undefined') {
          return token;
        }
      } catch (_) {}
    }
    return null;
  }
}
