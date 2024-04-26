import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cardiofitai/screens/palm_analysis/all_lead_prediction_screen.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:http/http.dart' as http;

class FileSelectionScreen extends StatefulWidget {
  const FileSelectionScreen({super.key});

  @override
  State<FileSelectionScreen> createState() => _FileSelectionScreenState();
}

class _FileSelectionScreenState extends State<FileSelectionScreen> {
  late List<double> _tenSecData = [];
  double _maxValue = 0;
  double _minValue = 0;

  final String _upServerUrl =
      'http://poornasenadheera100.pythonanywhere.com/upforunet';

  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);

    initConnectivity();

    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);

    _upServer();
  }

  Future<void> initConnectivity() async {
    late List<ConnectivityResult> result;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      print('Couldn\'t check connectivity status $e');
      return;
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) {
      return Future.value(null);
    }

    return _updateConnectionStatus(result);
  }

  Future<void> _updateConnectionStatus(List<ConnectivityResult> result) async {
    setState(() {
      _connectionStatus = result;
    });
    print('Connectivity changed: $_connectionStatus');
  }

  void _connectionErrorMsg() {}

  void _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.custom,
        allowedExtensions: ["txt"]);

    if (result == null) return;

    final file = File(result.files.single.path.toString());
    String contents = await file.readAsString();
    contents = contents.substring(1);
    // print(contents);

    List<double> dataList = contents.split(',').map((String value) {
      return double.tryParse(value) ?? 0.0;
    }).toList();

    _tenSecData = dataList.sublist(0, 2560);
    _calcMinMax(_tenSecData);
    setState(() {});

    // print(_tenSecData);

    await DefaultCacheManager().emptyCache();
  }

  void _calcMinMax(List<double> data) {
    _minValue =
        data.reduce((value, element) => value < element ? value : element) -
            0.5;
    _maxValue =
        data.reduce((value, element) => value > element ? value : element) +
            0.5;
  }

  Widget _ecgPlot() {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 1, left: 16, right: 16),
      child: LineChart(
        LineChartData(
          lineBarsData: [
            LineChartBarData(
              spots: List.generate(
                _tenSecData.length,
                (index) => FlSpot(index.toDouble(), _tenSecData[index]),
              ),
              isCurved: false,
              colors: [Colors.blue],
              barWidth: 2,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: false,
              ),
            ),
          ],
          minY: _minValue,
          // Adjust these values based on your data range
          maxY: _maxValue,
          titlesData: FlTitlesData(
            bottomTitles: SideTitles(
              showTitles: true,
              getTitles: (value) {
                if (value % 250 == 0) {
                  return (value ~/ 250).toString();
                } else {
                  return "";
                }
              },
            ),
            leftTitles: SideTitles(
              showTitles: true,
            ),
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

  Future<void> _onClickBtnProceed() async {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) =>
                AllLeadPredictionScreen(_tenSecData)));
  }

  Future<void> _upServer() async {
    await http.get(Uri.parse(_upServerUrl), headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: Text(
          "Cardiac Analysis Through Palms",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.red,
      ),
      body: _tenSecData.length == 0
          ? Center(
              child: ElevatedButton(
                child: const Text("Select file"),
                onPressed: () {
                  _pickFile();
                },
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 10, left: 20),
                  child: Text(
                    "Lead II ECG Signal",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                ),
                Expanded(child: SizedBox(child: _ecgPlot())),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10.0, right: 10),
                      child: ElevatedButton(
                          onPressed: () {
                            _onClickBtnProceed();
                          },
                          child: const Text("Proceed")),
                    ),
                  ],
                )
              ],
            ),
    );
  }
}
