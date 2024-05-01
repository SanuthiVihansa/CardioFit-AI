import 'package:cardiofitai/screens/facial_analysis/facial_analysis_home.dart';
import 'package:cardiofitai/screens/palm_analysis/file_selection_screen.dart';
import 'package:cardiofitai/screens/palm_analysis/temp_file_selection_screen.dart';
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
  final double _hDevWidth = 1280.0;
  final double _hDevHeight = 740.0;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
  }

  void _onClickFacialAnalysisBtn() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) =>
                FacialAnalysisHome(_width, _height, _hDevHeight, _hDevWidth)));
  }

  void _onClickPalmAnalysisBtn() {
    Navigator.push(
        context,
        MaterialPageRoute(
            // builder: (BuildContext context) => const FileSelectionScreen()));
            builder: (BuildContext context) =>
                const TempFileSelectionScreen()));
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
                  Size(_width / (_devWidth / 160.0),
                      _height / (_devHeight / 40)), // Button width and height
                ),
              ),
              child: Text(
                "Facial Analysis",
                style: TextStyle(fontSize: _width / (_devWidth / 10)),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                _onClickPalmAnalysisBtn();
              },
              style: ButtonStyle(
                fixedSize: MaterialStateProperty.all<Size>(
                  Size(_width / (_devWidth / 160.0),
                      _height / (_devHeight / 40)), // Button width and height
                ),
              ),
              child: Text(
                "Palm Analysis",
                style: TextStyle(fontSize: _width / (_devWidth / 10)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
