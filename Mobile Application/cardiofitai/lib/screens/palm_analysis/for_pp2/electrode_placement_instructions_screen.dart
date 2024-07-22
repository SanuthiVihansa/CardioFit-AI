import 'package:cardiofitai/screens/palm_analysis/for_pp2/serial_monitor2.dart';
import 'package:flutter/material.dart';

class ElectrodePlacementInstructionsScreen extends StatelessWidget {
  ElectrodePlacementInstructionsScreen({super.key});

  late double _width;
  late double _height;
  final double _devWidth = 753.4545454545455;
  final double _devHeight = 392.72727272727275;

  void _onTapContinueBtn(BuildContext context) {
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (BuildContext) => SerialMonitor2()));
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
                  child: Text("Continue"))
            ],
          ),
          Image.asset(
            "assets/palm_analysis/electrode_placement_palms.png",
            scale: 1.5,
          )
        ],
      ),
    );
  }
}
