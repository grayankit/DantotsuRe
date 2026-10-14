import 'dart:async';

import 'package:rhttp/rhttp.dart';

class DownloadCancel {
  static const _keep = 64;

  final _tokens = <CancelToken>[];
  bool _cancelled = false;

  bool get isCancelled => _cancelled;

  CancelToken fresh() {
    final token = CancelToken();
    if (_cancelled) {
      unawaited(_stop(token));
      return token;
    }
    _tokens.add(token);
    if (_tokens.length > _keep) _tokens.removeRange(0, _tokens.length - _keep);
    return token;
  }

  Future<void> cancel() async {
    _cancelled = true;
    final all = [..._tokens];
    _tokens.clear();
    await Future.wait(all.map(_stop));
  }

  static Future<void> _stop(CancelToken token) async {
    try {
      await token.cancel();
    } catch (_) {}
  }
}
