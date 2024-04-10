import 'package:cardiofitai/screens/dietaryplanprediction-homepage.dart';
import 'package:cardiofitai/screens/ocr_reader.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const CardioFitAi());
}

class CardioFitAi extends StatefulWidget {
  const CardioFitAi({super.key});


  @override
  State<CardioFitAi> createState() => _CardioFitAiState();
}

class _CardioFitAiState extends State<CardioFitAi> {
  late double _width;
  late double _height;
  @override
  Widget build(BuildContext context) {
    //Geeting the screen width and height for screen responsiveness
    _width = MediaQuery.of(context).size.width;
    _height = MediaQuery.of(context).size.height;
    return MaterialApp(home: MyHomePage());
  }
}
