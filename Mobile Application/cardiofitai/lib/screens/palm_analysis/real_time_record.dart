import 'package:flutter/material.dart';

class RealTimeRecord extends StatefulWidget {
  const RealTimeRecord({super.key});

  @override
  State<RealTimeRecord> createState() => _RealTimeRecordState();
}

class _RealTimeRecordState extends State<RealTimeRecord> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "CardioFit AI",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.red,
      ),
    );
  }
}
