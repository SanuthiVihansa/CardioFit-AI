import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:cardiofitai/screens/common/login_exchange_screen.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await AndroidAlarmManager.initialize();
  tz.initializeTimeZones();

  const AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings('@mipmap/launcher_icon');

  const InitializationSettings initializationSettings =
  InitializationSettings(android: initializationSettingsAndroid);

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  runApp(CardioFitAi());
}

class CardioFitAi extends StatelessWidget {
  CardioFitAi({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: LoginExchangeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
