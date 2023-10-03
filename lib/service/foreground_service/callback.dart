import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:foreground_service_poc/service/foreground_service/task_handler.dart';

@pragma('vm:entry-point')
Future<void> startCallback() async {
  // The setTaskHandler function must be called to handle the task in the background.
  WidgetsFlutterBinding.ensureInitialized();
  FlutterForegroundTask.setTaskHandler(ForegroundServiceHandler());
}