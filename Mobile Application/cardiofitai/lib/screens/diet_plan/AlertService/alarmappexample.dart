import 'package:flutter/material.dart';
import 'package:flutter_alarm_clock/flutter_alarm_clock.dart';

class AlarmAppExample extends StatefulWidget {
  const AlarmAppExample({super.key});

  @override
  State<AlarmAppExample> createState() => _AlarmAppExampleState();
}

class _AlarmAppExampleState extends State<AlarmAppExample> {
  static Future<void> alarmCallback(int id) async {
    print("Alarm fired! ID: $id");
    // Add your alarm logic here
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter alarm clock example'),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Container(
              margin: const EdgeInsets.all(25),
              child: TextButton(
                child: const Text(
                  'Create alarm at 23:59',
                  style: TextStyle(fontSize: 20),
                ),
                onPressed: () {
                  FlutterAlarmClock.createAlarm(hour: 19, minutes: 25);
                },
              ),
            ),
            Container(
              margin: const EdgeInsets.all(25),
              child: const TextButton(
                onPressed: FlutterAlarmClock.showAlarms,
                child: Text(
                  'Show alarms',
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.all(25),
              child: TextButton(
                child: const Text(
                  'Create timer for 42 seconds',
                  style: TextStyle(fontSize: 20),
                ),
                onPressed: () {
                  FlutterAlarmClock.createTimer(length: 42);
                },
              ),
            ),
            Container(
              margin: const EdgeInsets.all(25),
              child: const TextButton(
                onPressed: FlutterAlarmClock.showTimers,
                child: Text(
                  'Show Timers',
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}