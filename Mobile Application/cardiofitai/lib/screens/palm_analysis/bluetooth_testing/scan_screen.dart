// https://medium.com/@nandhuraj/exploring-bluetooth-communication-with-flutter-blue-plus-package-3c442d0e6cdb

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {

  FlutterBlue flutterBlue = FlutterBlue.instance;
  List<BluetoothDevice> devices = [];



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  void startScanning() async {
    await flutterBlue.startScan();
    flutterBlue.scanResults.listen((results) {
      for (ScanResult result in results) {
        if (!devices.contains(result.device)) {
          setState(() {
            devices.add(result.device);
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text("Scanning"),
      ),
    );
  }
}


