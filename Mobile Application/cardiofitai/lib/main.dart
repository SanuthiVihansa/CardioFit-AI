import 'package:cardiofitai/screens/facial_analysis/facial_analysis_home.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  late double _width;
  late double _height;

  @override
  Widget build(BuildContext context) {
    _width = MediaQuery.of(context).size.width;
    _height = MediaQuery.of(context).size.height;

    return MaterialApp(
        home: FacialAnalysisHome(_width, _height)
    );
  }
}
