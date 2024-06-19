// import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:get/get.dart';
// import 'package:intl/intl.dart';
// import 'package:timezone/data/latest.dart' as tz;
// import 'package:timezone/timezone.dart' as tz;
//
// class NotifyHelper {
//   FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//   FlutterLocalNotificationsPlugin();
//
//   int _notificationIdCounter = 0;
//
//
//   initializeNotification() async {
//     // Initialize time zones
//     tz.initializeTimeZones();
//
//     // iOS initialization settings
//     final IOSInitializationSettings initializationSettingsIOS =
//     IOSInitializationSettings(
//         requestSoundPermission: false,
//         requestBadgePermission: false,
//         requestAlertPermission: false,
//         onDidReceiveLocalNotification: onDidReceiveLocalNotification);
//
//     // Android initialization settings
//     final AndroidInitializationSettings initializationSettingsAndroid =
//     AndroidInitializationSettings('appicon');
//
//     final InitializationSettings initializationSettings = InitializationSettings(
//       iOS: initializationSettingsIOS,
//       android: initializationSettingsAndroid,
//     );
//
//     await flutterLocalNotificationsPlugin.initialize(
//       initializationSettings,
//       onSelectNotification: onSelectNotification,
//     );
//   }
//
//   Future onSelectNotification(String? payload) async {
//     if (payload != null) {
//       print('notification payload: $payload');
//     } else {
//       print("Notification Done");
//     }
//     Get.to(() => Container(color: Colors.white));
//   }
//
//   Future onDidReceiveLocalNotification(
//       int id, String? title, String? body, String? payload) async {
//     // display a dialog with the notification details, tap ok to go to another page
//     Get.dialog(Text("Welcome to Flutter"));
//   }
//
//   displayNotification({required String title, required String body}) async {
//     print("doing test");
//     var androidPlatformChannelSpecifics = AndroidNotificationDetails(
//       'your channel id',
//       'your channel name',
//       'your channel description',
//       importance: Importance.max,
//       priority: Priority.high,
//     );
//     var platformChannelSpecifics = NotificationDetails(
//       android: androidPlatformChannelSpecifics,
//       // iOS: iOSPlatformChannelSpecifics, // Uncomment and define iOSPlatformChannelSpecifics if needed for iOS
//     );
//     await flutterLocalNotificationsPlugin.show(
//       _generateUniqueReminderNo(),
//       title,
//       body,
//       platformChannelSpecifics,
//       payload: 'It could be anything you pass',
//     );
//   }
//
//   Future<void> scheduleNotificationsForMedicine(
//       {required String medicineName,
//         required String dosage,
//         required int pillIntake,
//         required String frequency,
//         required int days,
//         required DateTime startDate,
//         required List<String> selectedDays,
//         required String startTime}) async {
//     TimeOfDay start = _convertToTimeOfDay(startTime);
//     for (int i = 0; i < days; i++) {
//       DateTime scheduledDate = startDate.add(Duration(days: i));
//       if (selectedDays.contains(_getDayName(scheduledDate.weekday))) {
//         tz.TZDateTime scheduledDateTime =
//         tz.TZDateTime(tz.local, scheduledDate.year, scheduledDate.month,
//             scheduledDate.day, start.hour, start.minute);
//         await _scheduleNotification(
//             scheduledDateTime, medicineName, dosage, pillIntake);
//       }
//     }
//   }
//
//   Future<void> _scheduleNotification(
//       tz.TZDateTime scheduledDateTime,
//       String medicineName,
//       String dosage,
//       int pillIntake) async {
//     await flutterLocalNotificationsPlugin.zonedSchedule(
//       _generateUniqueReminderNo(),
//       'Medicine Reminder',
//       'It\'s time to take your medicine: $medicineName ($dosage). Take $pillIntake pills.',
//       scheduledDateTime,
//       const NotificationDetails(
//         android: AndroidNotificationDetails(
//           'your channel id',
//           'your channel name',
//           'your channel description',
//           importance: Importance.max,
//           priority: Priority.high,
//         ),
//       ),
//       androidAllowWhileIdle: true,
//       uiLocalNotificationDateInterpretation:
//       UILocalNotificationDateInterpretation.absoluteTime,
//       matchDateTimeComponents: DateTimeComponents.time,
//     );
//   }
//
//   int _generateUniqueReminderNo() {
//     return _notificationIdCounter++ % 2147483647; // Keeps IDs within 32-bit range
//   }
//
//   TimeOfDay _convertToTimeOfDay(String time) {
//     final DateFormat format12 = DateFormat.jm(); // 12-hour format
//     final DateFormat format24 = DateFormat.Hm(); // 24-hour format
//     try {
//       DateTime dateTime = format12.parse(time);
//       return TimeOfDay.fromDateTime(dateTime);
//     } catch (e) {
//       try {
//         DateTime dateTime = format24.parse(time);
//         return TimeOfDay.fromDateTime(dateTime);
//       } catch (e) {
//         print('Error parsing time: $e');
//         // Handle error or return a default value
//         return TimeOfDay.now();
//       }
//     }
//   }
//
//
//   String _getDayName(int dayNumber) {
//     switch (dayNumber) {
//       case DateTime.monday:
//         return "Mon";
//       case DateTime.tuesday:
//         return "Tue";
//       case DateTime.wednesday:
//         return "Wed";
//       case DateTime.thursday:
//         return "Thu";
//       case DateTime.friday:
//         return "Fri";
//       case DateTime.saturday:
//         return "Sat";
//       case DateTime.sunday:
//         return "Sun";
//       default:
//         return "";
//     }
//   }
// }