import 'package:cardiofitai/screens/common/login_exchange_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(CardioFitAi());
}

class CardioFitAi extends StatelessWidget {
  CardioFitAi({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: LoginExchangeScreen());
  }
}
