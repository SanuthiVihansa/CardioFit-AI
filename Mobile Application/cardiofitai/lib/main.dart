import 'package:cardiofitai/screens/dietaryplanprediction-homepage.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const DietaryPlanHomePage());
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late double _width;
  late double _height;
  @override
  Widget build(BuildContext context) {
    //Geeting the screen width and height for screen responsiveness
    _width = MediaQuery.of(context).size.width;
    _height = MediaQuery.of(context).size.height;
    return MaterialApp(home: DietaryPlanHomePage(_width, _height));
  }
}
