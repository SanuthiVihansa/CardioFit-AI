import 'package:cardiofitai/models/user.dart';
import 'package:flutter/material.dart';

class EcgHistoryScreen extends StatefulWidget {
  const EcgHistoryScreen(this._user, {super.key});

  final User _user;

  @override
  State<EcgHistoryScreen> createState() => _EcgHistoryScreenState();
}

class _EcgHistoryScreenState extends State<EcgHistoryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        title: Text(
          "ECG History",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
