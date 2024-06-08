import 'package:flutter/material.dart';

class NotificationHomePage extends StatefulWidget {
  const NotificationHomePage({super.key});

  @override
  State<NotificationHomePage> createState() => _NotificationHomePageState();
}

class _NotificationHomePageState extends State<NotificationHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Medicine Reminder"),),
      body: Column(
        children: [
          Row(
            children: [
              Column(
                children: [
                  //Add Current Date
                  Text(DateTime.now().toString()),
                ],
              )
            ],
          )
        ],
      ),
    );
  }
}
