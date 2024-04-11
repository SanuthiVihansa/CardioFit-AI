import 'package:cardiofitai/screens/firebase_testing/testing_firebase_screen.dart';
import 'package:cardiofitai/screens/palm_analysis/pmb_device_connection_screen.dart';
import 'package:cardiofitai/screens/palm_analysis/bluetooth_testing/sample_bluetooth_screen.dart';
import 'package:cardiofitai/screens/palm_analysis/real_time_record.dart';
import 'package:cardiofitai/screens/dietaryplanprediction-homepage.dart';
import 'package:cardiofitai/screens/ocr_reader.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';

// import 'firebase_options.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const CardioFitAi());
}

class CardioFitAi extends StatelessWidget {
  const CardioFitAi({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      color: Colors.red,
      home: TestingFirebaseScreen(),
    );
  }
}
