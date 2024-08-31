//Both Leads with extracted features
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import '../../models/user.dart';
import '../../services/user_information_service.dart';
import 'EmergencyDialog.dart';

class ECGDiagnosisScreen extends StatefulWidget {
  final File file;
  final User user;

  const ECGDiagnosisScreen({Key? key, required this.file, required this.user})
      : super(key: key);

  @override
  _ECGDiagnosisScreenState createState() => _ECGDiagnosisScreenState();
}

class _ECGDiagnosisScreenState extends State<ECGDiagnosisScreen> {
  File? _selectedFile;
  String _predictedLabel = '';
  List<double> _ecgDataLead1 = [];
  List<double> _ecgDataLead2 = [];
  bool _isLoading = true;
  String _errorMessage = '';
  Map<String, List<int>> _featureIndicesLead1 = {};
  Map<String, List<int>> _featureIndicesLead2 = {};

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    _selectedFile = widget.file;
    _processFile();
  }

  // Future<void> _processFile() async {
  //   try {
  //     var ecgData = await _readFile(_selectedFile!);
  //
  //     setState(() {
  //       _ecgDataLead1 = ecgData['lead1']!;
  //       _ecgDataLead2 = ecgData['lead2']!;
  //     });
  //
  //     String predictedLabel = await _predictLabel(_selectedFile!);
  //     setState(() {
  //       _predictedLabel = predictedLabel;
  //       _isLoading = false;
  //     });
  //
  //     // Extract features for both leads
  //     _extractFeatures(_ecgDataLead1, _featureIndicesLead1);
  //     _extractFeatures(_ecgDataLead2, _featureIndicesLead2);
  //
  //     // Check for emergency condition
  //     if (predictedLabel == 'Incomplete Right Bundle Branch Block') {
  //       _showEmergencyDialog(widget.user.memberRelationship);
  //     }
  //   } catch (e) {
  //     setState(() {
  //       _errorMessage = 'Error: $e';
  //       _isLoading = false;
  //     });
  //   }
  // }

  Future<void> _processFile() async {
    try {
      var ecgData = await _readFile(_selectedFile!);

      setState(() {
        _ecgDataLead1 = ecgData['lead1']!;
        _ecgDataLead2 = ecgData['lead2']!;
      });

      String predictedLabel = await _predictLabel(_selectedFile!);
      setState(() {
        _predictedLabel = predictedLabel;
        _isLoading = false;
      });

      // Determine the cardiac condition based on the predicted label
      String cardiacCondition = (predictedLabel == 'Normal') ? 'Yes' : 'No';

      // Update the user's cardiac condition in Firestore
      await _updateCardiacCondition(cardiacCondition);

      // Extract features for both leads
      _extractFeatures(_ecgDataLead1, _featureIndicesLead1);
      _extractFeatures(_ecgDataLead2, _featureIndicesLead2);

      // Check for emergency condition
      if (predictedLabel == 'Incomplete Right Bundle Branch Block' ||
          predictedLabel == 'Abnormal QRS' ||
          predictedLabel == 'Inferior Myocardial Infarction' ||
          predictedLabel == 'Ventricular Tachycardia') {
        _showEmergencyDialog(widget.user.memberRelationship);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _updateCardiacCondition(String cardiacCondition) async {
    try {
      // Create an instance of the UserLoginService
      UserLoginService userLoginService = UserLoginService();

      // Update the user object with the new cardiac condition
      User updatedUser =
          widget.user.copyWith(cardiacCondition: cardiacCondition);

      // Call the updateUser method to save the changes in Firestore
      await UserLoginService.updateUser(updatedUser);

      setState(() {
        widget.user.cardiacCondition =
            cardiacCondition; // Update the local user object
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to update cardiac condition: $e';
      });
    }
  }

  Future<Map<String, List<double>>> _readFile(File file) async {
    try {
      String fileContent = await file.readAsString();
      Map<String, dynamic> jsonData = jsonDecode(fileContent);

      if (jsonData.containsKey('l1') && jsonData.containsKey('l2')) {
        List<double> lead1 = (jsonData['l1'] as List<dynamic>)
            .map<double>((value) => value.toDouble())
            .toList();
        List<double> lead2 = (jsonData['l2'] as List<dynamic>)
            .map<double>((value) => value.toDouble())
            .toList();
        return {
          'lead1': lead1,
          'lead2': lead2,
        };
      } else {
        throw FormatException('No ECG data found in the file');
      }
    } catch (e) {
      throw FormatException('Failed to read the file: $e');
    }
  }

  Future<String> _predictLabel(File file) async {
    try {
      final url = Uri.parse('http://hilarinac.pythonanywhere.com/predict');
      var request = http.MultipartRequest('POST', url);
      request.files.add(await http.MultipartFile.fromPath('file', file.path));

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();
      var jsonResponse = json.decode(responseBody);

      return jsonResponse['Predicted class'] ?? '';
    } catch (e) {
      throw Exception('Failed to predict label: $e');
    }
  }

  void _extractFeatures(
      List<double> ecgData, Map<String, List<int>> featureIndices) {
    List<int> rPeaks = _detectRPeaks(ecgData);
    featureIndices['P wave'] = [];
    featureIndices['Q wave'] = [];
    featureIndices['R wave'] = rPeaks;
    featureIndices['S wave'] = [];
    featureIndices['T wave'] = [];

    for (int rPeak in rPeaks) {
      int qWave = _detectQWave(ecgData, rPeak);
      int sWave = _detectSWave(ecgData, rPeak);
      int tWave = _detectTWave(ecgData, rPeak);
      int pWave = _detectPWave(ecgData, rPeak);

      featureIndices['Q wave']?.add(qWave);
      featureIndices['S wave']?.add(sWave);
      featureIndices['T wave']?.add(tWave);
      featureIndices['P wave']?.add(pWave);
    }
  }

  List<int> _detectRPeaks(List<double> data) {
    List<int> rPeaks = [];
    for (int i = 1; i < data.length - 1; i++) {
      if (data[i] > data[i - 1] && data[i] > data[i + 1] && data[i] > 0.5) {
        rPeaks.add(i);
      }
    }
    return rPeaks;
  }

  int _detectQWave(List<double> data, int rPeak) {
    for (int i = rPeak; i > 0; i--) {
      if (data[i] < data[rPeak] / 2) {
        return i;
      }
    }
    return rPeak - 10;
  }

  int _detectSWave(List<double> data, int rPeak) {
    for (int i = rPeak; i < data.length; i++) {
      if (data[i] < data[rPeak] / 2) {
        return i;
      }
    }
    return rPeak + 10;
  }

  int _detectTWave(List<double> data, int rPeak) {
    for (int i = rPeak + 20; i < data.length; i++) {
      if (data[i] > data[rPeak] / 3) {
        return i;
      }
    }
    return rPeak + 30;
  }

  int _detectPWave(List<double> data, int rPeak) {
    for (int i = rPeak - 20; i > 0; i--) {
      if (data[i] > data[rPeak] / 3) {
        return i;
      }
    }
    return rPeak - 30;
  }

  void _showEmergencyDialog(String contactNumber) {
    showDialog(
      context: context,
      builder: (context) => EmergencyDialog(contactNumber: contactNumber),
    );
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
        child: _isLoading
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: const Text(
                      'Diagnosis of Arrhythmias In Progress',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                  const CircularProgressIndicator(),
                ],
              )
            : _errorMessage.isNotEmpty
                ? Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      _errorMessage,
                      style: const TextStyle(fontSize: 20, color: Colors.red),
                    ),
                  )
                : SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Text(
                            'Diagnosis: $_predictedLabel',
                            style: const TextStyle(fontSize: 20),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Lead 1',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 10),
                              SizedBox(
                                width: double.infinity,
                                height: 300,
                                child: Stack(
                                  children: [
                                    LineChart(
                                      LineChartData(
                                        lineBarsData: [
                                          LineChartBarData(
                                            spots: List.generate(
                                              _ecgDataLead1.length,
                                              (index) => FlSpot(
                                                  index.toDouble(),
                                                  _ecgDataLead1[index]),
                                            ),
                                            isCurved: false,
                                            colors: [Colors.blue],
                                            barWidth: 2,
                                            isStrokeCapRound: true,
                                            dotData: FlDotData(
                                              show: true,
                                              getDotPainter: (spot, xPercentage,
                                                  bar, index) {
                                                final feature =
                                                    _getFeatureNameByIndex(
                                                        index,
                                                        _featureIndicesLead1);
                                                if (feature != null) {
                                                  return FlDotCirclePainter(
                                                    radius: 3,
                                                    color: _getColorForFeature(
                                                        feature),
                                                    strokeWidth: 0,
                                                  );
                                                }
                                                return FlDotCirclePainter(
                                                  radius: 0,
                                                  color: Colors.transparent,
                                                  strokeWidth: 0,
                                                );
                                              },
                                            ),
                                          ),
                                        ],
                                        minY: _ecgDataLead1.reduce(
                                            (min, current) =>
                                                min < current ? min : current),
                                        maxY: _ecgDataLead1.reduce(
                                            (max, current) =>
                                                max > current ? max : current),
                                        titlesData: FlTitlesData(
                                          bottomTitles: SideTitles(
                                            showTitles: true,
                                            getTitles: (value) {
                                              // return value.toInt().toString();
                                              if (value % 500 == 0) {
                                                return (value ~/ 500)
                                                    .toString();
                                              } else {
                                                return "";
                                              }
                                            },
                                          ),
                                          leftTitles:
                                              SideTitles(showTitles: true),
                                        ),
                                        borderData: FlBorderData(
                                          show: true,
                                          border:
                                              Border.all(color: Colors.black),
                                        ),
                                        gridData: FlGridData(
                                          show: true,
                                          drawHorizontalLine: true,
                                          drawVerticalLine: true,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Lead 2',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 10),
                              SizedBox(
                                width: double.infinity,
                                height: 300,
                                child: Stack(
                                  children: [
                                    LineChart(
                                      LineChartData(
                                        lineBarsData: [
                                          LineChartBarData(
                                            spots: List.generate(
                                              _ecgDataLead2.length,
                                              (index) => FlSpot(
                                                  index.toDouble(),
                                                  _ecgDataLead2[index]),
                                            ),
                                            isCurved: false,
                                            colors: [Colors.blue],
                                            barWidth: 2,
                                            isStrokeCapRound: true,
                                            dotData: FlDotData(
                                              show: true,
                                              getDotPainter: (spot, xPercentage,
                                                  bar, index) {
                                                final feature =
                                                    _getFeatureNameByIndex(
                                                        index,
                                                        _featureIndicesLead2);
                                                if (feature != null) {
                                                  return FlDotCirclePainter(
                                                    radius: 3,
                                                    color: _getColorForFeature(
                                                        feature),
                                                    strokeWidth: 0,
                                                  );
                                                }
                                                return FlDotCirclePainter(
                                                  radius: 0,
                                                  color: Colors.transparent,
                                                  strokeWidth: 0,
                                                );
                                              },
                                            ),
                                          ),
                                        ],
                                        minY: _ecgDataLead2.reduce(
                                            (min, current) =>
                                                min < current ? min : current),
                                        maxY: _ecgDataLead2.reduce(
                                            (max, current) =>
                                                max > current ? max : current),
                                        titlesData: FlTitlesData(
                                          bottomTitles: SideTitles(
                                            showTitles: true,
                                            getTitles: (value) {
                                              if (value % 500 == 0) {
                                                return (value ~/ 500)
                                                    .toString();
                                              } else {
                                                return "";
                                              }
                                            },
                                          ),
                                          leftTitles:
                                              SideTitles(showTitles: true),
                                        ),
                                        borderData: FlBorderData(
                                          show: true,
                                          border:
                                              Border.all(color: Colors.black),
                                        ),
                                        gridData: FlGridData(
                                          show: true,
                                          drawHorizontalLine: true,
                                          drawVerticalLine: true,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildLegendItem('P wave', Colors.green),
                              _buildLegendItem('Q wave', Colors.orange),
                              _buildLegendItem('R wave', Colors.red),
                              _buildLegendItem('S wave', Colors.purple),
                              _buildLegendItem('T wave', Colors.yellow),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }

  Color _getColorForFeature(String featureName) {
    switch (featureName) {
      case 'P wave':
        return Colors.green;
      case 'Q wave':
        return Colors.orange;
      case 'R wave':
        return Colors.red;
      case 'S wave':
        return Colors.purple;
      case 'T wave':
        return Colors.yellow;
      default:
        return Colors.transparent;
    }
  }

  String? _getFeatureNameByIndex(
      int index, Map<String, List<int>> featureIndices) {
    if (featureIndices['P wave']!.contains(index)) {
      return 'P wave';
    } else if (featureIndices['Q wave']!.contains(index)) {
      return 'Q wave';
    } else if (featureIndices['R wave']!.contains(index)) {
      return 'R wave';
    } else if (featureIndices['S wave']!.contains(index)) {
      return 'S wave';
    } else if (featureIndices['T wave']!.contains(index)) {
      return 'T wave';
    } else {
      return null;
    }
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Icon(Icons.circle, color: color, size: 10),
        SizedBox(width: 5),
        Text(label),
        SizedBox(width: 10),
      ],
    );
  }
}
