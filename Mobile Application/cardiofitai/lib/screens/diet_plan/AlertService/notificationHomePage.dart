import 'dart:async';
import 'package:alarm/alarm.dart';
import 'package:alarm/model/alarm_settings.dart';
import 'package:cardiofitai/components/navigation_panel_component.dart';
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
  List<DateTime> _updatedScheduledDateTimes = [];
  List<bool> alarmStatusList = [];

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
//Fetch all the alarms which belong to the user
  Future<void> getSavedAlarms(int reminderNo) async {
    final QuerySnapshot alarmSnapshot = await FirebaseFirestore.instance
        .collection('alarms')
        .where('userEmail', isEqualTo: widget.user.email)
        .where('reminderNo', isEqualTo: reminderNo)
        .get();
    setState(() {
      _filteredAlerts = alarmSnapshot.docs;
      _assignUpdatedScheduledDateTimes(_filteredAlerts);
    });
  }
//Update when the alarm times are editted
  void _assignUpdatedScheduledDateTimes(List<DocumentSnapshot> filteredAlerts) {
    _updatedScheduledDateTimes.clear(); // Clear previous data
    alarmStatusList.clear(); // Clear previous statuses

    for (var alarm in filteredAlerts) {
      _updatedScheduledDateTimes
          .add(DateTime.parse(alarm["scheduledAlarmDateTime"]));
      alarmStatusList.add(alarm['isActive']);
    }
  }
  //Filter alerts upon selection of dates
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
//View items in the list view in detail
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
                setState(() {
                  _filterAlertsForSelectedDate();
                });
              },
            ),
          ],
        );
      },
    );
  }
  //When a particular alarm needs to be editted
  void _showEditDialog(BuildContext context, DocumentSnapshot reminder) async {
    final int reminderNo = reminder['reminderNo'];

    // Show a loading indicator while fetching alarms
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(child: CircularProgressIndicator());
      },
    );

    await getSavedAlarms(reminderNo);

    if (!mounted) return; // Check if the widget is still mounted

    Navigator.of(context).pop(); // Close the loading indicator

    if (_filteredAlerts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No alarms found for editing.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          insetPadding: EdgeInsets.all(10),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.8,
            padding: EdgeInsets.all(20),
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Column(
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

                          // Cast the document data to a Map
                          final Map<String, dynamic> alarmData = alarm.data() as Map<String, dynamic>;

                          // Check if 'scheduledAlarmDateTime' exists
                          final scheduledAlarmDateTime = alarmData.containsKey('scheduledAlarmDateTime')
                              ? DateTime.parse(alarmData['scheduledAlarmDateTime'])
                              : DateTime.now(); // Fallback to current time if missing

                          final TextEditingController dateController = TextEditingController(
                            text: DateFormat('yyyy-MM-dd').format(scheduledAlarmDateTime),
                          );
                          final TextEditingController timeController = TextEditingController(
                            text: DateFormat('HH:mm').format(scheduledAlarmDateTime),
                          );

                          bool alarmStatus = alarmStatusList[index];
                          final DateTime updatedDateTime = DateFormat('yyyy-MM-dd HH:mm')
                              .parse('${dateController.text} ${timeController.text}');

                          return Column(
                            children: [
                              Text(
                                'Alarm ${index + 1}',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 20),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildDatePickerTextField(
                                        dateController, 'Scheduled Date', context, index),
                                  ),
                                  SizedBox(width: 20),
                                  Expanded(
                                    child: _buildTimePickerTextField(
                                        timeController, 'Scheduled Time', context, index),
                                  ),
                                  SizedBox(width: 20),
                                  Switch(
                                    value: alarmStatus,
                                    onChanged: (bool value) {
                                      setState(() {
                                        alarmStatusList[index] = value;
                                      });
                                      if (value) {
                                        _updateReminderAlarmStatusTrue(alarmData['alarmIdNo']);
                                        _reCreateAlarm(
                                            alarmData['alarmIdNo'],
                                            updatedDateTime,
                                            alarmData["medicineName"],
                                            int.parse(alarmData["pillIntake"].toString()),
                                            int.parse(alarmData["dosage"].toString()));
                                      } else {
                                        _updateReminderAlarmStatus(alarmData['alarmIdNo']);
                                        Alarm.stop(alarmData['alarmIdNo']);
                                      }
                                    },
                                  ),
                                ],
                              ),
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
                          onPressed: () async {
                            int index1 = 0;
                            for (var alarm in _filteredAlerts) {
                              final alarmData = alarm.data() as Map<String, dynamic>;
                              await _updateReminder(
                                alarmData['alarmIdNo'],
                                DateFormat('yyyy-MM-ddTHH:mm:ss.SSS')
                                    .format(_updatedScheduledDateTimes[index1]),
                              );
                              await _reCreateAlarm(
                                  int.parse(alarmData["alarmIdNo"].toString()),
                                  _updatedScheduledDateTimes[index1],
                                  alarmData["medicineName"],
                                  int.parse(alarmData["pillIntake"].toString()),
                                  int.parse(alarmData["dosage"].toString()));
                              index1++;
                            }
                            if (mounted) {
                              Navigator.of(dialogContext).pop();
                              _showSuccessSnackBar("Alarm Updated");
                            }
                          },
                        ),
                        // TextButton(
                        //   child: Text('Cancel'),
                        //   onPressed: () {
                        //     if (mounted) {
                        //       Navigator.of(dialogContext).pop();
                        //     }
                        //   },
                        // ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
