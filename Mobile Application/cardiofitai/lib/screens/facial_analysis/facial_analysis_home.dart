import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'facial_analysis_ecg_capturing.dart';
import 'facial_analysis_reading.dart';

class FacialAnalysisHome extends StatelessWidget {
  FacialAnalysisHome(
      this._width, this._height, this._hDevHeight, this._hDevWidth,
      {super.key});

  // Height and width of current device
  final double _width, _height, _hDevWidth, _hDevHeight;

  //sizes and paddings
  final double iconSize = 100;
  final double iconPadding = 70;
  final double iconTextFontSize = 30;
  final double buttonLength = 325;
  final double buttonRoundness = 150;

  late double responsiveIconSize = _height / (_hDevHeight / iconSize);
  late double responsiveIconPadding = _height / (_hDevHeight / iconPadding);
  late double responsiveIconTextFontSize =
      _width / (_hDevWidth / iconTextFontSize);
  late double responsiveButtonLength = _width / (_hDevWidth / buttonLength);
  late double responsiveButtonRoundness = _width / (_hDevWidth / buttonRoundness);

  void _onTapTakeECGBtn(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) => CameraPage(_width, _height),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // set screen orientation to landscape
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: const Text(
          "Capturing ECG through Facial Analysis",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.red,
      ),
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.all(responsiveIconPadding),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    style: ButtonStyle(fixedSize: MaterialStateProperty.all(Size(responsiveButtonLength, responsiveButtonRoundness))),
                      onPressed: () {
                        _onTapTakeECGBtn(context);
                      },
                      icon: Image.asset(
                          'assets/facial_analysis/face-scan_2818147.png',
                          width: responsiveIconSize,
                          height: responsiveIconSize,
                          fit: BoxFit.contain),
                      label: Text('Take ECG',
                          style:
                              TextStyle(fontSize: responsiveIconTextFontSize, color: Colors.purple ))),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(responsiveIconPadding),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                      style: ButtonStyle(fixedSize: MaterialStateProperty.all(Size(responsiveButtonLength, responsiveButtonRoundness))),
                      onPressed: () {},
                      icon: Image.asset(
                          'assets/facial_analysis/electrocardiogram.png',
                          width: responsiveIconSize,
                          height: responsiveIconSize,
                          fit: BoxFit.contain),
                      label: Text('View past readings',
                          style:
                          TextStyle(fontSize: responsiveIconTextFontSize, color: Colors.purple))),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
