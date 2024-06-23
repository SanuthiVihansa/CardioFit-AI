// // // import 'dart:async';
// // // import 'dart:convert';
// // // import 'dart:io';
// // // import 'package:flutter/material.dart';
// // // import 'package:fl_chart/fl_chart.dart';
// // // import 'package:flutter/services.dart';
// // // import 'package:http/http.dart' as http;
// // //
// // // class ECGDiagnosisScreen extends StatefulWidget {
// // //   final File file; // Define the file parameter
// // //
// // //   const ECGDiagnosisScreen({Key? key, required this.file}) : super(key: key);
// // //
// // //   @override
// // //   _ECGDiagnosisScreenState createState() => _ECGDiagnosisScreenState();
// // // }
// // //
// // // class _ECGDiagnosisScreenState extends State<ECGDiagnosisScreen> {
// // //   File? _selectedFile;
// // //   String _predictedLabel = '';
// // //   List<double> _ecgData = [];
// // //
// // //   @override
// // //   void initState() {
// // //     super.initState();
// // //     SystemChrome.setPreferredOrientations(
// // //         [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
// // //     _selectedFile = widget.file; // Assign the file from widget parameter
// // //     _processFile();
// // //   }
// // //
// // //   Future<void> _processFile() async {
// // //     try {
// // //       // Read the file and plot ECG
// // //       List<double> ecgData = await _readFile(_selectedFile!);
// // //
// // //       setState(() {
// // //         _ecgData = ecgData;
// // //       });
// // //
// // //       // Predict label from web service
// // //       String predictedLabel = await _predictLabel(_selectedFile!);
// // //       setState(() {
// // //         _predictedLabel = predictedLabel;
// // //       });
// // //     } catch (e) {
// // //       print('Error: $e');
// // //       // Handle error
// // //     }
// // //   }
// // //
// // //   Future<List<double>> _readFile(File file) async {
// // //     String fileContent = await file.readAsString();
// // //     Map<String, dynamic> jsonData = jsonDecode(fileContent);
// // //
// // //     if (jsonData.containsKey('l1')) {
// // //       return (jsonData['l1'] as List).map<double>((value) {
// // //         return value.toDouble();
// // //       }).toList();
// // //     } else {
// // //       throw FormatException('No ECG data found in the file');
// // //     }
// // //   }
// // //
// // //   Future<String> _predictLabel(File file) async {
// // //     final url = Uri.parse('http://hilarinac.pythonanywhere.com/predict');
// // //     var request = http.MultipartRequest('POST', url);
// // //     request.files.add(await http.MultipartFile.fromPath('file', file.path));
// // //
// // //     var response = await request.send();
// // //     var responseBody = await response.stream.bytesToString();
// // //     var jsonResponse = json.decode(responseBody);
// // //
// // //     return jsonResponse['Predicted class'] ?? '';
// // //   }
// // //
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return Scaffold(
// // //       appBar: AppBar(
// // //         foregroundColor: Colors.white,
// // //         title: const Text(
// // //           "ECG Diagnosis",
// // //           style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
// // //         ),
// // //         backgroundColor: Colors.red,
// // //       ),
// // //       body: Center(
// // //         child: _predictedLabel.isNotEmpty
// // //             ? Column(
// // //                 mainAxisAlignment: MainAxisAlignment.center,
// // //                 children: <Widget>[
// // //                   Padding(
// // //                     padding: EdgeInsets.all(20.0),
// // //                     child: Text(
// // //                       'Diagnosis: $_predictedLabel',
// // //                       style: TextStyle(fontSize: 20),
// // //                     ),
// // //                   ),
// // //                   Padding(
// // //                     padding: EdgeInsets.all(20.0),
// // //                     child: SizedBox(
// // //                       width: double.infinity,
// // //                       height: 200,
// // //                       child: LineChart(
// // //                         LineChartData(
// // //                           lineBarsData: [
// // //                             LineChartBarData(
// // //                               spots: List.generate(
// // //                                 _ecgData.length,
// // //                                 (index) =>
// // //                                     FlSpot(index.toDouble(), _ecgData[index]),
// // //                               ),
// // //                               isCurved: false,
// // //                               colors: [Colors.blue],
// // //                               barWidth: 2,
// // //                               isStrokeCapRound: true,
// // //                               dotData: FlDotData(show: false),
// // //                             ),
// // //                           ],
// // //                           minY: _ecgData.reduce(
// // //                               (min, current) => min < current ? min : current),
// // //                           maxY: _ecgData.reduce(
// // //                               (max, current) => max > current ? max : current),
// // //                           titlesData: FlTitlesData(
// // //                             bottomTitles: SideTitles(
// // //                               showTitles: true,
// // //                               getTitles: (value) {
// // //                                 return "";
// // //                               },
// // //                             ),
// // //                             leftTitles: SideTitles(showTitles: true),
// // //                           ),
// // //                           borderData: FlBorderData(
// // //                             show: true,
// // //                             border: Border.all(color: Colors.black),
// // //                           ),
// // //                           gridData: FlGridData(
// // //                             show: true,
// // //                             drawHorizontalLine: true,
// // //                             drawVerticalLine: true,
// // //                           ),
// // //                         ),
// // //                       ),
// // //                     ),
// // //                   ),
// // //                 ],
// // //               )
// // //             : Column(
// // //                 mainAxisAlignment: MainAxisAlignment.center,
// // //                 children: <Widget>[
// // //                   Padding(
// // //                     padding: EdgeInsets.all(20.0),
// // //                     child: Text(
// // //                       'Diagnosis of Arrhythmias In Progress',
// // //                       style: TextStyle(fontSize: 20),
// // //                     ),
// // //                   ),
// // //                   CircularProgressIndicator(),
// // //                   // Show loading indicator while processing
// // //                 ],
// // //               ),
// // //       ),
// // //     );
// // //   }
// // // }
// // //
// // //
// // // import 'dart:async';
// // // import 'dart:convert';
// // // import 'dart:io';
// // // import 'package:flutter/material.dart';
// // // import 'package:fl_chart/fl_chart.dart';
// // // import 'package:flutter/services.dart';
// // // import 'package:http/http.dart' as http;
// // //
// // // class ECGDiagnosisScreen extends StatefulWidget {
// // //   final File file;
// // //
// // //   const ECGDiagnosisScreen({Key? key, required this.file}) : super(key: key);
// // //
// // //   @override
// // //   _ECGDiagnosisScreenState createState() => _ECGDiagnosisScreenState();
// // // }
// // //
// // // class _ECGDiagnosisScreenState extends State<ECGDiagnosisScreen> {
// // //   File? _selectedFile;
// // //   String _predictedLabel = '';
// // //   List<double> _ecgData = [];
// // //   List<int> _pWaveIndices = [];
// // //   List<int> _qrsIndices = [];
// // //   List<Map<String, dynamic>> _prIntervals = [];
// // //   double _sampleRate = 250.0; // Define the sample rate of the ECG data
// // //
// // //   @override
// // //   void initState() {
// // //     super.initState();
// // //     SystemChrome.setPreferredOrientations(
// // //         [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
// // //     _selectedFile = widget.file;
// // //     _processFile();
// // //   }
// // //
// // //   Future<void> _processFile() async {
// // //     try {
// // //       List<double> ecgData = await _readFile(_selectedFile!);
// // //       setState(() {
// // //         _ecgData = ecgData;
// // //       });
// // //
// // //       String predictedLabel = await _predictLabel(_selectedFile!);
// // //       setState(() {
// // //         _predictedLabel = predictedLabel;
// // //       });
// // //
// // //       _pWaveIndices = _findPWaveIndices(ecgData);
// // //       _qrsIndices = _findQRSIndices(ecgData);
// // //       _prIntervals = _detectPRIntervals(ecgData, _pWaveIndices, _qrsIndices, _sampleRate);
// // //     } catch (e) {
// // //       print('Error: $e');
// // //     }
// // //   }
// // //
// // //   Future<List<double>> _readFile(File file) async {
// // //     try {
// // //       String fileContent = await file.readAsString();
// // //       print("File content: $fileContent");
// // //
// // //       Map<String, dynamic> jsonData = jsonDecode(fileContent);
// // //
// // //       if (jsonData.containsKey('l1')) {
// // //         return (jsonData['l1'] as List).map<double>((value) {
// // //           return value.toDouble();
// // //         }).toList();
// // //       } else {
// // //         throw FormatException('No ECG data found in the file');
// // //       }
// // //     } catch (e) {
// // //       print('Error reading file: $e');
// // //       throw e;
// // //     }
// // //   }
// // //
// // //   Future<String> _predictLabel(File file) async {
// // //     try {
// // //       final url = Uri.parse('http://hilarinac.pythonanywhere.com/predict');
// // //       var request = http.MultipartRequest('POST', url);
// // //       request.files.add(await http.MultipartFile.fromPath('file', file.path));
// // //
// // //       var response = await request.send();
// // //       var responseBody = await response.stream.bytesToString();
// // //       var jsonResponse = json.decode(responseBody);
// // //
// // //       return jsonResponse['Predicted class'] ?? '';
// // //     } catch (e) {
// // //       print('Error predicting label: $e');
// // //       throw e;
// // //     }
// // //   }
// // //
// // //   List<int> _findPWaveIndices(List<double> ecgData) {
// // //     // Placeholder logic for finding P wave indices
// // //     return [10, 50, 90]; // Replace with actual implementation
// // //   }
// // //
// // //   List<int> _findQRSIndices(List<double> ecgData) {
// // //     // Placeholder logic for finding QRS complex indices
// // //     return [20, 60, 100]; // Replace with actual implementation
// // //   }
// // //
// // //   List<Map<String, dynamic>> _detectPRIntervals(List<double> ecgData, List<int> pWaves, List<int> qrsIndices, double sampleRate) {
// // //     List<Map<String, dynamic>> prIntervals = [];
// // //     for (int qrs in qrsIndices) {
// // //       int closestPWave = pWaves.reduce((a, b) => (a - qrs).abs() < (b - qrs).abs() ? a : b);
// // //       double prIntervalSec = (qrs - closestPWave) / sampleRate;
// // //       prIntervals.add({'pWave': closestPWave, 'qrs': qrs, 'prIntervalSec': prIntervalSec});
// // //     }
// // //     return prIntervals;
// // //   }
// // //
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return Scaffold(
// // //       appBar: AppBar(
// // //         foregroundColor: Colors.white,
// // //         title: const Text(
// // //           "ECG Diagnosis",
// // //           style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
// // //         ),
// // //         backgroundColor: Colors.red,
// // //       ),
// // //       body: Center(
// // //         child: _predictedLabel.isNotEmpty
// // //             ? Column(
// // //           mainAxisAlignment: MainAxisAlignment.center,
// // //           children: <Widget>[
// // //             Padding(
// // //               padding: const EdgeInsets.all(20.0),
// // //               child: Text(
// // //                 'Diagnosis: $_predictedLabel',
// // //                 style: const TextStyle(fontSize: 20),
// // //               ),
// // //             ),
// // //             Padding(
// // //               padding: const EdgeInsets.all(20.0),
// // //               child: SizedBox(
// // //                 width: double.infinity,
// // //                 height: 200,
// // //                 child: LineChart(
// // //                   LineChartData(
// // //                     lineBarsData: [
// // //                       LineChartBarData(
// // //                         spots: List.generate(
// // //                           _ecgData.length,
// // //                               (index) =>
// // //                               FlSpot(index.toDouble(), _ecgData[index]),
// // //                         ),
// // //                         isCurved: false,
// // //                         colors: [Colors.blue],
// // //                         barWidth: 2,
// // //                         isStrokeCapRound: true,
// // //                         dotData: FlDotData(show: false),
// // //                       ),
// // //                     ],
// // //                     extraLinesData: ExtraLinesData(
// // //                       horizontalLines: _prIntervals.map((interval) {
// // //                         return HorizontalLine(
// // //                           y: _ecgData[interval['qrs']],
// // //                           color: Colors.red,
// // //                           strokeWidth: 2,
// // //                           label: HorizontalLineLabel(
// // //                             show: true,
// // //                             alignment: Alignment.topRight,
// // //                             style: TextStyle(
// // //                               color: Colors.red,
// // //                               fontSize: 12,
// // //                             ),
// // //                             labelResolver: (line) =>
// // //                             'PR: ${interval['prIntervalSec'].toStringAsFixed(3)}s',
// // //                           ),
// // //                         );
// // //                       }).toList(),
// // //                     ),
// // //                     minY: _ecgData.reduce(
// // //                             (min, current) => min < current ? min : current),
// // //                     maxY: _ecgData.reduce(
// // //                             (max, current) => max > current ? max : current),
// // //                     titlesData: FlTitlesData(
// // //                       bottomTitles: SideTitles(
// // //                         showTitles: true,
// // //                         getTitles: (value) => "",
// // //                       ),
// // //                       leftTitles: SideTitles(showTitles: true),
// // //                     ),
// // //                     borderData: FlBorderData(
// // //                       show: true,
// // //                       border: Border.all(color: Colors.black),
// // //                     ),
// // //                     gridData: FlGridData(
// // //                       show: true,
// // //                       drawHorizontalLine: true,
// // //                       drawVerticalLine: true,
// // //                     ),
// // //                   ),
// // //                 ),
// // //               ),
// // //             ),
// // //           ],
// // //         )
// // //             : Column(
// // //           mainAxisAlignment: MainAxisAlignment.center,
// // //           children: <Widget>[
// // //             const Padding(
// // //               padding: EdgeInsets.all(20.0),
// // //               child: Text(
// // //                 'Diagnosis of Arrhythmias In Progress',
// // //                 style: TextStyle(fontSize: 20),
// // //               ),
// // //             ),
// // //             const CircularProgressIndicator(),
// // //           ],
// // //         ),
// // //       ),
// // //     );
// // //   }
// // // }
// //
// // //plot
// // // import 'dart:async';
// // // import 'dart:convert';
// // // import 'dart:io';
// // // import 'package:flutter/material.dart';
// // // import 'package:fl_chart/fl_chart.dart';
// // // import 'package:flutter/services.dart';
// // // import 'package:http/http.dart' as http;
// // //
// // // class ECGDiagnosisScreen extends StatefulWidget {
// // //   final File file;
// // //
// // //   const ECGDiagnosisScreen({Key? key, required this.file}) : super(key: key);
// // //
// // //   @override
// // //   _ECGDiagnosisScreenState createState() => _ECGDiagnosisScreenState();
// // // }
// // //
// // // class _ECGDiagnosisScreenState extends State<ECGDiagnosisScreen> {
// // //   File? _selectedFile;
// // //   String _predictedLabel = '';
// // //   List<double> _ecgData = [];
// // //   List<int> _pWaveIndices = [];
// // //   List<int> _qrsIndices = [];
// // //   List<Map<String, dynamic>> _prIntervals = [];
// // //   List<Map<String, dynamic>> _stSegments = [];
// // //   double _sampleRate = 250.0; // Define the sample rate of the ECG data
// // //
// // //   @override
// // //   void initState() {
// // //     super.initState();
// // //     SystemChrome.setPreferredOrientations(
// // //         [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
// // //     _selectedFile = widget.file;
// // //     _processFile();
// // //   }
// // //
// // //   Future<void> _processFile() async {
// // //     try {
// // //       List<double> ecgData = await _readFile(_selectedFile!);
// // //       setState(() {
// // //         _ecgData = ecgData;
// // //       });
// // //
// // //       String predictedLabel = await _predictLabel(_selectedFile!);
// // //       setState(() {
// // //         _predictedLabel = predictedLabel;
// // //       });
// // //
// // //       _pWaveIndices = _findPWaveIndices(ecgData);
// // //       _qrsIndices = _findQRSIndices(ecgData);
// // //       _prIntervals = _detectPRIntervals(ecgData, _pWaveIndices, _qrsIndices, _sampleRate);
// // //       _stSegments = _detectSTSegments(ecgData, _qrsIndices, _sampleRate);
// // //     } catch (e) {
// // //       print('Error: $e');
// // //     }
// // //   }
// // //
// // //   Future<List<double>> _readFile(File file) async {
// // //     try {
// // //       String fileContent = await file.readAsString();
// // //       print("File content: $fileContent");
// // //
// // //       Map<String, dynamic> jsonData = jsonDecode(fileContent);
// // //
// // //       if (jsonData.containsKey('l1')) {
// // //         return (jsonData['l1'] as List).map<double>((value) {
// // //           return value.toDouble();
// // //         }).toList();
// // //       } else {
// // //         throw FormatException('No ECG data found in the file');
// // //       }
// // //     } catch (e) {
// // //       print('Error reading file: $e');
// // //       throw e;
// // //     }
// // //   }
// // //
// // //   Future<String> _predictLabel(File file) async {
// // //     try {
// // //       final url = Uri.parse('http://hilarinac.pythonanywhere.com/predict');
// // //       var request = http.MultipartRequest('POST', url);
// // //       request.files.add(await http.MultipartFile.fromPath('file', file.path));
// // //
// // //       var response = await request.send();
// // //       var responseBody = await response.stream.bytesToString();
// // //       var jsonResponse = json.decode(responseBody);
// // //
// // //       return jsonResponse['Predicted class'] ?? '';
// // //     } catch (e) {
// // //       print('Error predicting label: $e');
// // //       throw e;
// // //     }
// // //   }
// // //
// // //   List<int> _findPWaveIndices(List<double> ecgData) {
// // //     // Placeholder logic for finding P wave indices
// // //     return [10, 50, 90]; // Replace with actual implementation
// // //   }
// // //
// // //   List<int> _findQRSIndices(List<double> ecgData) {
// // //     // Placeholder logic for finding QRS complex indices
// // //     return [20, 60, 100]; // Replace with actual implementation
// // //   }
// // //
// // //   List<Map<String, dynamic>> _detectPRIntervals(List<double> ecgData, List<int> pWaves, List<int> qrsIndices, double sampleRate) {
// // //     List<Map<String, dynamic>> prIntervals = [];
// // //     for (int qrs in qrsIndices) {
// // //       int closestPWave = pWaves.reduce((a, b) => (a - qrs).abs() < (b - qrs).abs() ? a : b);
// // //       double prIntervalSec = (qrs - closestPWave) / sampleRate;
// // //       prIntervals.add({'pWave': closestPWave, 'qrs': qrs, 'prIntervalSec': prIntervalSec});
// // //     }
// // //     return prIntervals;
// // //   }
// // //
// // //   List<Map<String, dynamic>> _detectSTSegments(List<double> ecgData, List<int> qrsIndices, double sampleRate) {
// // //     List<Map<String, dynamic>> stSegments = [];
// // //     for (int qrsIndex in qrsIndices) {
// // //       int qrsEnd = qrsIndex + (0.1 * sampleRate).toInt();  // Assuming QRS complex duration is 0.1 seconds
// // //       if (qrsEnd >= ecgData.length) continue;
// // //
// // //       int searchStart = qrsEnd;
// // //       int searchEnd = (qrsIndex + (0.35 * sampleRate).toInt()).clamp(0, ecgData.length);
// // //       List<double> segment = ecgData.sublist(searchStart, searchEnd);
// // //
// // //       int minValueIndex = segment.indexOf(segment.reduce((a, b) => a < b ? a : b));
// // //       int tWaveStart = searchStart + minValueIndex;
// // //       double stSegmentDuration = (tWaveStart - qrsEnd) / sampleRate;
// // //
// // //       stSegments.add({'qrsEnd': qrsEnd, 'tWaveStart': tWaveStart, 'stSegmentDuration': stSegmentDuration});
// // //     }
// // //     return stSegments;
// // //   }
// // //
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return Scaffold(
// // //       appBar: AppBar(
// // //         foregroundColor: Colors.white,
// // //         title: const Text(
// // //           "ECG Diagnosis",
// // //           style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
// // //         ),
// // //         backgroundColor: Colors.red,
// // //       ),
// // //       body: Center(
// // //         child: _predictedLabel.isNotEmpty
// // //             ? Column(
// // //           mainAxisAlignment: MainAxisAlignment.center,
// // //           children: <Widget>[
// // //             Padding(
// // //               padding: const EdgeInsets.all(20.0),
// // //               child: Text(
// // //                 'Diagnosis: $_predictedLabel',
// // //                 style: const TextStyle(fontSize: 20),
// // //               ),
// // //             ),
// // //             Padding(
// // //               padding: const EdgeInsets.all(20.0),
// // //               child: SizedBox(
// // //                 width: double.infinity,
// // //                 height: 200,
// // //                 child: LineChart(
// // //                   LineChartData(
// // //                     lineBarsData: [
// // //                       LineChartBarData(
// // //                         spots: List.generate(
// // //                           _ecgData.length,
// // //                               (index) =>
// // //                               FlSpot(index.toDouble(), _ecgData[index]),
// // //                         ),
// // //                         isCurved: false,
// // //                         colors: [Colors.blue],
// // //                         barWidth: 2,
// // //                         isStrokeCapRound: true,
// // //                         dotData: FlDotData(show: false),
// // //                       ),
// // //                     ],
// // //                     extraLinesData: ExtraLinesData(
// // //                       horizontalLines: [
// // //                         ..._prIntervals.map((interval) {
// // //                           return HorizontalLine(
// // //                             y: _ecgData[interval['qrs']],
// // //                             color: Colors.orange,
// // //                             strokeWidth: 2,
// // //                             label: HorizontalLineLabel(
// // //                               show: true,
// // //                               alignment: Alignment.topRight,
// // //                               style: TextStyle(
// // //                                 color: Colors.orange,
// // //                                 fontSize: 12,
// // //                               ),
// // //                               labelResolver: (line) =>
// // //                               'PR: ${interval['prIntervalSec'].toStringAsFixed(3)}s',
// // //                             ),
// // //                           );
// // //                         }).toList(),
// // //                         ..._stSegments.map((segment) {
// // //                           return HorizontalLine(
// // //                             y: _ecgData[segment['tWaveStart']],
// // //                             color: Colors.green,
// // //                             strokeWidth: 2,
// // //                             label: HorizontalLineLabel(
// // //                               show: true,
// // //                               alignment: Alignment.topRight,
// // //                               style: TextStyle(
// // //                                 color: Colors.green,
// // //                                 fontSize: 12,
// // //                               ),
// // //                               labelResolver: (line) =>
// // //                               'ST: ${segment['stSegmentDuration'].toStringAsFixed(3)}s',
// // //                             ),
// // //                           );
// // //                         }).toList(),
// // //                       ],
// // //                     ),
// // //                     minY: _ecgData.reduce(
// // //                             (min, current) => min < current ? min : current),
// // //                     maxY: _ecgData.reduce(
// // //                             (max, current) => max > current ? max : current),
// // //                     titlesData: FlTitlesData(
// // //                       bottomTitles: SideTitles(
// // //                         showTitles: true,
// // //                         getTitles: (value) => "",
// // //                       ),
// // //                       leftTitles: SideTitles(showTitles: true),
// // //                     ),
// // //                     borderData: FlBorderData(
// // //                       show: true,
// // //                       border: Border.all(color: Colors.black),
// // //                     ),
// // //                     gridData: FlGridData(
// // //                       show: true,
// // //                       drawHorizontalLine: true,
// // //                       drawVerticalLine: true,
// // //                     ),
// // //                   ),
// // //                 ),
// // //               ),
// // //             ),
// // //           ],
// // //         )
// // //             : Column(
// // //           mainAxisAlignment: MainAxisAlignment.center,
// // //           children: <Widget>[
// // //             const Padding(
// // //               padding: EdgeInsets.all(20.0),
// // //               child: Text(
// // //                 'Diagnosis of Arrhythmias In Progress',
// // //                 style: TextStyle(fontSize: 20),
// // //               ),
// // //             ),
// // //             const CircularProgressIndicator(),
// // //           ],
// // //         ),
// // //       ),
// // //     );
// // //   }
// // // }
// //
// //
// // import 'dart:async';
// // import 'dart:convert';
// // import 'dart:io';
// // import 'package:flutter/material.dart';
// // import 'package:fl_chart/fl_chart.dart';
// // import 'package:flutter/services.dart';
// // import 'package:http/http.dart' as http;
// //
// // class ECGDiagnosisScreen extends StatefulWidget {
// //   final File file;
// //
// //   const ECGDiagnosisScreen({Key? key, required this.file}) : super(key: key);
// //
// //   @override
// //   _ECGDiagnosisScreenState createState() => _ECGDiagnosisScreenState();
// // }
// //
// // class _ECGDiagnosisScreenState extends State<ECGDiagnosisScreen> {
// //   File? _selectedFile;
// //   String _predictedLabel = '';
// //   List<double> _ecgData = [];
// //   List<int> _pWaveIndices = [];
// //   List<int> _qrsIndices = [];
// //   List<Map<String, dynamic>> _prIntervals = [];
// //   List<Map<String, dynamic>> _stSegments = [];
// //   List<Map<String, dynamic>> _qtIntervals = [];
// //   double _sampleRate = 250.0; // Define the sample rate of the ECG data
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     SystemChrome.setPreferredOrientations(
// //         [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
// //     _selectedFile = widget.file;
// //     _processFile();
// //   }
// //
// //   Future<void> _processFile() async {
// //     try {
// //       List<double> ecgData = await _readFile(_selectedFile!);
// //       setState(() {
// //         _ecgData = ecgData;
// //       });
// //
// //       String predictedLabel = await _predictLabel(_selectedFile!);
// //       setState(() {
// //         _predictedLabel = predictedLabel;
// //       });
// //
// //       _pWaveIndices = _findPWaveIndices(ecgData);
// //       _qrsIndices = _findQRSIndices(ecgData);
// //       _prIntervals = _detectPRIntervals(ecgData, _pWaveIndices, _qrsIndices, _sampleRate);
// //       _stSegments = _detectSTSegments(ecgData, _qrsIndices, _sampleRate);
// //       _qtIntervals = _detectQTIntervals(ecgData, _qrsIndices, _sampleRate);
// //     } catch (e) {
// //       print('Error: $e');
// //     }
// //   }
// //
// //   Future<List<double>> _readFile(File file) async {
// //     try {
// //       String fileContent = await file.readAsString();
// //       print("File content: $fileContent");
// //
// //       Map<String, dynamic> jsonData = jsonDecode(fileContent);
// //
// //       if (jsonData.containsKey('l1')) {
// //         return (jsonData['l1'] as List).map<double>((value) {
// //           return value.toDouble();
// //         }).toList();
// //       } else {
// //         throw FormatException('No ECG data found in the file');
// //       }
// //     } catch (e) {
// //       print('Error reading file: $e');
// //       throw e;
// //     }
// //   }
// //
// //   Future<String> _predictLabel(File file) async {
// //     try {
// //       final url = Uri.parse('http://hilarinac.pythonanywhere.com/predict');
// //       var request = http.MultipartRequest('POST', url);
// //       request.files.add(await http.MultipartFile.fromPath('file', file.path));
// //
// //       var response = await request.send();
// //       var responseBody = await response.stream.bytesToString();
// //       var jsonResponse = json.decode(responseBody);
// //
// //       return jsonResponse['Predicted class'] ?? '';
// //     } catch (e) {
// //       print('Error predicting label: $e');
// //       throw e;
// //     }
// //   }
// //
// //   List<int> _findPWaveIndices(List<double> ecgData) {
// //     // Placeholder logic for finding P wave indices
// //     return [10, 50, 90]; // Replace with actual implementation
// //   }
// //
// //   List<int> _findQRSIndices(List<double> ecgData) {
// //     // Placeholder logic for finding QRS complex indices
// //     return [20, 60, 100]; // Replace with actual implementation
// //   }
// //
// //   List<Map<String, dynamic>> _detectPRIntervals(List<double> ecgData, List<int> pWaves, List<int> qrsIndices, double sampleRate) {
// //     List<Map<String, dynamic>> prIntervals = [];
// //     for (int qrs in qrsIndices) {
// //       int closestPWave = pWaves.reduce((a, b) => (a - qrs).abs() < (b - qrs).abs() ? a : b);
// //       double prIntervalSec = (qrs - closestPWave) / sampleRate;
// //       prIntervals.add({'pWave': closestPWave, 'qrs': qrs, 'prIntervalSec': prIntervalSec});
// //     }
// //     return prIntervals;
// //   }
// //
// //   List<Map<String, dynamic>> _detectSTSegments(List<double> ecgData, List<int> qrsIndices, double sampleRate) {
// //     List<Map<String, dynamic>> stSegments = [];
// //     for (int qrsIndex in qrsIndices) {
// //       int qrsEnd = qrsIndex + (0.1 * sampleRate).toInt();  // Assuming QRS complex duration is 0.1 seconds
// //       if (qrsEnd >= ecgData.length) continue;
// //
// //       int searchStart = qrsEnd;
// //       int searchEnd = (qrsIndex + (0.35 * sampleRate).toInt()).clamp(0, ecgData.length);
// //       List<double> segment = ecgData.sublist(searchStart, searchEnd);
// //
// //       int minValueIndex = segment.indexOf(segment.reduce((a, b) => a < b ? a : b));
// //       int tWaveStart = searchStart + minValueIndex;
// //       double stSegmentDuration = (tWaveStart - qrsEnd) / sampleRate;
// //
// //       stSegments.add({'qrsEnd': qrsEnd, 'tWaveStart': tWaveStart, 'stSegmentDuration': stSegmentDuration});
// //     }
// //     return stSegments;
// //   }
// //
// //   List<Map<String, dynamic>> _detectQTIntervals(List<double> ecgData, List<int> qrsIndices, double sampleRate) {
// //     List<Map<String, dynamic>> qtIntervals = [];
// //     for (int qrsIndex in qrsIndices) {
// //       int qrsEnd = qrsIndex + (0.1 * sampleRate).toInt();  // Assuming QRS complex duration is 0.1 seconds
// //       if (qrsEnd >= ecgData.length) continue;
// //
// //       int searchStart = qrsIndex + (0.35 * sampleRate).toInt();  // Assuming maximum T wave duration is 0.35 seconds
// //       int searchEnd = (qrsIndex + (0.6 * sampleRate).toInt()).clamp(0, ecgData.length);  // Assuming maximum QT interval duration is 0.6 seconds
// //       List<double> segment = ecgData.sublist(searchStart, searchEnd);
// //
// //       int maxValueIndex = segment.indexOf(segment.reduce((a, b) => a > b ? a : b));
// //       int tWaveEnd = searchStart + maxValueIndex;
// //       double qtIntervalSec = (tWaveEnd - qrsIndex) / sampleRate;
// //
// //       qtIntervals.add({'qrsIndex': qrsIndex, 'tWaveEnd': tWaveEnd, 'qtIntervalSec': qtIntervalSec});
// //     }
// //     return qtIntervals;
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         foregroundColor: Colors.white,
// //         title: const Text(
// //           "ECG Diagnosis",
// //           style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
// //         ),
// //         backgroundColor: Colors.red,
// //       ),
// //       body: Center(
// //         child: _predictedLabel.isNotEmpty
// //             ? Column(
// //           mainAxisAlignment: MainAxisAlignment.center,
// //           children: <Widget>[
// //             Padding(
// //               padding: const EdgeInsets.all(20.0),
// //               child: Text(
// //                 'Diagnosis: $_predictedLabel',
// //                 style: const TextStyle(fontSize: 20),
// //               ),
// //             ),
// //             Padding(
// //               padding: const EdgeInsets.all(20.0),
// //               child: SizedBox(
// //                 width: double.infinity,
// //                 height: 200,
// //                 child: LineChart(
// //                   LineChartData(
// //                     lineBarsData: [
// //                       LineChartBarData(
// //                         spots: List.generate(
// //                           _ecgData.length,
// //                               (index) =>
// //                               FlSpot(index.toDouble(), _ecgData[index]),
// //                         ),
// //                         isCurved: false,
// //                         colors: [Colors.blue],
// //                         barWidth: 2,
// //                         isStrokeCapRound: true,
// //                         dotData: FlDotData(show: false),
// //                       ),
// //                     ],
// //                     extraLinesData: ExtraLinesData(
// //                       horizontalLines: [
// //                         ..._prIntervals.map((interval) {
// //                           return HorizontalLine(
// //                             y: _ecgData[interval['qrs']],
// //                             color: Colors.orange,
// //                             strokeWidth: 2,
// //                             label: HorizontalLineLabel(
// //                               show: true,
// //                               alignment: Alignment.topRight,
// //                               style: const TextStyle(
// //                                 color: Colors.orange,
// //                                 fontSize: 12,
// //                               ),
// //                               labelResolver: (line) =>
// //                               'PR: ${interval['prIntervalSec'].toStringAsFixed(3)}s',
// //                             ),
// //                           );
// //                         }).toList(),
// //                         ..._stSegments.map((segment) {
// //                           return HorizontalLine(
// //                             y: _ecgData[segment['tWaveStart']],
// //                             color: Colors.green,
// //                             strokeWidth: 2,
// //                             label: HorizontalLineLabel(
// //                               show: true,
// //                               alignment: Alignment.topRight,
// //                               style: const TextStyle(
// //                                 color: Colors.green,
// //                                 fontSize: 12,
// //                               ),
// //                               labelResolver: (line) =>
// //                               'ST: ${segment['stSegmentDuration'].toStringAsFixed(3)}s',
// //                             ),
// //                           );
// //                         }).toList(),
// //                         ..._qtIntervals.map((interval) {
// //                           return HorizontalLine(
// //                             y: _ecgData[interval['tWaveEnd']],
// //                             color: Colors.purple,
// //                             strokeWidth: 2,
// //                             label: HorizontalLineLabel(
// //                               show: true,
// //                               alignment: Alignment.topRight,
// //                               style: const TextStyle(
// //                                 color: Colors.purple,
// //                                 fontSize: 12,
// //                               ),
// //                               labelResolver: (line) =>
// //                               'QT: ${interval['qtIntervalSec'].toStringAsFixed(3)}s',
// //                             ),
// //                           );
// //                         }).toList(),
// //                       ],
// //                     ),
// //                     minY: _ecgData.reduce(
// //                             (min, current) => min < current ? min : current),
// //                     maxY: _ecgData.reduce(
// //                             (max, current) => max > current ? max : current),
// //                     titlesData: FlTitlesData(
// //                       bottomTitles: SideTitles(
// //                         showTitles: true,
// //                         getTitles: (value) {
// //                           return "";
// //                         },
// //                       ),
// //                       leftTitles: SideTitles(showTitles: true),
// //                     ),
// //                     borderData: FlBorderData(
// //                       show: true,
// //                       border: Border.all(color: Colors.black),
// //                     ),
// //                     gridData: FlGridData(
// //                       show: true,
// //                       drawHorizontalLine: true,
// //                       drawVerticalLine: true,
// //                     ),
// //                   ),
// //                 ),
// //               ),
// //             ),
// //           ],
// //         )
// //             : Column(
// //           mainAxisAlignment: MainAxisAlignment.center,
// //           children: <Widget>[
// //             const Padding(
// //               padding: EdgeInsets.all(20.0),
// //               child: Text(
// //                 'Diagnosis of Arrhythmias In Progress',
// //                 style: TextStyle(fontSize: 20),
// //               ),
// //             ),
// //             const CircularProgressIndicator(),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }
//
//
// import 'dart:async';
// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:fl_chart/fl_chart.dart';
// import 'package:flutter/services.dart';
// import 'package:http/http.dart' as http;
//
// class ECGDiagnosisScreen extends StatefulWidget {
//   final File file;
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
//   List<int> _pWaveIndices = [];
//   List<int> _qrsIndices = [];
//   List<Map<String, dynamic>> _prIntervals = [];
//   List<Map<String, dynamic>> _stSegments = [];
//   List<Map<String, dynamic>> _qtIntervals = [];
//   double _sampleRate = 250.0; // Define the sample rate of the ECG data
//
//   @override
//   void initState() {
//     super.initState();
//     SystemChrome.setPreferredOrientations(
//         [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
//     _selectedFile = widget.file;
//     _processFile();
//   }
//
//   Future<void> _processFile() async {
//     try {
//       List<double> ecgData = await _readFile(_selectedFile!);
//       setState(() {
//         _ecgData = ecgData;
//       });
//
//       String predictedLabel = await _predictLabel(_selectedFile!);
//       setState(() {
//         _predictedLabel = predictedLabel;
//       });
//
//       _pWaveIndices = _findPWaveIndices(ecgData);
//       _qrsIndices = _findQRSIndices(ecgData);
//       _prIntervals = _detectPRIntervals(ecgData, _pWaveIndices, _qrsIndices, _sampleRate);
//       _stSegments = _detectSTSegments(ecgData, _qrsIndices, _sampleRate);
//       _qtIntervals = _detectQTIntervals(ecgData, _qrsIndices, _sampleRate);
//     } catch (e) {
//       print('Error: $e');
//     }
//   }
//
//   Future<List<double>> _readFile(File file) async {
//     try {
//       String fileContent = await file.readAsString();
//       print("File content: $fileContent");
//
//       Map<String, dynamic> jsonData = jsonDecode(fileContent);
//
//       if (jsonData.containsKey('l1')) {
//         return (jsonData['l1'] as List).map<double>((value) {
//           return value.toDouble();
//         }).toList();
//       } else {
//         throw FormatException('No ECG data found in the file');
//       }
//     } catch (e) {
//       print('Error reading file: $e');
//       throw e;
//     }
//   }
//
//   Future<String> _predictLabel(File file) async {
//     try {
//       final url = Uri.parse('http://hilarinac.pythonanywhere.com/predict');
//       var request = http.MultipartRequest('POST', url);
//       request.files.add(await http.MultipartFile.fromPath('file', file.path));
//
//       var response = await request.send();
//       var responseBody = await response.stream.bytesToString();
//       var jsonResponse = json.decode(responseBody);
//
//       return jsonResponse['Predicted class'] ?? '';
//     } catch (e) {
//       print('Error predicting label: $e');
//       throw e;
//     }
//   }
//
//   List<int> _findPWaveIndices(List<double> ecgData) {
//     List<int> pWaves = [];
//     for (int qrs in _qrsIndices) {
//       int searchStart = (qrs - (0.2 * _sampleRate)).toInt().clamp(0, ecgData.length);
//       int searchEnd = (qrs - (0.08 * _sampleRate)).toInt().clamp(0, ecgData.length);
//
//       if (searchStart < searchEnd) {
//         List<double> segment = ecgData.sublist(searchStart, searchEnd);
//         int peakIndex = segment.indexOf(segment.reduce((a, b) => a > b ? a : b));
//         pWaves.add(searchStart + peakIndex);
//       }
//     }
//     return pWaves;
//   }
//
//   List<int> _findQRSIndices(List<double> ecgData) {
//     // Placeholder logic for finding QRS complex indices
//     return [20, 60, 100]; // Replace with actual implementation
//   }
//
//   List<Map<String, dynamic>> _detectPRIntervals(List<double> ecgData, List<int> pWaves, List<int> qrsIndices, double sampleRate) {
//     List<Map<String, dynamic>> prIntervals = [];
//     for (int qrs in qrsIndices) {
//       int closestPWave = pWaves.reduce((a, b) => (a - qrs).abs() < (b - qrs).abs() ? a : b);
//       double prIntervalSec = (qrs - closestPWave) / sampleRate;
//       prIntervals.add({'pWave': closestPWave, 'qrs': qrs, 'prIntervalSec': prIntervalSec});
//     }
//     return prIntervals;
//   }
//
//   List<Map<String, dynamic>> _detectSTSegments(List<double> ecgData, List<int> qrsIndices, double sampleRate) {
//     List<Map<String, dynamic>> stSegments = [];
//     for (int qrsIndex in qrsIndices) {
//       int qrsEnd = qrsIndex + (0.1 * sampleRate).toInt();  // Assuming QRS complex duration is 0.1 seconds
//       if (qrsEnd >= ecgData.length) continue;
//
//       int searchStart = qrsEnd;
//       int searchEnd = (qrsIndex + (0.35 * sampleRate).toInt()).clamp(0, ecgData.length);
//       List<double> segment = ecgData.sublist(searchStart, searchEnd);
//
//       int minValueIndex = segment.indexOf(segment.reduce((a, b) => a < b ? a : b));
//       int tWaveStart = searchStart + minValueIndex;
//       double stSegmentDuration = (tWaveStart - qrsEnd) / sampleRate;
//
//       stSegments.add({'qrsEnd': qrsEnd, 'tWaveStart': tWaveStart, 'stSegmentDuration': stSegmentDuration});
//     }
//     return stSegments;
//   }
//
//   List<Map<String, dynamic>> _detectQTIntervals(List<double> ecgData, List<int> qrsIndices, double sampleRate) {
//     List<Map<String, dynamic>> qtIntervals = [];
//     for (int qrsIndex in qrsIndices) {
//       int qrsEnd = qrsIndex + (0.1 * sampleRate).toInt();  // Assuming QRS complex duration is 0.1 seconds
//       if (qrsEnd >= ecgData.length) continue;
//
//       int searchStart = qrsIndex + (0.35 * sampleRate).toInt();  // Assuming maximum T wave duration is 0.35 seconds
//       int searchEnd = (qrsIndex + (0.6 * sampleRate).toInt()).clamp(0, ecgData.length);  // Assuming maximum QT interval duration is 0.6 seconds
//       List<double> segment = ecgData.sublist(searchStart, searchEnd);
//
//       int maxValueIndex = segment.indexOf(segment.reduce((a, b) => a > b ? a : b));
//       int tWaveEnd = searchStart + maxValueIndex;
//       double qtIntervalSec = (tWaveEnd - qrsIndex) / sampleRate;
//
//       qtIntervals.add({'qrsIndex': qrsIndex, 'tWaveEnd': tWaveEnd, 'qtIntervalSec': qtIntervalSec});
//     }
//     return qtIntervals;
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
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             Padding(
//               padding: const EdgeInsets.all(20.0),
//               child: Text(
//                 'Diagnosis: $_predictedLabel',
//                 style: const TextStyle(fontSize: 20),
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(20.0),
//               child: SizedBox(
//                 width: double.infinity,
//                 height: 200,
//                 child: LineChart(
//                   LineChartData(
//                     lineBarsData: [
//                       LineChartBarData(
//                         spots: List.generate(
//                           _ecgData.length,
//                               (index) =>
//                               FlSpot(index.toDouble(), _ecgData[index]),
//                         ),
//                         isCurved: false,
//                         colors: [Colors.blue],
//                         barWidth: 2,
//                         isStrokeCapRound: true,
//                         dotData: FlDotData(show: false),
//                       ),
//                       LineChartBarData(
//                         spots: _pWaveIndices
//                             .map((index) =>
//                             FlSpot(index.toDouble(), _ecgData[index]))
//                             .toList(),
//                         isCurved: false,
//                         colors: [Colors.red],
//                         barWidth: 2,
//                         isStrokeCapRound: true,
//                         dotData: FlDotData(
//                           show: true,
//                           getDotPainter: (spot, percent, barData, index) =>
//                               FlDotCirclePainter(
//                                 radius: 4,
//                                 color: Colors.red,
//                                 strokeWidth: 1,
//                                 strokeColor: Colors.red,
//                               ),
//                         ),
//                       ),
//                     ],
//                     extraLinesData: ExtraLinesData(
//                       horizontalLines: [
//                         ..._prIntervals.map((interval) {
//                           return HorizontalLine(
//                             y: _ecgData[interval['qrs']],
//                             color: Colors.orange,
//                             strokeWidth: 2,
//                             label: HorizontalLineLabel(
//                               show: true,
//                               alignment: Alignment.topRight,
//                               style: const TextStyle(
//                                 color: Colors.orange,
//                                 fontSize: 12,
//                               ),
//                               labelResolver: (line) =>
//                               'PR: ${interval['prIntervalSec'].toStringAsFixed(3)}s',
//                             ),
//                           );
//                         }).toList(),
//                         ..._stSegments.map((segment) {
//                           return HorizontalLine(
//                             y: _ecgData[segment['tWaveStart']],
//                             color: Colors.green,
//                             strokeWidth: 2,
//                             label: HorizontalLineLabel(
//                               show: true,
//                               alignment: Alignment.topRight,
//                               style: const TextStyle(
//                                 color: Colors.green,
//                                 fontSize: 12,
//                               ),
//                               labelResolver: (line) =>
//                               'ST: ${segment['stSegmentDuration'].toStringAsFixed(3)}s',
//                             ),
//                           );
//                         }).toList(),
//                         ..._qtIntervals.map((interval) {
//                           return HorizontalLine(
//                             y: _ecgData[interval['tWaveEnd']],
//                             color: Colors.purple,
//                             strokeWidth: 2,
//                             label: HorizontalLineLabel(
//                               show: true,
//                               alignment: Alignment.topRight,
//                               style: const TextStyle(
//                                 color: Colors.purple,
//                                 fontSize: 12,
//                               ),
//                               labelResolver: (line) =>
//                               'QT: ${interval['qtIntervalSec'].toStringAsFixed(3)}s',
//                             ),
//                           );
//                         }).toList(),
//                       ],
//                     ),
//                     minY: _ecgData.reduce(
//                             (min, current) => min < current ? min : current),
//                     maxY: _ecgData.reduce(
//                             (max, current) => max > current ? max : current),
//                     titlesData: FlTitlesData(
//                       bottomTitles: SideTitles(
//                         showTitles: true,
//                         getTitles: (value) {
//                           return "";
//                         },
//                       ),
//                       leftTitles: SideTitles(showTitles: true),
//                     ),
//                     borderData: FlBorderData(
//                       show: true,
//                       border: Border.all(color: Colors.black),
//                     ),
//                     gridData: FlGridData(
//                       show: true,
//                       drawHorizontalLine: true,
//                       drawVerticalLine: true,
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         )
//             : Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             const Padding(
//               padding: EdgeInsets.all(20.0),
//               child: Text(
//                 'Diagnosis of Arrhythmias In Progress',
//                 style: TextStyle(fontSize: 20),
//               ),
//             ),
//             const CircularProgressIndicator(),
//           ],
//         ),
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
  List<int> _pWaveIndices = [];
  List<int> _qrsIndices = [];
  List<Map<String, dynamic>> _prIntervals = [];
  List<Map<String, dynamic>> _stSegments = [];
  List<Map<String, dynamic>> _qtIntervals = [];
  double _sampleRate = 250.0; // Define the sample rate of the ECG data

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
      });

      _pWaveIndices = _findPWaveIndices(ecgData);
      _qrsIndices = _findQRSIndices(ecgData);
      _prIntervals = _detectPRIntervals(ecgData, _pWaveIndices, _qrsIndices, _sampleRate);
      _stSegments = _detectSTSegments(ecgData, _qrsIndices, _sampleRate);
      _qtIntervals = _detectQTIntervals(ecgData, _qrsIndices, _sampleRate);
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<List<double>> _readFile(File file) async {
    try {
      String fileContent = await file.readAsString();
      print("File content: $fileContent");

      Map<String, dynamic> jsonData = jsonDecode(fileContent);

      if (jsonData.containsKey('l1')) {
        return (jsonData['l1'] as List).map<double>((value) {
          return value.toDouble();
        }).toList();
      } else {
        throw FormatException('No ECG data found in the file');
      }
    } catch (e) {
      print('Error reading file: $e');
      throw e;
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
      print('Error predicting label: $e');
      throw e;
    }
  }

  List<int> _findPWaveIndices(List<double> ecgData) {
    List<int> pWaves = [];
    for (int qrs in _qrsIndices) {
      int searchStart = (qrs - (0.2 * _sampleRate)).toInt().clamp(0, ecgData.length);
      int searchEnd = (qrs - (0.08 * _sampleRate)).toInt().clamp(0, ecgData.length);

      if (searchStart < searchEnd) {
        List<double> segment = ecgData.sublist(searchStart, searchEnd);
        int peakIndex = segment.indexOf(segment.reduce((a, b) => a > b ? a : b));
        pWaves.add(searchStart + peakIndex);
      }
    }
    return pWaves;
  }

  List<int> _findQRSIndices(List<double> ecgData) {
    // Placeholder logic for finding QRS complex indices
    return [20, 60, 100]; // Replace with actual implementation
  }

  List<Map<String, dynamic>> _detectPRIntervals(List<double> ecgData, List<int> pWaves, List<int> qrsIndices, double sampleRate) {
    List<Map<String, dynamic>> prIntervals = [];
    for (int qrs in qrsIndices) {
      int closestPWave = pWaves.reduce((a, b) => (a - qrs).abs() < (b - qrs).abs() ? a : b);
      double prIntervalSec = (qrs - closestPWave) / sampleRate;
      prIntervals.add({'pWave': closestPWave, 'qrs': qrs, 'prIntervalSec': prIntervalSec});
    }
    return prIntervals;
  }

  List<Map<String, dynamic>> _detectSTSegments(List<double> ecgData, List<int> qrsIndices, double sampleRate) {
    List<Map<String, dynamic>> stSegments = [];
    for (int qrsIndex in qrsIndices) {
      int qrsEnd = qrsIndex + (0.1 * sampleRate).toInt();  // Assuming QRS complex duration is 0.1 seconds
      if (qrsEnd >= ecgData.length) continue;

      int searchStart = qrsEnd;
      int searchEnd = (qrsIndex + (0.35 * sampleRate).toInt()).clamp(0, ecgData.length);
      List<double> segment = ecgData.sublist(searchStart, searchEnd);

      int minValueIndex = segment.indexOf(segment.reduce((a, b) => a < b ? a : b));
      int tWaveStart = searchStart + minValueIndex;
      double stSegmentDuration = (tWaveStart - qrsEnd) / sampleRate;

      stSegments.add({'qrsEnd': qrsEnd, 'tWaveStart': tWaveStart, 'stSegmentDuration': stSegmentDuration});
    }
    return stSegments;
  }

  List<Map<String, dynamic>> _detectQTIntervals(List<double> ecgData, List<int> qrsIndices, double sampleRate) {
    List<Map<String, dynamic>> qtIntervals = [];
    for (int qrsIndex in qrsIndices) {
      int qrsEnd = qrsIndex + (0.1 * sampleRate).toInt();  // Assuming QRS complex duration is 0.1 seconds
      if (qrsEnd >= ecgData.length) continue;

      int searchStart = qrsIndex + (0.35 * sampleRate).toInt();  // Assuming maximum T wave duration is 0.35 seconds
      int searchEnd = (qrsIndex + (0.6 * sampleRate).toInt()).clamp(0, ecgData.length);  // Assuming maximum QT interval duration is 0.6 seconds
      List<double> segment = ecgData.sublist(searchStart, searchEnd);

      int maxValueIndex = segment.indexOf(segment.reduce((a, b) => a > b ? a : b));
      int tWaveEnd = searchStart + maxValueIndex;
      double qtIntervalSec = (tWaveEnd - qrsIndex) / sampleRate;

      qtIntervals.add({'qrsIndex': qrsIndex, 'tWaveEnd': tWaveEnd, 'qtIntervalSec': qtIntervalSec});
    }
    return qtIntervals;
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
                      LineChartBarData(
                        spots: _pWaveIndices
                            .map((index) =>
                            FlSpot(index.toDouble(), _ecgData[index]))
                            .toList(),
                        isCurved: false,
                        colors: [Colors.red],
                        barWidth: 2,
                        isStrokeCapRound: true,
                        dotData: FlDotData(
                          show: true,
                          getDotPainter: (spot, percent, barData, index) =>
                              FlDotCirclePainter(
                                radius: 4,
                                color: Colors.red,
                                strokeWidth: 1,
                                strokeColor: Colors.red,
                              ),
                        ),
                      ),
                    ],
                    extraLinesData: ExtraLinesData(
                      horizontalLines: [
                        ..._prIntervals.map((interval) {
                          return HorizontalLine(
                            y: _ecgData[interval['qrs']],
                            color: Colors.orange,
                            strokeWidth: 2,
                            label: HorizontalLineLabel(
                              show: true,
                              alignment: Alignment.topRight,
                              style: const TextStyle(
                                color: Colors.orange,
                                fontSize: 12,
                              ),
                              labelResolver: (line) =>
                              'PR: ${interval['prIntervalSec'].toStringAsFixed(3)}s',
                            ),
                          );
                        }).toList(),
                        ..._stSegments.map((segment) {
                          return HorizontalLine(
                            y: _ecgData[segment['tWaveStart']],
                            color: Colors.green,
                            strokeWidth: 2,
                            label: HorizontalLineLabel(
                              show: true,
                              alignment: Alignment.topRight,
                              style: const TextStyle(
                                color: Colors.green,
                                fontSize: 12,
                              ),
                              labelResolver: (line) =>
                              'ST: ${segment['stSegmentDuration'].toStringAsFixed(3)}s',
                            ),
                          );
                        }).toList(),
                        ..._qtIntervals.map((interval) {
                          return HorizontalLine(
                            y: _ecgData[interval['tWaveEnd']],
                            color: Colors.purple,
                            strokeWidth: 2,
                            label: HorizontalLineLabel(
                              show: true,
                              alignment: Alignment.topRight,
                              style: const TextStyle(
                                color: Colors.purple,
                                fontSize: 12,
                              ),
                              labelResolver: (line) =>
                              'QT: ${interval['qtIntervalSec'].toStringAsFixed(3)}s',
                            ),
                          );
                        }).toList(),
                      ],
                    ),
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
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    color: Colors.red,
                  ),
                  const SizedBox(width: 5),
                  const Text('P Waves', style: TextStyle(fontSize: 16)),
                ],
              ),
            ),
          ],
        )
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: Text(
                'Diagnosis of Arrhythmias In Progress',
                style: TextStyle(fontSize: 20),
              ),
            ),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
