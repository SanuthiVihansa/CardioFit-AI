import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PMBDeviceConnectionScreen extends StatefulWidget {
  const PMBDeviceConnectionScreen({super.key});

  @override
  State<PMBDeviceConnectionScreen> createState() =>
      _PMBDeviceConnectionScreenState();
}

class _PMBDeviceConnectionScreenState extends State<PMBDeviceConnectionScreen> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(),
    );
  }
}
