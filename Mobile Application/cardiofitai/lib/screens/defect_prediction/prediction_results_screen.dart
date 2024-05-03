import 'package:flutter/material.dart';

class PredictionResultsScreen extends StatelessWidget {
  final String predictedDisease;

  const PredictionResultsScreen({required this.predictedDisease});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Prediction Results"),
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
