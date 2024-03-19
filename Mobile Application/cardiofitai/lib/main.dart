import 'package:cardiofitai/screens/palm_analysis/pmb_device_connection_screen.dart';
import 'package:flutter/material.dart';

void main(){
  runApp(CardioFitAi());
}

class CardioFitAi extends StatelessWidget {
  const CardioFitAi({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: PMBDeviceConnectionScreen(),
    );
  }
}
