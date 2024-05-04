// // // // import 'dart:async';
// // // // import 'dart:io';
// // // // import 'package:cardiofitai/screens/palm_analysis/all_lead_prediction_screen.dart';
// // // // import 'package:connectivity_plus/connectivity_plus.dart';
// // // // import 'package:file_picker/file_picker.dart';
// // // // import 'package:fl_chart/fl_chart.dart';
// // // // import 'package:flutter/material.dart';
// // // // import 'package:flutter/services.dart';
// // // // import 'package:flutter_cache_manager/flutter_cache_manager.dart';
// // // // import 'package:http/http.dart' as http;
// // // //
// // // // class ECGPlotScreen extends StatefulWidget {
// // // //   const ECGPlotScreen({super.key});
// // // //
// // // //   @override
// // // //   State<ECGPlotScreen> createState() => _FileSelectionScreenState();
// // // // }
// // // //
// // // // class _FileSelectionScreenState extends State<ECGPlotScreen> {
// // // //   late double _width;
// // // //   late double _height;
// // // //   final double _devWidth = 753.4545454545455;
// // // //   final double _devHeight = 392.72727272727275;
// // // //
// // // //   late List<double> _tenSecData = [];
// // // //   double _maxValue = 0;
// // // //   double _minValue = 0;
// // // //
// // // //   bool _hasConnection = false;
// // // //
// // // //   final String _upServerUrl =
// // // //       'http://poornasenadheera100.pythonanywhere.com/upforunet';
// // // //
// // // //   List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
// // // //   final Connectivity _connectivity = Connectivity();
// // // //
// // // //   // ignore: unused_field
// // // //   late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
// // // //
// // // //   @override
// // // //   void initState() {
// // // //     super.initState();
// // // //
// // // //     SystemChrome.setPreferredOrientations(
// // // //         [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
// // // //
// // // //     initConnectivity();
// // // //
// // // //     _connectivitySubscription =
// // // //         _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
// // // //   }
// // // //
// // // //   Future<void> initConnectivity() async {
// // // //     late List<ConnectivityResult> result;
// // // //     try {
// // // //       result = await _connectivity.checkConnectivity();
// // // //       // ignore: unused_catch_clause
// // // //     } on PlatformException catch (e) {
// // // //       // print('Could not check connectivity status $e');
// // // //       return;
// // // //     }
// // // //     if (!mounted) {
// // // //       return Future.value(null);
// // // //     }
// // // //
// // // //     return _updateConnectionStatus(result);
// // // //   }
// // // //
// // // //   Future<void> _updateConnectionStatus(List<ConnectivityResult> result) async {
// // // //     setState(() {
// // // //       _connectionStatus = result;
// // // //     });
// // // //     // print('Connectivity changed: $_connectionStatus');
// // // //     _checkNetwork(_connectionStatus[0]);
// // // //   }
// // // //
// // // //   void _checkNetwork(ConnectivityResult result) {
// // // //     if (result != ConnectivityResult.none) {
// // // //       _hasConnection = true;
// // // //       _upServer();
// // // //     } else {
// // // //       _hasConnection = false;
// // // //     }
// // // //     setState(() {});
// // // //
// // // //     if (!_hasConnection) {
// // // //       _showNetworkErrorMsg();
// // // //     }
// // // //   }
// // // //
// // // //   Future<void> _showNetworkErrorMsg() async {
// // // //     await showDialog<bool>(
// // // //         context: context,
// // // //         builder: (context) => AlertDialog(
// // // //           title: const Text("No Internet"),
// // // //           actionsAlignment: MainAxisAlignment.center,
// // // //           content: const Text('Please connect to the network!'),
// // // //           actions: <Widget>[
// // // //             TextButton(
// // // //               onPressed: () async {
// // // //                 return Navigator.pop(context, true);
// // // //               },
// // // //               child: const Text('OK'),
// // // //             ),
// // // //           ],
// // // //         ));
// // // //   }
// // // //
// // // //   void _pickFile() async {
// // // //     final result = await FilePicker.platform.pickFiles(
// // // //         allowMultiple: false,
// // // //         type: FileType.custom,
// // // //         allowedExtensions: ["txt"]);
// // // //
// // // //     if (result == null) return;
// // // //
// // // //     final file = File(result.files.single.path.toString());
// // // //     String contents = await file.readAsString();
// // // //     contents = contents.substring(1);
// // // //
// // // //     List<double> dataList = contents.split(',').map((String value) {
// // // //       return double.tryParse(value) ?? 0.0;
// // // //     }).toList();
// // // //
// // // //     _tenSecData = dataList.sublist(0, 2560);
// // // //     _calcMinMax(_tenSecData);
// // // //     setState(() {});
// // // //
// // // //     await DefaultCacheManager().emptyCache();
// // // //   }
// // // //
// // // //   void _calcMinMax(List<double> data) {
// // // //     _minValue =
// // // //         data.reduce((value, element) => value < element ? value : element) -
// // // //             0.5;
// // // //     _maxValue =
// // // //         data.reduce((value, element) => value > element ? value : element) +
// // // //             0.5;
// // // //   }
// // // //
// // // //   Widget _ecgPlot() {
// // // //     return Padding(
// // // //       padding: EdgeInsets.only(
// // // //           top: _height / (_devHeight / 16),
// // // //           bottom: _height / (_devHeight / 1),
// // // //           left: _width / (_devWidth / 16),
// // // //           right: _width / (_devWidth / 16)),
// // // //       child: IgnorePointer(
// // // //         ignoring: true,
// // // //         child: LineChart(
// // // //           LineChartData(
// // // //             lineBarsData: [
// // // //               LineChartBarData(
// // // //                 spots: List.generate(
// // // //                   _tenSecData.length,
// // // //                       (index) => FlSpot(index.toDouble(), _tenSecData[index]),
// // // //                 ),
// // // //                 isCurved: false,
// // // //                 colors: [Colors.blue],
// // // //                 barWidth: 2,
// // // //                 isStrokeCapRound: true,
// // // //                 dotData: FlDotData(
// // // //                   show: false,
// // // //                 ),
// // // //               ),
// // // //             ],
// // // //             minY: _minValue,
// // // //             // Adjust these values based on your data range
// // // //             maxY: _maxValue,
// // // //             titlesData: FlTitlesData(
// // // //               bottomTitles: SideTitles(
// // // //                 showTitles: true,
// // // //                 getTitles: (value) {
// // // //                   if (value % 250 == 0) {
// // // //                     return (value ~/ 250).toString();
// // // //                   } else {
// // // //                     return "";
// // // //                   }
// // // //                 },
// // // //               ),
// // // //               leftTitles: SideTitles(
// // // //                 showTitles: true,
// // // //               ),
// // // //             ),
// // // //             borderData: FlBorderData(
// // // //               show: true,
// // // //               border: Border.all(color: Colors.black),
// // // //             ),
// // // //             gridData: FlGridData(
// // // //               show: true,
// // // //               drawHorizontalLine: true,
// // // //               drawVerticalLine: true,
// // // //             ),
// // // //           ),
// // // //         ),
// // // //       ),
// // // //     );
// // // //   }
// // // //
// // // //   Future<void> _onClickBtnProceed() async {
// // // //     Navigator.push(
// // // //         context,
// // // //         MaterialPageRoute(
// // // //             builder: (BuildContext context) =>
// // // //                 AllLeadPredictionScreen(_tenSecData)));
// // // //   }
// // // //
// // // //   Future<void> _upServer() async {
// // // //     await http.get(Uri.parse(_upServerUrl), headers: <String, String>{
// // // //       'Content-Type': 'application/json; charset=UTF-8',
// // // //     });
// // // //   }
// // // //
// // // //   @override
// // // //   Widget build(BuildContext context) {
// // // //     _width = MediaQuery.of(context).size.width;
// // // //     _height = MediaQuery.of(context).size.height;
// // // //     return Scaffold(
// // // //       appBar: AppBar(
// // // //         foregroundColor: Colors.white,
// // // //         title: const Text(
// // // //           "Cardiac Analysis Through Palms",
// // // //           style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
// // // //         ),
// // // //         backgroundColor: Colors.red,
// // // //       ),
// // // //       // ignore: prefer_is_empty
// // // //       body: _tenSecData.length == 0
// // // //           ? Center(
// // // //         child: Column(
// // // //           mainAxisAlignment: MainAxisAlignment.center,
// // // //           children: [
// // // //             ElevatedButton(
// // // //               onPressed: _hasConnection
// // // //                   ? () {
// // // //                 _pickFile();
// // // //               }
// // // //                   : null,
// // // //               style: ButtonStyle(
// // // //                 fixedSize: MaterialStateProperty.all<Size>(
// // // //                   Size(
// // // //                       _width / (_devWidth / 160.0),
// // // //                       _height /
// // // //                           (_devHeight / 40)), // Button width and height
// // // //                 ),
// // // //               ),
// // // //               child: Text(
// // // //                 "Select file",
// // // //                 style: TextStyle(fontSize: _width / (_devWidth / 10)),
// // // //               ),
// // // //             ),
// // // //             !_hasConnection
// // // //                 ? Text(
// // // //               "No Network Connection!",
// // // //               style: TextStyle(
// // // //                   color: Colors.red,
// // // //                   fontSize: _width / (_devWidth / 10)),
// // // //             )
// // // //                 : const SizedBox()
// // // //           ],
// // // //         ),
// // // //       )
// // // //           : Column(
// // // //         crossAxisAlignment: CrossAxisAlignment.start,
// // // //         children: [
// // // //           Padding(
// // // //             padding: EdgeInsets.only(
// // // //                 top: _height / (_devHeight / 10),
// // // //                 left: _width / (_devWidth / 20)),
// // // //             child: Text(
// // // //               "Lead II ECG Signal",
// // // //               style: TextStyle(
// // // //                   fontWeight: FontWeight.bold,
// // // //                   fontSize: _width / (_devWidth / 20)),
// // // //             ),
// // // //           ),
// // // //           Expanded(child: SizedBox(child: _ecgPlot())),
// // // //           Row(
// // // //             mainAxisAlignment: MainAxisAlignment.end,
// // // //             children: [
// // // //               !_hasConnection
// // // //                   ? Padding(
// // // //                 padding: EdgeInsets.only(
// // // //                     bottom: _height / (_devHeight / 10)),
// // // //                 child: Text(
// // // //                   "No Network Connection!",
// // // //                   style: TextStyle(
// // // //                       color: Colors.red,
// // // //                       fontSize: _width / (_devWidth / 10)),
// // // //                 ),
// // // //               )
// // // //                   : const SizedBox(),
// // // //               Padding(
// // // //                 padding: EdgeInsets.only(
// // // //                     bottom: _height / (_devHeight / 10),
// // // //                     right: _width / (_devWidth / 10),
// // // //                     left: _width / (_devWidth / 10)),
// // // //                 child: ElevatedButton(
// // // //                   onPressed: _hasConnection
// // // //                       ? () {
// // // //                     _onClickBtnProceed();
// // // //                   }
// // // //                       : null,
// // // //                   style: ButtonStyle(
// // // //                     fixedSize: MaterialStateProperty.all<Size>(
// // // //                       Size(
// // // //                           _width / (_devWidth / 160.0),
// // // //                           _height /
// // // //                               (_devHeight /
// // // //                                   40)), // Button width and height
// // // //                     ),
// // // //                   ),
// // // //                   child: Text(
// // // //                     "Proceed",
// // // //                     style: TextStyle(fontSize: _width / (_devWidth / 10)),
// // // //                   ),
// // // //                 ),
// // // //               ),
// // // //             ],
// // // //           )
// // // //         ],
// // // //       ),
// // // //     );
// // // //   }
// // // // }
// // //
// // //
// // // import 'dart:convert';
// // // import 'dart:io';
// // //
// // // import 'package:file_picker/file_picker.dart';
// // // import 'package:flutter/material.dart';
// // // import 'package:fl_chart/fl_chart.dart';
// // //
// // // void main() {
// // //   runApp(MyApp());
// // // }
// // //
// // // class MyApp extends StatelessWidget {
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return MaterialApp(
// // //       home: ECGFilePickerScreen(),
// // //     );
// // //   }
// // // }
// // //
// // // class ECGFilePickerScreen extends StatefulWidget {
// // //   @override
// // //   _ECGFilePickerScreenState createState() => _ECGFilePickerScreenState();
// // // }
// // //
// // // class _ECGFilePickerScreenState extends State<ECGFilePickerScreen> {
// // //   File? _selectedFile;
// // //
// // //   void _selectFile() async {
// // //     FilePickerResult? result = await FilePicker.platform.pickFiles(
// // //       type: FileType.custom,
// // //       allowedExtensions: ['txt'], // Adjust as needed
// // //     );
// // //
// // //     if (result != null) {
// // //       setState(() {
// // //         _selectedFile = File(result.files.single.path!);
// // //       });
// // //     }
// // //   }
// // //
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return Scaffold(
// // //       appBar: AppBar(
// // //         title: Text('Upload ECG File'),
// // //       ),
// // //       body: Center(
// // //         child: Column(
// // //           mainAxisAlignment: MainAxisAlignment.center,
// // //           children: <Widget>[
// // //             ElevatedButton(
// // //               onPressed: _selectFile,
// // //               child: Text('Select ECG File'),
// // //             ),
// // //             if (_selectedFile != null)
// // //               Padding(
// // //                 padding: const EdgeInsets.all(20.0),
// // //                 child: Column(
// // //                   children: [
// // //                     Text('Selected File: ${_selectedFile!.path}'),
// // //                     ElevatedButton(
// // //                       onPressed: () {
// // //                         // Read the file content and pass it to ECGPlotWidget
// // //                         _readFileAndNavigateToECGPlotScreen(_selectedFile!);
// // //                       },
// // //                       child: Text('Plot ECG'),
// // //                     ),
// // //                   ],
// // //                 ),
// // //               ),
// // //           ],
// // //         ),
// // //       ),
// // //     );
// // //   }
// // //
// // //   void _readFileAndNavigateToECGPlotScreen(File file) async {
// // //     try {
// // //       String fileContent = await file.readAsString();
// // //       Navigator.push(
// // //         context,
// // //         MaterialPageRoute(
// // //           builder: (context) => ECGPlotWidget(
// // //             ecgData: fileContent,
// // //           ),
// // //         ),
// // //       );
// // //     } catch (e) {
// // //       print('Error reading file: $e');
// // //       // Handle error reading file
// // //     }
// // //   }
// // // }
// // //
// // // class ECGPlotWidget extends StatelessWidget {
// // //   final String ecgData; // ECG data from file
// // //
// // //   const ECGPlotWidget({required this.ecgData});
// // //
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     // Parse the ECG data and plot it
// // //     List<double> parsedData = _parseECGData(ecgData);
// // //
// // //     return Scaffold(
// // //       appBar: AppBar(
// // //         title: Text('ECG Plot'),
// // //       ),
// // //       body: Center(
// // //         child: SizedBox(
// // //           width: 300,
// // //           height: 200,
// // //           child: LineChart(
// // //             LineChartData(
// // //               lineBarsData: [
// // //                 LineChartBarData(
// // //                   spots: List.generate(
// // //                     parsedData.length,
// // //                         (index) => FlSpot(index.toDouble(), parsedData[index]),
// // //                   ),
// // //                   isCurved: false,
// // //                   colors: [Colors.blue],
// // //                   barWidth: 2,
// // //                   isStrokeCapRound: true,
// // //                   dotData: FlDotData(show: false),
// // //                 ),
// // //               ],
// // //               minY: parsedData.reduce((min, current) => min < current ? min : current),
// // //               maxY: parsedData.reduce((max, current) => max > current ? max : current),
// // //               titlesData: FlTitlesData(
// // //                 bottomTitles: SideTitles(showTitles: true),
// // //                 leftTitles: SideTitles(showTitles: true),
// // //               ),
// // //               borderData: FlBorderData(
// // //                 show: true,
// // //                 border: Border.all(color: Colors.black),
// // //               ),
// // //               gridData: FlGridData(
// // //                 show: true,
// // //                 drawHorizontalLine: true,
// // //                 drawVerticalLine: true,
// // //               ),
// // //             ),
// // //           ),
// // //         ),
// // //       ),
// // //     );
// // //   }
// // //
// // //   List<double> _parseECGData(String ecgData) {
// // //     // Parse ECG data from the file content
// // //     List<String> lines = ecgData.split('\n');
// // //     List<double> parsedData = [];
// // //
// // //     for (String line in lines) {
// // //       try {
// // //         parsedData.add(double.parse(line));
// // //       } catch (e) {
// // //         print('Error parsing line: $line');
// // //         // Handle error parsing line
// // //       }
// // //     }
// // //
// // //     return parsedData;
// // //   }
// // // }
// //
// //
// // import 'dart:convert';
// // import 'dart:io';
// //
// // import 'package:file_picker/file_picker.dart';
// // import 'package:flutter/material.dart';
// // import 'package:fl_chart/fl_chart.dart';
// //
// // void main() {
// //   runApp(MyApp());
// // }
// //
// // class MyApp extends StatelessWidget {
// //   @override
// //   Widget build(BuildContext context) {
// //     return MaterialApp(
// //       home: ECGFilePickerScreen(),
// //     );
// //   }
// // }
// //
// // class ECGFilePickerScreen extends StatefulWidget {
// //   @override
// //   _ECGFilePickerScreenState createState() => _ECGFilePickerScreenState();
// // }
// //
// // class _ECGFilePickerScreenState extends State<ECGFilePickerScreen> {
// //   File? _selectedFile;
// //
// //   void _selectFile() async {
// //     FilePickerResult? result = await FilePicker.platform.pickFiles(
// //       type: FileType.custom,
// //       allowedExtensions: ['txt'], // Adjust as needed
// //     );
// //
// //     if (result != null) {
// //       setState(() {
// //         _selectedFile = File(result.files.single.path!);
// //       });
// //     }
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: Text('Upload ECG File'),
// //       ),
// //       body: Center(
// //         child: Column(
// //           mainAxisAlignment: MainAxisAlignment.center,
// //           children: <Widget>[
// //             ElevatedButton(
// //               onPressed: _selectFile,
// //               child: Text('Select ECG File'),
// //             ),
// //             if (_selectedFile != null)
// //               Padding(
// //                 padding: const EdgeInsets.all(20.0),
// //                 child: Column(
// //                   children: [
// //                     Text('Selected File: ${_selectedFile!.path}'),
// //                     ElevatedButton(
// //                       onPressed: () {
// //                         // Read the file content and pass it to ECGPlotWidget
// //                         _readFileAndNavigateToECGPlotScreen(_selectedFile!);
// //                       },
// //                       child: Text('Plot ECG'),
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// //
// //   void _readFileAndNavigateToECGPlotScreen(File file) async {
// //     try {
// //       String fileContent = await file.readAsString();
// //       Navigator.push(
// //         context,
// //         MaterialPageRoute(
// //           builder: (context) => ECGPlotWidget(
// //             ecgData: fileContent,
// //           ),
// //         ),
// //       );
// //     } catch (e) {
// //       print('Error reading file: $e');
// //       // Handle error reading file
// //     }
// //   }
// // }
// //
// // class ECGPlotWidget extends StatelessWidget {
// //   final String ecgData; // ECG data from file
// //
// //   const ECGPlotWidget({required this.ecgData});
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     // Parse the ECG data and plot it
// //     List<double> parsedData = _parseECGData(ecgData);
// //
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: Text('ECG Plot'),
// //       ),
// //       body: Center(
// //         child: SizedBox(
// //           width: 300,
// //           height: 200,
// //           child: LineChart(
// //             LineChartData(
// //               lineBarsData: [
// //                 LineChartBarData(
// //                   spots: List.generate(
// //                     parsedData.length,
// //                         (index) => FlSpot(index.toDouble(), parsedData[index]),
// //                   ),
// //                   isCurved: false,
// //                   colors: [Colors.blue],
// //                   barWidth: 2,
// //                   isStrokeCapRound: true,
// //                   dotData: FlDotData(show: false),
// //                 ),
// //               ],
// //               minY: parsedData.reduce((min, current) => min < current ? min : current),
// //               maxY: parsedData.reduce((max, current) => max > current ? max : current),
// //               titlesData: FlTitlesData(
// //                 bottomTitles: SideTitles(showTitles: true),
// //                 leftTitles: SideTitles(showTitles: true),
// //               ),
// //               borderData: FlBorderData(
// //                 show: true,
// //                 border: Border.all(color: Colors.black),
// //               ),
// //               gridData: FlGridData(
// //                 show: true,
// //                 drawHorizontalLine: true,
// //                 drawVerticalLine: true,
// //               ),
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// //
// //   List<double> _parseECGData(String ecgData) {
// //     // Parse ECG data from the file content
// //     List<String> lines = ecgData.split('\n');
// //     List<double> parsedData = [];
// //
// //     for (String line in lines) {
// //       try {
// //         parsedData.add(double.parse(line));
// //       } catch (e) {
// //         print('Error parsing line: $line');
// //         // Handle error parsing line
// //       }
// //     }
// //
// //     return parsedData;
// //   }
// // }
//
// import 'dart:async';
// import 'dart:io';
// import 'package:file_picker/file_picker.dart';
// import 'package:flutter/material.dart';
// import 'package:fl_chart/fl_chart.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
//
// void main() {
//   runApp(MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: ECGFilePickerScreen(),
//     );
//   }
// }
//
// class ECGFilePickerScreen extends StatefulWidget {
//   @override
//   _ECGFilePickerScreenState createState() => _ECGFilePickerScreenState();
// }
//
// class _ECGFilePickerScreenState extends State<ECGFilePickerScreen> {
//   File? _selectedFile;
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('ECG File Picker'),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             ElevatedButton(
//               onPressed: _pickFile,
//               child: Text('Select ECG File'),
//             ),
//             if (_selectedFile != null)
//               Padding(
//                 padding: EdgeInsets.all(20.0),
//                 child: ElevatedButton(
//                   onPressed: () async {
//                     // Format and plot the ECG data
//                     List<double> ecgData = await _formatECGData(_selectedFile!);
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => ECGPlotScreen(ecgData: ecgData),
//                       ),
//                     );
//                   },
//                   child: Text('Plot ECG'),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Future<void> _pickFile() async {
//     FilePickerResult? result = await FilePicker.platform.pickFiles(
//       type: FileType.custom,
//       allowedExtensions: ['txt'],
//     );
//
//     if (result != null) {
//       setState(() {
//         _selectedFile = File(result.files.single.path!);
//       });
//     }
//   }
//
//   Future<List<double>> _formatECGData(File file) async {
//     String fileContent = await file.readAsString();
//     List<double> dataList = fileContent
//         .split(',')
//         .map((String value) => double.tryParse(value) ?? 0.0)
//         .toList();
//     return dataList;
//   }
// }
//
// class ECGPlotScreen extends StatelessWidget {
//   final List<double> ecgData;
//
//   const ECGPlotScreen({required this.ecgData});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('ECG Plot'),
//       ),
//       body: Padding(
//         padding: EdgeInsets.all(20.0),
//         child: LineChart(
//           LineChartData(
//             lineBarsData: [
//               LineChartBarData(
//                 spots: List.generate(
//                   ecgData.length,
//                       (index) => FlSpot(index.toDouble(), ecgData[index]),
//                 ),
//                 isCurved: false,
//                 colors: [Colors.blue],
//                 barWidth: 2,
//                 isStrokeCapRound: true,
//                 dotData: FlDotData(show: false),
//               ),
//             ],
//             minY: ecgData.reduce((min, current) => min < current ? min : current),
//             maxY: ecgData.reduce((max, current) => max > current ? max : current),
//             titlesData: FlTitlesData(
//               bottomTitles: SideTitles(showTitles: true),
//               leftTitles: SideTitles(showTitles: true),
//             ),
//             borderData: FlBorderData(
//               show: true,
//               border: Border.all(color: Colors.black),
//             ),
//             gridData: FlGridData(
//               show: true,
//               drawHorizontalLine: true,
//               drawVerticalLine: true,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// //LAST METHOD
//
import 'dart:async';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';


class ECGFilePickerScreen extends StatefulWidget {
  @override
  _ECGFilePickerScreenState createState() => _ECGFilePickerScreenState();
}

class _ECGFilePickerScreenState extends State<ECGFilePickerScreen> {
  File? _selectedFile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ECG File Picker'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: _pickFile,
              child: Text('Select ECG File'),
            ),
            if (_selectedFile != null)
              Padding(
                padding: EdgeInsets.all(20.0),
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to ECGPlotScreen and pass the selected file
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ECGPlotScreen(
                          selectedFile: _selectedFile!,
                        ),
                      ),
                    );
                  },
                  child: Text('Plot ECG'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['txt'],
    );

    if (result != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
      });
    }
  }
}

