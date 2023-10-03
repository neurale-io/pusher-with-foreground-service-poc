import 'package:flutter/material.dart';
import 'package:foreground_service_poc/service/foreground_service/service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  final ForegroundService _foregroundService = ForegroundService();
  bool _foregroundServiceRunning = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    init();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      updateForegroundServiceRunningState();
    }
  }

  Future<void> init() async {
    _foregroundService.initForegroundTask();
    await updateForegroundServiceRunningState();
  }

  Future<void> updateForegroundServiceRunningState() async {
    bool isRunning = await _foregroundService.isRunningService();
    setState(() {
      _foregroundServiceRunning = isRunning;
    });
  }

  Future<void> onBtnClicked() async {
    if (_foregroundServiceRunning) {
      await _foregroundService.stopForegroundTask();
    } else {
      await _foregroundService.startForegroundTask();
    }

    await updateForegroundServiceRunningState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Foreground service")),
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(_foregroundServiceRunning ? "Flutter Foreground Task Running" : "", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 80),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _foregroundServiceRunning ? Colors.red : Colors.blue,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(2)),
              ),
            ),
            onPressed: () => onBtnClicked(),
            child: const Text(
              'Start Foreground service',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          )
        ]),
      ),
    );
  }
}
