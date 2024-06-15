import 'package:cardiofitai/models/user.dart';
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
                    style: TextStyle(fontSize: screenWidth * 0.08, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  Text(
                    "Today",
                    style: TextStyle(fontSize: screenWidth * 0.06, fontWeight: FontWeight.bold, color: Colors.black),
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
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              "+ Add Reminder",
              style: TextStyle(fontSize: screenWidth * 0.045),
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
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: screenWidth * 0.05),
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: Colors.redAccent,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            reminder['medicineName'] ?? 'No Medicine Name',
            style: TextStyle(fontSize: screenWidth * 0.05, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          SizedBox(height: screenWidth * 0.02),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'Dosage: ',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                ),
                TextSpan(
                  text: '${reminder['dosage'] ?? 'N/A'}\n',
                  style: TextStyle(color: Colors.white),
                ),
                TextSpan(
                  text: 'Frequency: ',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                ),
                TextSpan(
                  text: '${reminder['interval'] ?? 'N/A'}\n',
                  style: TextStyle(color: Colors.white),
                ),
                TextSpan(
                  text: 'Pill Intake: ',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                ),
                TextSpan(
                  text: '${reminder['pillIntake'] ?? 'N/A'}\n',
                  style: TextStyle(color: Colors.white),
                ),
                TextSpan(
                  text: 'Start Date: ',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                ),
                TextSpan(
                  text: '${reminder['startDate'] ?? 'N/A'}\n',
                  style: TextStyle(color: Colors.white),
                ),
                TextSpan(
                  text: 'Start Time: ',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                ),
                TextSpan(
                  text: '${reminder['startTime'] ?? 'N/A'}\n',
                  style: TextStyle(color: Colors.white),
                ),
                TextSpan(
                  text: 'Days: ',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                ),
                TextSpan(
                  text: '${reminder['days'] ?? 'N/A'}\n',
                  style: TextStyle(color: Colors.white),
                ),
                TextSpan(
                  text: 'Additional Instructions: ',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                ),
                TextSpan(
                  text: '${reminder['additionalInstructions'] ?? 'N/A'}\n',
                  style: TextStyle(color: Colors.white),
                ),
                TextSpan(
                  text: 'Days of Week: ',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                ),
                TextSpan(
                  text: (reminder['daysOfWeek'] as List<dynamic>).join(', '),
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
