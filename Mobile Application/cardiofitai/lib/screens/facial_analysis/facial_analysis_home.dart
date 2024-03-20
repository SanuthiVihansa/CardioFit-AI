import 'package:flutter/material.dart';

class FacialAnalysisHome extends StatelessWidget {
  const FacialAnalysisHome(this._width, this._height, {super.key});

  // Height and width of current device
  final double _width;
  final double _height;

  final double iconSize = 100;
  final double iconPadding = 18;
  final double iconTextFontSize = 30;

  @override
  Widget build(BuildContext context) {
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
              padding: EdgeInsets.all(iconPadding),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    iconSize: iconSize,
                    icon: const Icon(Icons.face_sharp),
                    onPressed: (){},
                  ),
                  Text(
                      'Take ECG',
                    style: TextStyle(fontSize: iconTextFontSize),
                  )
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(iconPadding),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    iconSize: iconSize,
                    icon: const Icon(Icons.file_copy_rounded),
                    onPressed: (){},
                  ),
                  Text(
                      'View past readings',
                    style: TextStyle(fontSize: iconTextFontSize),
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

