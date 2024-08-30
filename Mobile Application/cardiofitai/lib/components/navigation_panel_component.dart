import 'dart:io';

import 'package:cardiofitai/models/user.dart';
import 'package:cardiofitai/screens/common/dashboard_screen.dart';
import 'package:cardiofitai/screens/common/ecg_monitoring_home_screen.dart';
import 'package:cardiofitai/screens/diet_plan/AlertService/medicineAlertScreen.dart';
import 'package:cardiofitai/screens/diet_plan/AlertService/notificationHomePage.dart';
import 'package:cardiofitai/screens/diet_plan/ReportReading/modiRecognitionScreen.dart';
import 'package:cardiofitai/screens/diet_plan/diet_,mainhome_page.screen.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../screens/common/signup_screen.dart';

class NavigationPanelComponent extends StatelessWidget {
  NavigationPanelComponent(this._currentScreen, this._user, {super.key});

  final String _currentScreen;
  final User _user;

  Future<void> _onTapLogOutBtn(BuildContext context) async {
    var dialogRes = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
              actionsAlignment: MainAxisAlignment.spaceBetween,
              content: const Text('Are you sure you want to logout?'),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('No'),
                ),
                TextButton(
                  onPressed: () async {
                    return Navigator.pop(context, true);
                  },
                  child: const Text('Yes'),
                ),
              ],
            ));

    if (dialogRes == true) {
      final directory = await getApplicationDocumentsDirectory();
      final path = directory.path;
      File file = File('$path/userdata.txt');
      await file.delete();

      // Navigator.of(context).pop();
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (BuildContext context) => SignUpPage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    return Container(
      width: 80,
      height: screenHeight,
      color: Colors.blueGrey, // Set your desired color
      child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20), // Top padding
            NavigationItem(
              icon: Icons.dashboard,
              label: 'Dashboard',
              onTap: () {
                if (_currentScreen != "dashboard") {
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (BuildContext) => DashboardScreen(_user)));
                }
              },
            ),
            NavigationItem(
              icon: Icons.alarm,
              label: 'Alarm',
              onTap: () {
                if (_currentScreen != "alarm") {
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (BuildContext) => NotificationHomePage(_user)));
                }
              },
            ),
            NavigationItem(
              icon: Icons.monitor_heart,
              label: 'ECG',
              onTap: () {
                if (_currentScreen != "ecg") {
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (BuildContext) =>
                          ECGMonitoringHomeScreen(_user)));
                }
              },
            ),
            NavigationItem(
              icon: Icons.insert_chart,
              label: 'Reports',
              onTap: () {
                if (_currentScreen != "reports") {
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (BuildContext) => RecognitionScreen(_user)));
                }
              },
            ),
            NavigationItem(
              icon: Icons.emoji_food_beverage,
              label: 'Diet Plan',
              onTap: () {
                if (_currentScreen != "diet plan") {
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (BuildContext) => DietHomePage(_user)));
                }
              },
            ),
            NavigationItem(
              icon: Icons.exit_to_app,
              label: 'Log Out',
              onTap: () {
                _onTapLogOutBtn(context);
              },
            ),
            SizedBox(height: 20), // Bottom padding
          ],
        ),
      ),
    );
  }
}

class NavigationItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  NavigationItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          children: [
            Icon(icon, color: Colors.white),
            Text(label, style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }
}
