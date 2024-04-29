import 'package:cardiofitai/screens/palm_analysis/file_selection_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ECGMonitoringHomeScreen extends StatefulWidget {
  const ECGMonitoringHomeScreen({super.key});

  @override
  State<ECGMonitoringHomeScreen> createState() =>
      _ECGMonitoringHomeScreenState();
}

class _ECGMonitoringHomeScreenState extends State<ECGMonitoringHomeScreen> {
  late double _width;
  late double _height;
  final double _devWidth = 753.4545454545455;
  final double _devHeight = 392.72727272727275;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
  }

  void _onClickFacialAnalysisBtn() {}

  void _onClickPalmAnalysisBtn() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) => const FileSelectionScreen()));
  }

  @override
  Widget build(BuildContext context) {
    _width = MediaQuery.of(context).size.width;
    _height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: const Text(
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
              style: ButtonStyle(
                fixedSize: MaterialStateProperty.all<Size>(
                  Size(_width / (_devWidth / 200.0),
                      _height / (_devHeight / 50)), // Button width and height
                ),
              ),
              child: Text(
                "Facial Analysis",
                style: TextStyle(fontSize: _width / (_devWidth / 15)),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                _onClickPalmAnalysisBtn();
              },
              style: ButtonStyle(
                fixedSize: MaterialStateProperty.all<Size>(
                  Size(_width / (_devWidth / 200.0),
                      _height / (_devHeight / 50)), // Button width and height
                ),
              ),
              child: Text(
                "Palm Analysis",
                style: TextStyle(fontSize: _width / (_devWidth / 15)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
