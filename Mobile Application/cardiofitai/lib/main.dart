import 'package:cardiofitai/screens/test.dart';
import 'package:flutter/material.dart';

void main(){
  runApp(CardioFitAi());
}

class CardioFitAi extends StatelessWidget {
  const CardioFitAi({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Test(),
    );
  }
}
