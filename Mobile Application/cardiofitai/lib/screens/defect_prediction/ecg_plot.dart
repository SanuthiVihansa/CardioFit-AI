import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class ECGDiagnosisScreen extends StatefulWidget {
  final File file; // Define the file parameter

  const ECGDiagnosisScreen({Key? key, required this.file}) : super(key: key);

  @override
  _ECGDiagnosisScreenState createState() => _ECGDiagnosisScreenState();
}

class _ECGDiagnosisScreenState extends State<ECGDiagnosisScreen> {
  File? _selectedFile;
  String _predictedLabel = '';
  List<double> _ecgData = [];

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    _selectedFile = widget.file; // Assign the file from widget parameter
    _processFile();
  }

  Future<void> _processFile() async {
    try {
      // Read the file and plot ECG
      List<double> ecgData = await _readFile(_selectedFile!);

      setState(() {
        _ecgData = ecgData;
      });

      // Predict label from web service
      String predictedLabel = await _predictLabel(_selectedFile!);
      setState(() {
        _predictedLabel = predictedLabel;
      });
    } catch (e) {
      print('Error: $e');
      // Handle error
    }
  }

  Future<List<double>> _readFile(File file) async {
    String fileContent = await file.readAsString();
    Map<String, dynamic> jsonData = json.decode(fileContent);

    if (jsonData.containsKey('l1')) {
      return (jsonData['l1'] as List).map<double>((value) {
        return value.toDouble();
      }).toList();
    } else {
      throw FormatException('No ECG data found in the file');
    }
  }

  Future<String> _predictLabel(File file) async {
    final url = Uri.parse('http://hilarinac.pythonanywhere.com/predict');
    var request = http.MultipartRequest('POST', url);
    request.files.add(await http.MultipartFile.fromPath('file', file.path));

    var response = await request.send();
    var responseBody = await response.stream.bytesToString();
    var jsonResponse = json.decode(responseBody);

    return jsonResponse['Predicted class'] ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: const Text(
          "ECG Diagnosis",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.red,
      ),
      body: Center(
        child: _predictedLabel.isNotEmpty
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Text(
                      'Diagnosis: $_predictedLabel',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(20.0),
                    child: SizedBox(
                      width: double.infinity,
                      height: 200,
                      child: LineChart(
                        LineChartData(
                          lineBarsData: [
                            LineChartBarData(
                              spots: List.generate(
                                _ecgData.length,
                                (index) =>
                                    FlSpot(index.toDouble(), _ecgData[index]),
                              ),
                              isCurved: false,
                              colors: [Colors.blue],
                              barWidth: 2,
                              isStrokeCapRound: true,
                              dotData: FlDotData(show: false),
                            ),
                          ],
                          minY: _ecgData.reduce(
                              (min, current) => min < current ? min : current),
                          maxY: _ecgData.reduce(
                              (max, current) => max > current ? max : current),
                          titlesData: FlTitlesData(
                            bottomTitles: SideTitles(
                              showTitles: true,
                              getTitles: (value) {
                                return "";
                              },
                            ),
                            leftTitles: SideTitles(showTitles: true),
                          ),
                          borderData: FlBorderData(
                            show: true,
                            border: Border.all(color: Colors.black),
                          ),
                          gridData: FlGridData(
                            show: true,
                            drawHorizontalLine: true,
                            drawVerticalLine: true,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Text(
                      'Diagnosis of Arrhythmias In Progress',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                  CircularProgressIndicator(),
                  // Show loading indicator while processing
                ],
              ),
      ),
    );
  }
}
