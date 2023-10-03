import 'dart:developer';
import 'dart:isolate';

import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:foreground_service_poc/service/foreground_service/callback.dart';

class ForegroundService {
  ReceivePort? _receivePort;

  void initForegroundTask() {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'foreground_service',
        channelName: 'Flutter Notification',
        channelDescription: 'foreground_service_poc',
        channelImportance: NotificationChannelImportance.HIGH,
        priority: NotificationPriority.HIGH,
        iconData: const NotificationIconData(
          resType: ResourceType.mipmap,
          resPrefix: ResourcePrefix.ic,
          name: 'launcher',
        ),
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: true,
        playSound: false,
      ),
      foregroundTaskOptions: const ForegroundTaskOptions(
        interval: 5000,
        isOnceEvent: false,
        autoRunOnBoot: false,
        allowWakeLock: true,
        allowWifiLock: true,
      ),
    );
  }

  Future<bool> startForegroundTask() async {
    // Register the receivePort before starting the service.
    final ReceivePort? receivePort = FlutterForegroundTask.receivePort;
    final bool isRegistered = registerReceivePort(receivePort);
    if (!isRegistered) {
      log('Failed to register receivePort!');
      return false;
    }

    if (await FlutterForegroundTask.isRunningService) {
      return FlutterForegroundTask.restartService();
    } else {
      return FlutterForegroundTask.startService(
          notificationTitle: 'Flutter POC', notificationText: 'Foreground service activated', callback: startCallback);
    }
  }

  Future<bool> isRunningService() async {
    return await FlutterForegroundTask.isRunningService;
  }

  Future<ReceivePort?> newReceivePort() async => FlutterForegroundTask.receivePort;

  Future<bool> stopForegroundTask() {
    return FlutterForegroundTask.stopService();
  }

  bool registerReceivePort(ReceivePort? newReceivePort) {
    if (newReceivePort == null) {
      return false;
    }

    _closeReceivePort();
    _receivePort = newReceivePort;
    return _receivePort != null;
  }

  void _closeReceivePort() {
    _receivePort?.close();
    _receivePort = null;
  }
}
