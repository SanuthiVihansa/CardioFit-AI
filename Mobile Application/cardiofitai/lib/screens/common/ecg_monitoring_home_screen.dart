import 'package:cardiofitai/screens/palm_analysis/file_selection_screen.dart';
import 'package:flutter/material.dart';

class ECGMonitoringHomeScreen extends StatefulWidget {
  const ECGMonitoringHomeScreen({super.key});

  @override
  State<ECGMonitoringHomeScreen> createState() =>
      _ECGMonitoringHomeScreenState();
}

class _ECGMonitoringHomeScreenState extends State<ECGMonitoringHomeScreen> {
  void _onClickFacialAnalysisBtn() {}

  void _onClickPalmAnalysisBtn() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) => FileSelectionScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "ECG Monitoring",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.red,
      ),
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
                onPressed: () {
                  _onClickFacialAnalysisBtn();
                },
                child: Text("Facial Analysis")),
            ElevatedButton(
                onPressed: () {
                  _onClickPalmAnalysisBtn();
                },
                child: Text("Palm Analysis"))
          ],
        ),
      ),
    );
  }
}