//Show success msg upon updating the alarms
  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: Colors.green,
    ));
  }
  //Show error message when something goes wrong
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
    ));
  }
  //When updating delete the existing and recreate alarms
  Future<void> _reCreateAlarm(
      int alarmId, DateTime dateTime, String medicineName, int pillIntake, int dosage) async {
    try {
      // Stop the previous alarm
      await Alarm.stop(alarmId);

      // Set the new alarm
      final alarmSettings = AlarmSettings(
        id: alarmId,
        dateTime: dateTime,
        assetAudioPath: 'assets/diet_component/audio_assets/alarmsound.mp3',
        loopAudio: true,
        vibrate: true,
        volume: 0.8,
        fadeDuration: 2,
        notificationTitle: medicineName,
        notificationBody: 'Take $pillIntake pill(s) of $medicineName. $dosage mg.',
      );
      await Alarm.set(alarmSettings: alarmSettings);
    } catch (e) {
      print('Error recreating alarm: $e');
      _showErrorSnackBar('Error recreating alarm: ${e.toString()}');
      rethrow; // Re-throw the error to handle it in the calling function
    }
  }
//Update the editted content in firebase collection
  Future<void> _updateReminder(int alarmIdNo, String scheduledAlarmDateTime) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('alarms')
          .where("alarmIdNo", isEqualTo: alarmIdNo)
          .get();

      if (querySnapshot.docs.isEmpty) {
        throw Exception('Document does not exist');
      }

      for (QueryDocumentSnapshot documentSnapshot in querySnapshot.docs) {
        // Get the document reference
        DocumentReference documentReference = documentSnapshot.reference;

        // Update the document
        await documentReference.update({
          'scheduledAlarmDateTime': scheduledAlarmDateTime,
        });
      }
    } catch (e) {
      print('Error updating reminder: $e');
      _showErrorSnackBar('Error updating reminder: ${e.toString()}');
      rethrow; // Re-throw the error to handle it in the calling function
    }
  }
//When an reminder needs to be set as active or inactive, update status in firbase collection
  Future<void> _updateReminderAlarmStatus(int alarmIdNo) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('alarms')
          .where("alarmIdNo", isEqualTo: alarmIdNo)
          .get();

      if (querySnapshot.docs.isEmpty) {
        throw Exception('Document does not exist');
      }

      for (QueryDocumentSnapshot documentSnapshot in querySnapshot.docs) {
        // Get the document reference
        DocumentReference documentReference = documentSnapshot.reference;

        // Update the document
        await documentReference.update({
          'isActive': false,
        });
      }
    } catch (e) {
      print('Error updating reminder: $e');
      _showErrorSnackBar('Error updating reminder: ${e.toString()}');
    }
  }
