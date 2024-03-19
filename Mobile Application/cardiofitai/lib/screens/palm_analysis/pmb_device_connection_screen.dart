import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PMBDeviceConnectionScreen extends StatefulWidget {
  const PMBDeviceConnectionScreen({super.key});

  @override
  State<PMBDeviceConnectionScreen> createState() =>
      _PMBDeviceConnectionScreenState();
}

class _PMBDeviceConnectionScreenState extends State<PMBDeviceConnectionScreen> {
  double _devDeviceWidth = 1280.0;
  double _devDeviceHeight = 720.0;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  Widget build(BuildContext context) {
    double _width = MediaQuery.of(context).size.width;
    double _height = MediaQuery.of(context).size.height;

    print(_width);
    print(_height);

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: _width / (_devDeviceWidth / 700),
            // width: 700,
            child: Text(
              "Please connect the Ambulatory ECG Device to continue...",
              style: TextStyle(color: Colors.red, fontSize: 40),
              textAlign: TextAlign.center,
            ),
          ),
          Row(
            children: [
              Image.asset(
                'assets/palm_analysis/tablet.png',
                width: 600.0,
                height: 240.0,
                fit: BoxFit.contain,
              ),
              Image.asset(
                'assets/palm_analysis/usb.png',
                width: 600.0,
                height: 240.0,
                fit: BoxFit.contain,
              ),
            ],
          )
        ],
      ),
    );
  }
}
