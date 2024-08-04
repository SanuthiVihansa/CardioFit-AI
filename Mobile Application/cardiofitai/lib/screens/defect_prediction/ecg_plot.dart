// import 'dart:async';
// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:fl_chart/fl_chart.dart';
// import 'package:flutter/services.dart';
// import 'package:http/http.dart' as http;
//
// class ECGDiagnosisScreen extends StatefulWidget {
//   final File file; // Define the file parameter
//
//   const ECGDiagnosisScreen({Key? key, required this.file}) : super(key: key);
//
//   @override
//   _ECGDiagnosisScreenState createState() => _ECGDiagnosisScreenState();
// }
//
// class _ECGDiagnosisScreenState extends State<ECGDiagnosisScreen> {
//   File? _selectedFile;
//   String _predictedLabel = '';
//   List<double> _ecgData = [];
//
//   @override
//   void initState() {
//     super.initState();
//     SystemChrome.setPreferredOrientations(
//         [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
//     _selectedFile = widget.file; // Assign the file from widget parameter
//     _processFile();
//   }
//
//   Future<void> _processFile() async {
//     try {
//       // Read the file and plot ECG
//       List<double> ecgData = await _readFile(_selectedFile!);
//
//       setState(() {
//         _ecgData = ecgData;
//       });
//
//       // Predict label from web service
//       String predictedLabel = await _predictLabel(_selectedFile!);
//       setState(() {
//         _predictedLabel = predictedLabel;
//       });
//     } catch (e) {
//       print('Error: $e');
//       // Handle error
//     }
//   }
//
//   Future<List<double>> _readFile(File file) async {
//     String fileContent = await file.readAsString();
//     Map<String, dynamic> jsonData = jsonDecode(fileContent);
//
//     if (jsonData.containsKey('l1')) {
//       return (jsonData['l1'] as List).map<double>((value) {
//         return value.toDouble();
//       }).toList();
//     } else {
//       throw FormatException('No ECG data found in the file');
//     }
//   }
//
//   Future<String> _predictLabel(File file) async {
//     final url = Uri.parse('http://hilarinac.pythonanywhere.com/predict');
//     var request = http.MultipartRequest('POST', url);
//     request.files.add(await http.MultipartFile.fromPath('file', file.path));
//
//     var response = await request.send();
//     var responseBody = await response.stream.bytesToString();
//     var jsonResponse = json.decode(responseBody);
//
//     return jsonResponse['Predicted class'] ?? '';
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         foregroundColor: Colors.white,
//         title: const Text(
//           "ECG Diagnosis",
//           style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
//         ),
//         backgroundColor: Colors.red,
//       ),
//       body: Center(
//         child: _predictedLabel.isNotEmpty
//             ? Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: <Widget>[
//                   Padding(
//                     padding: EdgeInsets.all(20.0),
//                     child: Text(
//                       'Diagnosis: $_predictedLabel',
//                       style: TextStyle(fontSize: 20),
//                     ),
//                   ),
//                   Padding(
//                     padding: EdgeInsets.all(20.0),
//                     child: SizedBox(
//                       width: double.infinity,
//                       height: 200,
//                       child: LineChart(
//                         LineChartData(
//                           lineBarsData: [
//                             LineChartBarData(
//                               spots: List.generate(
//                                 _ecgData.length,
//                                 (index) =>
//                                     FlSpot(index.toDouble(), _ecgData[index]),
//                               ),
//                               isCurved: false,
//                               colors: [Colors.blue],
//                               barWidth: 2,
//                               isStrokeCapRound: true,
//                               dotData: FlDotData(show: false),
//                             ),
//                           ],
//                           minY: _ecgData.reduce(
//                               (min, current) => min < current ? min : current),
//                           maxY: _ecgData.reduce(
//                               (max, current) => max > current ? max : current),
//                           titlesData: FlTitlesData(
//                             bottomTitles: SideTitles(
//                               showTitles: true,
//                               getTitles: (value) {
//                                 return "";
//                               },
//                             ),
//                             leftTitles: SideTitles(showTitles: true),
//                           ),
//                           borderData: FlBorderData(
//                             show: true,
//                             border: Border.all(color: Colors.black),
//                           ),
//                           gridData: FlGridData(
//                             show: true,
//                             drawHorizontalLine: true,
//                             drawVerticalLine: true,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               )
//             : Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: <Widget>[
//                   Padding(
//                     padding: EdgeInsets.all(20.0),
//                     child: Text(
//                       'Diagnosis of Arrhythmias In Progress',
//                       style: TextStyle(fontSize: 20),
//                     ),
//                   ),
//                   CircularProgressIndicator(),
//                   // Show loading indicator while processing
//                 ],
//               ),
//       ),
//     );
//   }
// }
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class ECGDiagnosisScreen extends StatefulWidget {
  final File file;

  const ECGDiagnosisScreen({Key? key, required this.file}) : super(key: key);

  @override
  _ECGDiagnosisScreenState createState() => _ECGDiagnosisScreenState();
}