//Update the firebase collection of alarms scheduled
  Future<void> _updateReminderAlarmStatusTrue(int alarmIdNo) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('alarms')
          .where("alarmIdNo", isEqualTo: alarmIdNo)
          .get();

      if (querySnapshot.docs.isEmpty) {
        throw Exception('Document does not exist');
      }

      for (QueryDocumentSnapshot documentSnapshot in querySnapshot.docs) {
        // Get the document reference
        DocumentReference documentReference = documentSnapshot.reference;

        // Update the document
        await documentReference.update({
          'isActive': true,
        });
      }
    } catch (e) {
      print('Error updating reminder: $e');
      _showErrorSnackBar('Error updating reminder: ${e.toString()}');
    }
  }
  //When delete button is clicked
  Future<void> _deleteReminder(DocumentSnapshot reminder) async {
    final reminderNo = reminder['reminderNo'];
    final userEmail = reminder['userEmail'];

    try {
      // Fetch all alarms related to the reminderNo
      final QuerySnapshot alarmSnapshot = await FirebaseFirestore.instance
          .collection('alarms')
          .where('reminderNo', isEqualTo: reminderNo)
          .where('userEmail', isEqualTo: userEmail)
          .get();

      // Stop each alarm and delete the record in Firestore
      for (var alarmDoc in alarmSnapshot.docs) {
        final alarmIdNo = alarmDoc['alarmIdNo'];

        // Stop the alarm
        await Alarm.stop(alarmIdNo);

        // Delete the alarm document
        await alarmDoc.reference.delete();
      }

      // Delete the reminder document from medicinereminder collection
      await reminder.reference.delete();

      // Refresh the list of saved alerts
      await getSavedAlerts();

      // Update the UI
      setState(() {
        _filterAlertsForSelectedDate();
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Reminder and associated alarms deleted successfully.'),
        backgroundColor: Colors.green,
      ));
    } catch (e) {
      print('Error deleting reminder: $e');
      _showErrorSnackBar('Error deleting reminder: ${e.toString()}');
    }
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
      body: Row(
        children: [
          //Put the navigation component to the screen
          NavigationPanelComponent("alarm", widget.user),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _addTaskBar(screenWidth),
                  _addDateBar(screenWidth),
                  _showReminders(screenHeight, screenWidth),
                ],
              ),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.white,
    );
  }
//Current date and Add Reminder button
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
                        fontSize: screenWidth * 0.03,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                  Text(
                    "Today",
                    style: TextStyle(
                        fontSize: screenWidth * 0.04,
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
//Horizontal Scrollable date bar
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
//Logic to check if there are alarms available and if yes put them to a list view else show a msg
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

  //Medicine Reminders : List view details
  Widget _buildReminderItem(DocumentSnapshot reminder, double screenWidth) {
    final data = reminder.data() as Map<String, dynamic>?;

    return Card(
      margin:
          EdgeInsets.symmetric(vertical: 8.0, horizontal: screenWidth * 0.05),
      child: ListTile(
        leading: Icon(Icons.alarm,
            color: Colors.redAccent, size: screenWidth * 0.05),
        title: Text(
          data != null && data.containsKey('medicineName')
              ? data['medicineName']
              : 'No Medicine Name',
          style: TextStyle(
            fontSize: screenWidth * 0.02,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        subtitle: Text(
          'Pill Intake: ${data != null && data.containsKey('pillIntake') ? data['pillIntake'] : 'N/A'}\n'
          'Frequency: ${data != null && data.containsKey('interval') ? data['interval'].toString() + ' times' : 'N/A'}',
          style: TextStyle(fontSize: screenWidth * 0.02, color: Colors.black),
        ),
        trailing: Icon(Icons.chevron_right,
            color: Colors.grey, size: screenWidth * 0.02),
        onTap: () {
          _showReminderDetails(context, reminder);
        },
      ),
    );
  }


  Widget _buildDatePickerTextField(TextEditingController controller,
      String label, BuildContext context, int index) {
    return TextField(
      readOnly: true,
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
              DateTime dateTime = _updatedScheduledDateTimes[index];
              setState(() {
                controller.text = DateFormat('yyyy-MM-dd').format(pickedDate);
                _updatedScheduledDateTimes[index] = DateTime(
                    pickedDate.year,
                    pickedDate.month,
                    pickedDate.day,
                    dateTime.hour,
                    dateTime.minute);
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

  String _formatTimeOfDay(TimeOfDay time) {
    // Format the hour and minute to always be two digits
    final String hour = time.hour.toString().padLeft(2, '0');
    final String minute = time.minute.toString().padLeft(2, '0');

    return '$hour:$minute';
  }

  Widget _buildTimePickerTextField(TextEditingController controller,
      String label, BuildContext context, int index) {
    return TextField(
      readOnly: true,
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
              DateTime dateTime = _updatedScheduledDateTimes[index];
              setState(() {
                controller.text = _formatTimeOfDay(pickedTime);
              });
              _updatedScheduledDateTimes[index] = DateTime(
                  dateTime.year,
                  dateTime.month,
                  dateTime.day,
                  pickedTime.hour,
                  pickedTime.minute);
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
