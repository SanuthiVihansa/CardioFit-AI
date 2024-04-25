import 'package:cardiofitai/screens/common/ecg_monitoring_home_screen.dart';
import 'package:flutter/material.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  void _onClickEcgMonitoringBtn() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) => ECGMonitoringHomeScreen()));
  }

  void _onClickDietPlanBtn() {}

  void _onClickReportingAndAnalyticsBtn() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
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
                fontWeight: FontWeight.bold, fontSize: 20, color: Colors.red),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                  onPressed: () {
                    _onClickEcgMonitoringBtn();
                  },
                  child: Text("ECG Monitoring")),
              ElevatedButton(
                  onPressed: () {
                    _onClickDietPlanBtn();
                  },
                  child: Text("Diet Plan")),
              ElevatedButton(
                  onPressed: () {
                    _onClickReportingAndAnalyticsBtn();
                  },
                  child: Text("Reporting & Analytics"))
            ],
          )
        ],
      ),
    );
  }
}
