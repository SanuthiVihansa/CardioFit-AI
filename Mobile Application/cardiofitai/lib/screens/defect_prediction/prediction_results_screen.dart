import 'package:flutter/material.dart';

class PredictionResultsScreen extends StatelessWidget {
  final String predictedDisease;

  const PredictionResultsScreen({required this.predictedDisease});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: Text(
          "Prediction Results",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.red,
      ),
      body: Center(
        child: Text(
          'ECG Status : $predictedDisease',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }

//Prediction results
}
