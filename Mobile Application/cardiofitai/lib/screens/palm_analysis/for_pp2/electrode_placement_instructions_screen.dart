import 'package:flutter/material.dart';

class ElectrodePlacementInstructionsScreen extends StatelessWidget {
  const ElectrodePlacementInstructionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Palm Analysis"),
      ),
      backgroundColor: Colors.white,
      body: Row(
        children: [
          Column(
            children: [
              Text("Instructions"),
              Text("Place the electrodes along with the correct color")
            ],
          ),
          Image.asset(
            "assets/palm_analysis/electrode_placement_palms.png",
            scale: 15,
          )
        ],
      ),
    );
  }
}
