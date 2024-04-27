import 'package:cardiofitai/screens/common/ecg_monitoring_home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late double _width;
  // ignore: unused_field
  late double _height;

  final double _devWidth = 753.4545454545455;
  // ignore: unused_field
  final double _devHeight = 392.72727272727275;

  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
  }

  void _onClickEcgMonitoringBtn() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) =>
                const ECGMonitoringHomeScreen()));
  }

  void _onClickDietPlanBtn() {}

  void _onClickReportingAndAnalyticsBtn() {}

  @override
  Widget build(BuildContext context) {
    _width = MediaQuery.of(context).size.width;
    _height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "CardioFit AI",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.red,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(
            "Welcome !",
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: _width / (_devWidth / 20),
                color: Colors.red),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                  onPressed: () {
                    _onClickEcgMonitoringBtn();
                  },
                  child: const Text("ECG Monitoring")),
              ElevatedButton(
                  onPressed: () {
                    _onClickDietPlanBtn();
                  },
                  child: const Text("Diet Plan")),
              ElevatedButton(
                  onPressed: () {
                    _onClickReportingAndAnalyticsBtn();
                  },
                  child: const Text("Reporting & Analytics"))
            ],
          )
        ],
      ),
    );
  }
}
