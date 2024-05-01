import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'camera_page.dart';
import 'facial_analysis_reading.dart';

class FacialAnalysisHome extends StatelessWidget {
  FacialAnalysisHome(this._width, this._height, this._hDevHeight, this._hDevWidth, {super.key});

  // Height and width of current device
  final double _width, _height, _hDevWidth, _hDevHeight;

  //sizes and paddings
  final double iconSize = 100;
  final double iconPadding = 50;
  final double iconTextFontSize = 80;

  late double responsiveIconSize = _hDevHeight / (_height / iconSize);
  late double responsiveIconPadding = _hDevHeight / (_height / iconPadding);
  late double responsiveIconTextFontSize = _hDevWidth / (_width / iconTextFontSize);

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
    // SystemChrome.setPreferredOrientations([
    //   DeviceOrientation.landscapeLeft,
    //   DeviceOrientation.landscapeRight,
    // ]);

    return Scaffold(
      appBar: AppBar(
        title: const Text('CardioFit AI'),
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
                  IconButton(
                    iconSize: responsiveIconSize,
                    icon: const Icon(Icons.face_sharp),
                    onPressed: (){
                      _onTapTakeECGBtn(context);
                    },
                  ),
                  Text(
                      'Take ECG',
                    style: TextStyle(fontSize: responsiveIconTextFontSize),
                  )
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(responsiveIconPadding),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    iconSize: responsiveIconSize,
                    icon: const Icon(Icons.file_copy_rounded),
                    onPressed: (){},
                  ),
                  Text(
                      'View past readings',
                    style: TextStyle(fontSize: responsiveIconTextFontSize),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