class ECGPlotScreen extends StatelessWidget {
  final File selectedFile;

  const ECGPlotScreen({required this.selectedFile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ECG Plot'),
      ),
      body: FutureBuilder(
        future: _readFile(selectedFile),
        builder: (context, AsyncSnapshot<List<double>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            List<double> ecgData = snapshot.data ?? [];
            return Padding(
              padding: EdgeInsets.all(20.0),
              child: LineChart(
                LineChartData(
                  lineBarsData: [
                    LineChartBarData(
                      spots: List.generate(
                        ecgData.length,
                            (index) => FlSpot(index.toDouble(), ecgData[index]),
                      ),
                      isCurved: false,
                      colors: [Colors.blue],
                      barWidth: 2,
                      isStrokeCapRound: true,
                      dotData: FlDotData(show: false),
                    ),
                  ],
                  minY: ecgData.reduce((min, current) => min < current ? min : current),
                  maxY: ecgData.reduce((max, current) => max > current ? max : current),
                  titlesData: FlTitlesData(
                    bottomTitles: SideTitles(showTitles: true),
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
            );
          }
        },
      ),
    );
  }

  Future<List<double>> _readFile(File file) async {
    String fileContent = await file.readAsString();
    List<double> dataList = fileContent.split(',').map((String value) {
      return double.tryParse(value) ?? 0.0;
    }).toList();
    return dataList;
  }
}
