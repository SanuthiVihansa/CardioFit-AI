import 'package:cardiofitai/screens/defect_prediction/report_home_screen.dart';
import 'package:cardiofitai/screens/facial_analysis/facial_analysis_home.dart';
// import 'package:cardiofitai/screens/diet_plan/ocr_reader.dart';
import 'package:flutter/material.dart';
import 'package:cardiofitai/screens/firebase_testing/testing_firebase_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp( CardioFitAi());
}

class CardioFitAi extends StatelessWidget {
   CardioFitAi({super.key});

  late double _width;
  late double _height;

  @override
  Widget build(BuildContext context) {
    _width = MediaQuery.of(context).size.width;
    _height = MediaQuery.of(context).size.height;

    return  MaterialApp(
      color: Colors.red,
      // home: TestingFirebaseScreen(),
      home: ReportHome()
    );
  }
}
