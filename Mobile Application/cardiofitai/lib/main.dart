import 'package:flutter/material.dart';
import 'package:cardiofitai/screens/firebase_testing/testing_firebase_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

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
