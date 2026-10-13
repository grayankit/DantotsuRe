import 'dart:io';

import 'package:flutter_foreground_task/flutter_foreground_task.dart';

import '../../Logger.dart';

class DownloadService {
  DownloadService._();

  static const _id = 7002;
  static bool _ready = false;
  static bool _running = false;

  static bool get supported => Platform.isAndroid;

  static Future<bool> sync({
    required bool active,
    required String title,
    required String text,
  }) async {
    if (!supported) return false;
    try {
      if (!active) {
        if (_running) {
          _running = false;
          await FlutterForegroundTask.stopService();
        }
        return true;
      }
      if (!_ready) {
        FlutterForegroundTask.init(
          androidNotificationOptions: AndroidNotificationOptions(
            channelId: 'dartotsu_downloads_service',
            channelName: 'Downloads',
            channelDescription: 'Keeps downloads running in the background',
            onlyAlertOnce: true,
          ),
          iosNotificationOptions: const IOSNotificationOptions(
            showNotification: false,
          ),
          foregroundTaskOptions: ForegroundTaskOptions(
            eventAction: ForegroundTaskEventAction.nothing(),
            allowWakeLock: true,
            allowWifiLock: true,
          ),
        );
        _ready = true;
      }
      if (!_running) {
        final result = await FlutterForegroundTask.startService(
          serviceId: _id,
          serviceTypes: [ForegroundServiceTypes.dataSync],
          notificationTitle: title,
          notificationText: text,
        );
        _running = result is ServiceRequestSuccess;
        return _running;
      }
      await FlutterForegroundTask.updateService(
        notificationTitle: title,
        notificationText: text,
      );
      return true;
    } catch (e) {
      logger('Download service failed: $e', tag: 'DOWNLOAD');
      return false;
    }
  }
}
