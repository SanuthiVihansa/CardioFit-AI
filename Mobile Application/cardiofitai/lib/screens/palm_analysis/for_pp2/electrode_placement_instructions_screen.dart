import 'package:cardiofitai/screens/palm_analysis/for_pp2/serial_monitor.dart';
import 'package:flutter/material.dart';

class ElectrodePlacementInstructionsScreen extends StatelessWidget {
  ElectrodePlacementInstructionsScreen({super.key});

  late double _width;
  late double _height;
  final double _devWidth = 753.4545454545455;
  final double _devHeight = 392.72727272727275;

  void _onTapContinueBtn(BuildContext context) {
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (BuildContext) => SerialMonitor()));
  }

  @override
  Widget build(BuildContext context) {
    _width = MediaQuery.of(context).size.width;
    _height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        title: Text("Palm Analysis"),
      ),
      backgroundColor: Colors.white,
      body: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                "Instructions",
                style: TextStyle(fontSize: _width / (_devWidth / 30)),
              ),
              Text(
                "Place the electrodes along with the correct color",
                style: TextStyle(fontSize: _width / (_devWidth / 15)),
              ),
              ElevatedButton(
                  onPressed: () {
                    _onTapContinueBtn(context);
                  },
                  style: ButtonStyle(
                    fixedSize: MaterialStateProperty.all<Size>(
                      Size(
                          _width / (_devWidth / 160.0),
                          _height /
                              (_devHeight / 40)), // Button width and height
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Continue",
                        style: TextStyle(fontSize: _width / (_devWidth / 10)),
                      ),
                      Icon(
                        Icons.arrow_right_outlined,
                        size: _height / (_devHeight / 20),
                      )
                    ],
                  ))
            ],
          ),
          Image.asset(
            "assets/palm_analysis/3_electrode_placement_palms.png",
            scale: 1.5,
          )
        ],
      ),
    );
  }
}
