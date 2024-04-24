import 'package:cardiofitai/screens/facial_analysis/camera_page.dart';
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
  late double _vWidth;
  late double _vHeight;
  late double _hWidth;
  late double _hHeight;

  @override
  Widget build(BuildContext context) {
    // current device dimensions
    _width = MediaQuery.of(context).size.width;
    _height = MediaQuery.of(context).size.height;

    // development device dimensions
    // vertical
    _vWidth = 800.0;
    _vHeight = 1220.0;
    // horizontal
    _hWidth = 1280.0;
    _hHeight = 740.0;

    return MaterialApp(
      color: Colors.red,
      // home: TestingFirebaseScreen(),
      home: FacialAnalysisHome(_width, _height)
      // home: CameraPage(_width, _height),
    );
  }
}
