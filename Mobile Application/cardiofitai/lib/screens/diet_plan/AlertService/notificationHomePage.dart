import 'dart:async';
import 'package:alarm/alarm.dart';
import 'package:alarm/model/alarm_settings.dart';
import 'package:cardiofitai/models/user.dart';
import 'package:cardiofitai/screens/diet_plan/AlertService/medicineAlertScreen.dart';
import 'package:cardiofitai/screens/diet_plan/AlertService/ring.dart';
import 'package:cardiofitai/services/medicineReminderService.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_picker_timeline/date_picker_timeline.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationHomePage extends StatefulWidget {
  const NotificationHomePage(this.user, {super.key});

  final User user;

  @override
  State<NotificationHomePage> createState() => _NotificationHomePageState();
}

class _NotificationHomePageState extends State<NotificationHomePage> {
  List<DocumentSnapshot> _allAlerts = [];
  List<DocumentSnapshot> _filteredAlerts = [];
  late List<AlarmSettings> alarms;
  static StreamSubscription<AlarmSettings>? subscription;
  DateTime _selectedDate = DateTime.now();
  late BuildContext _buildContext;
  final dateController = TextEditingController();
  final timeController = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (Alarm.android) {
      checkAndroidNotificationPermission();
      checkAndroidScheduleExactAlarmPermission();
      loadAlarms();
    }
    getSavedAlerts();
    subscription ??= Alarm.ringStream.stream.listen(navigateToRingScreen);
  }

  void loadAlarms() {
    setState(() {
      alarms = Alarm.getAlarms();
      alarms.sort((a, b) => a.dateTime.isBefore(b.dateTime) ? 0 : 1);
    });
  }

  Future<void> checkAndroidNotificationPermission() async {
    final status = await Permission.notification.status;
    if (status.isDenied) {
      alarmPrint('Requesting notification permission...');
      final res = await Permission.notification.request();
      alarmPrint(
        'Notification permission ${res.isGranted ? '' : 'not '}granted',
      );
    }
  }

  Future<void> checkAndroidScheduleExactAlarmPermission() async {
    final status = await Permission.scheduleExactAlarm.status;
    alarmPrint('Schedule exact alarm permission: $status.');
    if (status.isDenied) {
      alarmPrint('Requesting schedule exact alarm permission...');
      final res = await Permission.scheduleExactAlarm.request();
      alarmPrint(
        'Schedule exact alarm permission ${res.isGranted ? '' : 'not'} granted',
      );
    }
  }

  Future<void> navigateToRingScreen(AlarmSettings alarmSettings) async {
    await Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) =>
            ExampleAlarmRingScreen(alarmSettings: alarmSettings),
      ),
    );
    loadAlarms();
  }

  Future<void> getSavedAlerts() async {
    QuerySnapshot querySnapshot =
    await MedicineReminderService.getAllUserReminder(widget.user.email);
    setState(() {
      _allAlerts = querySnapshot.docs;
      _filterAlertsForSelectedDate();
    });
  }

  Future<void> getSavedAlarms(int reminderNo) async {
    final QuerySnapshot alarmSnapshot = await FirebaseFirestore.instance
        .collection('alarms')
        .where('userEmail', isEqualTo: widget.user.email)
        .where('reminderNo', isEqualTo: reminderNo)
        .get();
    setState(() {
      _filteredAlerts = alarmSnapshot.docs;
    });
  }

  void _filterAlertsForSelectedDate() {
    setState(() {
      _filteredAlerts = _allAlerts.where((alert) {
        DateTime startDate = DateTime.parse(alert['startDate']);
        DateTime endDate = DateTime.parse(alert['endDate']);
        return startDate.isBefore(_selectedDate) &&
            endDate.isAfter(_selectedDate);
      }).toList();
    });
  }

  void _showReminderDetails(BuildContext context, DocumentSnapshot reminder) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(reminder['medicineName'] ?? 'No Medicine Name'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Dosage: ${reminder['dosage'] ?? 'N/A'}'),
                Text('Frequency: ${reminder['interval'] + ' times' ?? 'N/A'}'),
                Text('Pill Intake: ${reminder['pillIntake'] ?? 'N/A'}'),
                Text('Days: ${reminder['days'] ?? 'N/A'}'),
                Text(
                    'Additional Instructions: ${reminder['additionalInstructions'] ?? 'N/A'}'),
                Text(
                    'Repeat: ${(reminder['daysOfWeek'] as List<dynamic>).join(', ')}'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Edit'),
              onPressed: () {
                // Navigator.of(context).pop();
                _showEditDialog(context, reminder);
              },
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteReminder(reminder);
              },
            ),
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showEditDialog(BuildContext context, DocumentSnapshot reminder) async {
    final int reminderNo = reminder['reminderNo'];
    await getSavedAlarms(reminderNo);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: EdgeInsets.all(10),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.8,
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Edit Alarms for ${reminder['medicineName']}',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _filteredAlerts.length,
                    itemBuilder: (context, index) {
                      final alarm = _filteredAlerts[index];
                      final DateTime scheduledAlarmDateTime = DateTime.parse(alarm['scheduledAlarmDateTime']);
                      final TextEditingController dateController = TextEditingController(
                        text: DateFormat('yyyy-MM-dd').format(scheduledAlarmDateTime),
                      );
                      final TextEditingController timeController = TextEditingController(
                        text: DateFormat('HH:mm').format(scheduledAlarmDateTime),
                      );

                      return Column(
                        children: [
                          Text(
                            'Alarm ${index + 1}',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          _buildDatePickerTextField(
                              dateController, 'Scheduled Date', context),
                          _buildTimePickerTextField(
                              timeController, 'Scheduled Time', context),
                          SizedBox(height: 20),
                        ],
                      );
                    },
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      child: Text('Save'),
                      onPressed: () {
                        for (var alarm in _filteredAlerts) {
                          final DateTime updatedDateTime = DateFormat('yyyy-MM-dd HH:mm').parse(
                            '${dateController.text} ${timeController.text}',
                          );
                          _updateReminder(
                            alarm['reminderNo'],
                            DateFormat('yyyy-MM-ddTHH:mm:ss.SSS').format(updatedDateTime),
                          );
                        }
                        Navigator.of(context).pop();
                      },
                    ),
                    TextButton(
                      child: Text('Cancel'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _updateReminder(int reminderNo, String scheduledAlarmDateTime) async {
    try {
      DocumentReference documentReference = FirebaseFirestore.instance
          .collection('alarms')
          .doc(reminderNo.toString());

      DocumentSnapshot snapshot = await documentReference.get();
      if (!snapshot.exists) {
        throw Exception('Document does not exist');
      }

      await documentReference.update({
        'scheduledAlarmDateTime': scheduledAlarmDateTime,
      });
    } catch (e) {
      print('Error updating reminder: $e');
      _showErrorSnackBar('Error updating reminder: ${e.toString()}');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
    ));
  }

  Future<void> _deleteReminder(DocumentSnapshot reminder) async {
    await FirebaseFirestore.instance
        .collection('alarms')
        .doc(reminder.id)
        .delete();
    Alarm.stop(reminder.id.hashCode).then((_) => loadAlarms());
    //Alarm.stop(alarms[index].id).then((_) => loadAlarms());
    getSavedAlerts();
  }

  @override
  void dispose() {
    subscription?.cancel();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Medicine Reminder",
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
          ),
        ),
        backgroundColor: Colors.red,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _addTaskBar(screenWidth),
            _addDateBar(screenWidth),
            _showReminders(screenHeight, screenWidth),
          ],
        ),
      ),
      backgroundColor: Colors.white,
    );
  }

  Widget _addTaskBar(double screenWidth) {
    return Container(
      margin: EdgeInsets.only(
          left: screenWidth * 0.05,
          right: screenWidth * 0.05,
          top: 20,
          bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat.yMMMMd().format(DateTime.now()),
                    style: TextStyle(
                        fontSize: screenWidth * 0.06,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                  Text(
                    "Today",
                    style: TextStyle(
                        fontSize: screenWidth * 0.05,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                ],
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (BuildContext context) =>
                      MedicineAlertPage(widget.user),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.red,
              padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.04, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              "+ Add Reminder",
              style: TextStyle(fontSize: screenWidth * 0.04),
            ),
          ),
        ],
      ),
    );
  }

  Widget _addDateBar(double screenWidth) {
    return Container(
      margin: EdgeInsets.only(top: 20, left: screenWidth * 0.05),
      child: DatePicker(
        DateTime.now(),
        height: 100,
        width: 80,
        initialSelectedDate: DateTime.now(),
        selectedTextColor: Colors.white,
        selectionColor: Colors.red,
        dateTextStyle: TextStyle(
            fontSize: 20, fontWeight: FontWeight.w600, color: Colors.grey),
        onDateChange: (date) {
          setState(() {
            _selectedDate = date;
            _filterAlertsForSelectedDate();
          });
        },
      ),
    );
  }

  Widget _showReminders(double screenHeight, double screenWidth) {
    if (_filteredAlerts.isEmpty) {
      return Center(
          child: Text('No reminders found.',
              style: TextStyle(color: Colors.black)));
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: _filteredAlerts.length,
      itemBuilder: (context, index) {
        final reminder = _filteredAlerts[index];
        return _buildReminderItem(reminder, screenWidth);
      },
    );
  }

  Widget _buildReminderItem(DocumentSnapshot reminder, double screenWidth) {
    final data = reminder.data() as Map<String, dynamic>?;

    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: screenWidth * 0.05),
      child: ListTile(
        leading: Icon(Icons.alarm, color: Colors.redAccent, size: screenWidth * 0.05),
        title: Text(
          data != null && data.containsKey('medicineName') ? data['medicineName'] : 'No Medicine Name',
          style: TextStyle(
            fontSize: screenWidth * 0.03,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        subtitle: Text(
          'Pill Intake: ${data != null && data.containsKey('pillIntake') ? data['pillIntake'] : 'N/A'}\n'
              'Frequency: ${data != null && data.containsKey('interval') ? data['interval'].toString() + ' times' : 'N/A'}',
          style: TextStyle(fontSize: screenWidth * 0.028, color: Colors.black),
        ),
        trailing: Icon(Icons.chevron_right, color: Colors.grey, size: screenWidth * 0.08),
        onTap: () {
          _showReminderDetails(context, reminder);
        },
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      TextInputType keyboardType) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.black),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red, width: 2.0),
          borderRadius: BorderRadius.circular(12.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black, width: 1.0),
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
      keyboardType: keyboardType,
      cursorColor: Colors.red,
    );
  }

  Widget _buildDatePickerTextField(
      TextEditingController controller, String label, BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.black),
        suffixIcon: IconButton(
          icon: Icon(Icons.calendar_today_outlined, color: Colors.red),
          onPressed: () async {
            DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2101),
            );
            if (pickedDate != null) {
              setState(() {
                controller.text = DateFormat('yyyy-MM-dd').format(pickedDate);
              });
            }
          },
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red, width: 2.0),
          borderRadius: BorderRadius.circular(12.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black, width: 1.0),
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
      keyboardType: TextInputType.datetime,
      cursorColor: Colors.red,
    );
  }

  Widget _buildTimePickerTextField(
      TextEditingController controller, String label, BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.black),
        suffixIcon: IconButton(
          icon: Icon(Icons.access_time_outlined, color: Colors.red),
          onPressed: () async {
            TimeOfDay? pickedTime = await showTimePicker(
              context: context,
              initialTime: TimeOfDay.now(),
              builder: (BuildContext context, Widget? child) {
                return MediaQuery(
                  data: MediaQuery.of(context)
                      .copyWith(alwaysUse24HourFormat: true),
                  child: child!,
                );
              },
            );
            if (pickedTime != null) {
              setState(() {
                controller.text = pickedTime.format(context);
              });
            }
          },
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red, width: 2.0),
          borderRadius: BorderRadius.circular(12.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black, width: 1.0),
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
      keyboardType: TextInputType.datetime,
      cursorColor: Colors.red,
    );
  }
}