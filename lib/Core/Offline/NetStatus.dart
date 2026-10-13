import 'dart:async';
import 'dart:io';

import '../State/State.dart';

class NetStatus extends AppController {
  static const _hosts = ['one.one.one.one', 'google.com'];

  final online = true.live;
  Timer? _timer;

  @override
  void onInit() {
    unawaited(check());
    _timer = Timer.periodic(const Duration(seconds: 15), (_) => check());
  }

  Future<bool> check() async {
    var ok = false;
    for (final host in _hosts) {
      try {
        final found = await InternetAddress.lookup(
          host,
        ).timeout(const Duration(seconds: 4));
        if (found.isNotEmpty) {
          ok = true;
          break;
        }
      } catch (_) {}
    }
    online.value = ok;
    return ok;
  }

  @override
  void onClose() {
    _timer?.cancel();
    online.close();
  }
}
