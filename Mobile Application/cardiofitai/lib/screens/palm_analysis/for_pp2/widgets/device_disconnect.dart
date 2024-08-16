import 'package:flutter/material.dart';

class DeviceDisconnect extends StatelessWidget {
  const DeviceDisconnect({super.key});
  final double _devDeviceWidth = 1280.0;
  final double _devDeviceHeight = 720.0;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding:
          EdgeInsets.only(bottom: height / (_devDeviceHeight / 50.0)),
          child: SizedBox(
            width: width / (_devDeviceWidth / 700),
            // width: 700,
            child: Text(
              "Please connect the Ambulatory ECG Device to continue...",
              style: TextStyle(
                  color: Colors.red,
                  fontSize: height / (_devDeviceHeight / 40)),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Image.asset(
              'assets/palm_analysis/tablet.png',
              width: width / (_devDeviceWidth / 600),
              height: height / (_devDeviceHeight / 240),
              fit: BoxFit.contain,
            ),
            Image.asset(
              'assets/palm_analysis/usb.png',
              width: width / (_devDeviceWidth / 600),
              height: height / (_devDeviceHeight / 240),
              fit: BoxFit.contain,
            ),
          ],
        )
      ],
    );
  }
}