class _ECGDiagnosisScreenState extends State<ECGDiagnosisScreen> {
  File? _selectedFile;
  String _predictedLabel = '';
  List<double> _ecgData = [];
  bool _isLoading = true;
  String _errorMessage = '';
  Map<String, List<int>> _featureIndices = {};

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    _selectedFile = widget.file;
    _processFile();
  }

  Future<void> _processFile() async {
    try {
      List<double> ecgData = await _readFile(_selectedFile!);

      setState(() {
        _ecgData = ecgData;
      });

      String predictedLabel = await _predictLabel(_selectedFile!);
      setState(() {
        _predictedLabel = predictedLabel;
        _isLoading = false;
      });

      // Extract features
      _extractFeatures();
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  Future<List<double>> _readFile(File file) async {
    try {
      String fileContent = await file.readAsString();
      Map<String, dynamic> jsonData = jsonDecode(fileContent);

      if (jsonData.containsKey('l1')) {
        return (jsonData['l1'] as List).map<double>((value) {
          return value.toDouble();
        }).toList();
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

  void _extractFeatures() {
    List<int> rPeaks = _detectRPeaks(_ecgData);
    Map<String, List<int>> featureIndices = {
      'P wave': [],
      'Q wave': [],
      'R wave': rPeaks,
      'S wave': [],
      'T wave': [],
    };

    for (int rPeak in rPeaks) {
      int qWave = _detectQWave(_ecgData, rPeak);
      int sWave = _detectSWave(_ecgData, rPeak);
      int tWave = _detectTWave(_ecgData, rPeak);
      int pWave = _detectPWave(_ecgData, rPeak);

      featureIndices['Q wave']?.add(qWave);
      featureIndices['S wave']?.add(sWave);
      featureIndices['T wave']?.add(tWave);
      featureIndices['P wave']?.add(pWave);
    }

    setState(() {
      _featureIndices = featureIndices;
    });
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
            : Column(
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
              child: SizedBox(
                width: double.infinity,
                height: 300,
                child: Stack(
                  children: [
                    LineChart(
                      LineChartData(
                        lineBarsData: [
                          LineChartBarData(
                            spots: List.generate(
                              _ecgData.length,
                                  (index) => FlSpot(
                                  index.toDouble(), _ecgData[index]),
                            ),
                            isCurved: false,
                            colors: [Colors.blue],
                            barWidth: 2,
                            isStrokeCapRound: true,
                            dotData: FlDotData(
                              show: true,
                              getDotPainter: (spot, xPercentage, bar, index) {
                                final feature = _getFeatureNameByIndex(index);
                                if (feature != null) {
                                  return FlDotCirclePainter(
                                    radius: 3,
                                    color: _getColorForFeature(feature),
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
                        minY: _ecgData.reduce(
                                (min, current) => min < current ? min : current),
                        maxY: _ecgData.reduce(
                                (max, current) => max > current ? max : current),
                        titlesData: FlTitlesData(
                          bottomTitles: SideTitles(
                            showTitles: true,
                            getTitles: (value) {
                              return value.toInt().toString();
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
                  ],
                ),
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

  String? _getFeatureNameByIndex(int index) {
    if (_featureIndices['P wave']!.contains(index)) {
      return 'P wave';
    } else if (_featureIndices['Q wave']!.contains(index)) {
      return 'Q wave';
    } else if (_featureIndices['R wave']!.contains(index)) {
      return 'R wave';
    } else if (_featureIndices['S wave']!.contains(index)) {
      return 'S wave';
    } else if (_featureIndices['T wave']!.contains(index)) {
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
