import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
          _addTaskBar()
        ],
      ),
    );
  }

  _addTaskBar(){
    return Container(
      margin: const EdgeInsets.only(left: 20,right: 20,top: 20,bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //Add Current Date
                //Text(DateTime.now().toString()),
                Text(DateFormat.yMMMMd().format(DateTime.now()),style: TextStyle(fontSize: 30,fontWeight: FontWeight.bold),),
                Text("Today",style: TextStyle(fontSize: 24,fontWeight: FontWeight.bold),)
              ],
            ),
          ),
          ElevatedButton(onPressed: (){}, child: Text("+Add Reminder"))
        ],
      ),
    );
  }
}
