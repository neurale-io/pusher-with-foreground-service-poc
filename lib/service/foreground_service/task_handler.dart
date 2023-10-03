import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:isolate';

import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:foreground_service_poc/config.dart';
import 'package:foreground_service_poc/constant.dart';
import 'package:foreground_service_poc/utils/pusher.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';

class ForegroundServiceHandler extends TaskHandler {
  SendPort? _sendPort;
  late PusherChannelsFlutter pusher;
  PusherChannel? channel;
  int count = 0;

  // Called when the task is started.
  @override
  void onStart(DateTime timestamp, SendPort? sendPort) async {
    try {
      pusher = PusherChannelsFlutter.getInstance();
      await Future.delayed(const Duration(seconds: 1), () async {
        await pusher.init(
            apiKey: PUSHER_APP_KEY,
            cluster: PUSHER_CLUSTER,
            onAuthorizer: onAuthorizer,
            onEvent: (event) {
              if (event.eventName == pusherEventNameStopService) {
                // Stop Foreground service
                FlutterForegroundTask.stopService();
              }
            });
        channel = await pusher.subscribe(channelName: pusherChannelName);
      });
      await pusher.connect();
    } catch (e) {
      log("pusher error: $e");
    }
    _sendPort = sendPort;
  }

  // Called every [interval] milliseconds in [ForegroundTaskOptions].
  @override
  void onRepeatEvent(DateTime timestamp, SendPort? sendPort) async {
    try {
      channel?.trigger(PusherEvent(
          channelName: pusherChannelName,
          eventName: pusherClientEventName,
          data: json.encode({"data": "Test message", "os": Platform.isIOS ? "IOS" : "Android", "count": count++})));
    } catch (e) {
      log("Error in sending data $e");
    }
  }

  // Called when the foreground service stopping time.
  @override
  void onDestroy(DateTime timestamp, SendPort? sendPort) async {
    await pusher.unsubscribe(channelName: pusherChannelName);
  }

  @override
  void onNotificationPressed() {
    FlutterForegroundTask.launchApp();
    _sendPort?.send('onNotificationPressed');
  }
}
