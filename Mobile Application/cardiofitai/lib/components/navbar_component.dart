import 'dart:io';


import 'package:cardiofitai/screens/common/signup_screen.dart';

import 'package:cardiofitai/screens/diet_plan/user_profile_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../models/user.dart';
import '../screens/diet_plan/modiRecognitionScreen.dart';
import '../screens/diet_plan/scan.dart';

class LeftNavBar extends StatelessWidget {
  final String name;
  final String email;
  final double width;
  final double height;
  final User user;

  LeftNavBar({
    required this.user,
    required this.name,
    required this.email,
    required this.width,
    required this.height,
  });

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

      Navigator.of(context).pop();
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (BuildContext context) => SignUpPage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(name),
            accountEmail: Text(email),
            currentAccountPicture: Stack(
              children: [
                // Circular progress indicator
                CircularProgressIndicator(
                  value: 0.5, // Set the value (e.g., 50%)
                  strokeWidth: 8, // Customize the stroke width
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
                ),
                //Profile Picture
                CupertinoButton(
                  minSize: 600,
                  padding: EdgeInsets.all(16.0),
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ProfilePage(user)),
                    );
                  },
                  child: CircleAvatar(
                    child: ClipOval(
                      child: Image.network(
                        'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8dXNlciUyMHByb2ZpbGV8ZW58MHx8MHx8fDA%3D',
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            decoration: BoxDecoration(
              color: Colors.blueAccent,
            ),
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text("OCR Reader"),
            onTap: () {
              Navigator.of(context).pop(); // Close the drawer
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => RecognitionScreenScan(),
                ),
              );
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.monetization_on),
            title: Text("Recognition Screen"),
            onTap: () {
              Navigator.of(context).pop(); // Close the drawer
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => RecognitionScreen(),
                ),
              );
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text("LOG OUT"),
            onTap: () {
              _onTapLogOutBtn(context);
            },
          )
        ],
      ),
    );
  }
}
