import 'package:cardiofitai/models/user.dart';
import 'package:cardiofitai/screens/diet_plan/AlertService/alarmappexample.dart';
import 'package:cardiofitai/screens/diet_plan/AlertService/medicineAlertScreen.dart';
import 'package:cardiofitai/services/medicineReminderService.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_picker_timeline/date_picker_timeline.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NotificationHomePage extends StatefulWidget {
  const NotificationHomePage(this.user, {super.key});

  final User user;

  @override
  State<NotificationHomePage> createState() => _NotificationHomePageState();
}

class _NotificationHomePageState extends State<NotificationHomePage> {
  List<DocumentSnapshot> _allAlerts = [];

  @override
  void initState() {
    super.initState();
    getSavedAlerts();
  }

  Future<void> getSavedAlerts() async {
    QuerySnapshot querySnapshot = await MedicineReminderService.getAllUserReminder(widget.user.email);
    setState(() {
      _allAlerts = querySnapshot.docs;
    });
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
      margin: EdgeInsets.only(left: screenWidth * 0.05, right: screenWidth * 0.05, top: 20, bottom: 10),
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
                    style: TextStyle(fontSize: screenWidth * 0.06, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  Text(
                    "Today",
                    style: TextStyle(fontSize: screenWidth * 0.05, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                ],
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (BuildContext context) => MedicineAlertPage(widget.user),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.red,
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04, vertical: 8),
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
        dateTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.grey),
      ),
    );
  }

  Widget _showReminders(double screenHeight, double screenWidth) {
    if (_allAlerts.isEmpty) {
      return Center(child: Text('No reminders found.', style: TextStyle(color: Colors.black)));
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: _allAlerts.length,
      itemBuilder: (context, index) {
        final reminder = _allAlerts[index];
        return _buildReminderItem(reminder, screenWidth);
      },
    );
  }

  Widget _buildReminderItem(DocumentSnapshot reminder, double screenWidth) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: screenWidth * 0.05),
      child: ListTile(
        leading: Icon(Icons.alarm, color: Colors.redAccent, size: screenWidth * 0.1),
        title: Text(
          reminder['medicineName'] ?? 'No Medicine Name',
          style: TextStyle(fontSize: screenWidth * 0.05, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        subtitle: Text(
          'Dosage: ${reminder['dosage'] ?? 'N/A'}\n'
              'Frequency: ${reminder['interval'] ?? 'N/A'}',
          style: TextStyle(fontSize: screenWidth * 0.035, color: Colors.black),
        ),
        trailing: Icon(Icons.chevron_right, color: Colors.grey, size: screenWidth * 0.08),
        onTap: () {
          _showReminderDetails(context, reminder);
        },
      ),
    );
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
                Text('Frequency: ${reminder['interval'] ?? 'N/A'}'),
                Text('Pill Intake: ${reminder['pillIntake'] ?? 'N/A'}'),
                Text('Start Date: ${reminder['startDate'] ?? 'N/A'}'),
                Text('Start Time: ${reminder['startTime'] ?? 'N/A'}'),
                Text('Days: ${reminder['days'] ?? 'N/A'}'),
                Text('Additional Instructions: ${reminder['additionalInstructions'] ?? 'N/A'}'),
                Text('Days of Week: ${(reminder['daysOfWeek'] as List<dynamic>).join(', ')}'),
              ],
            ),
          ),
          actions: <Widget>[
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
}
