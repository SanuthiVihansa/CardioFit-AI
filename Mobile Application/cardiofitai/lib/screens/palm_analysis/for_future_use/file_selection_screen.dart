import 'dart:async';
import 'dart:io';
import 'package:cardiofitai/screens/palm_analysis/for_future_use/all_lead_prediction_screen.dart';
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
  late double _width;
  late double _height;
  final double _devWidth = 753.4545454545455;
  final double _devHeight = 392.72727272727275;

  late List<double> _tenSecData = [];
  double _maxValue = 0;
  double _minValue = 0;

  bool _hasConnection = false;

  final String _upServerUrl =
      'http://poornasenadheera100.pythonanywhere.com/upforunet';

  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  final Connectivity _connectivity = Connectivity();

  // ignore: unused_field
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);

    initConnectivity();

    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  Future<void> initConnectivity() async {
    late List<ConnectivityResult> result;
    try {
      result = await _connectivity.checkConnectivity();
      // ignore: unused_catch_clause
    } on PlatformException catch (e) {
      // print('Could not check connectivity status $e');
      return;
    }
    if (!mounted) {
      return Future.value(null);
    }

    return _updateConnectionStatus(result);
  }

  Future<void> _updateConnectionStatus(List<ConnectivityResult> result) async {
    setState(() {
      _connectionStatus = result;
    });
    // print('Connectivity changed: $_connectionStatus');
    _checkNetwork(_connectionStatus[0]);
  }

  void _checkNetwork(ConnectivityResult result) {
    if (result != ConnectivityResult.none) {
      _hasConnection = true;
      _upServer();
    } else {
      _hasConnection = false;
    }
    setState(() {});

    if (!_hasConnection) {
      _showNetworkErrorMsg();
    }
  }

  Future<void> _showNetworkErrorMsg() async {
    await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text("No Internet"),
              actionsAlignment: MainAxisAlignment.center,
              content: const Text('Please connect to the network!'),
              actions: <Widget>[
                TextButton(
                  onPressed: () async {
                    return Navigator.pop(context, true);
                  },
                  child: const Text('OK'),
                ),
              ],
            ));
  }

  void _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.custom,
        allowedExtensions: ["txt"]);

    if (result == null) return;

    final file = File(result.files.single.path.toString());
    String contents = await file.readAsString();
    contents = contents.substring(1);

    List<double> dataList = contents.split(',').map((String value) {
      return double.tryParse(value) ?? 0.0;
    }).toList();

    _tenSecData = dataList.sublist(0, 2560);
    _calcMinMax(_tenSecData);
    setState(() {});

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
      padding: EdgeInsets.only(
          top: _height / (_devHeight / 16),
          bottom: _height / (_devHeight / 1),
          left: _width / (_devWidth / 16),
          right: _width / (_devWidth / 16)),
      child: IgnorePointer(
        ignoring: true,
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
    _width = MediaQuery.of(context).size.width;
    _height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: const Text(
          "Cardiac Analysis Through Palms",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.red,
      ),
      // ignore: prefer_is_empty
      body: _tenSecData.length == 0
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _hasConnection
                        ? () {
                            _pickFile();
                          }
                        : null,
                    style: ButtonStyle(
                      fixedSize: MaterialStateProperty.all<Size>(
                        Size(
                            _width / (_devWidth / 160.0),
                            _height /
                                (_devHeight / 40)), // Button width and height
                      ),
                    ),
                    child: Text(
                      "Select file",
                      style: TextStyle(fontSize: _width / (_devWidth / 10)),
                    ),
                  ),
                  !_hasConnection
                      ? Text(
                          "No Network Connection!",
                          style: TextStyle(
                              color: Colors.red,
                              fontSize: _width / (_devWidth / 10)),
                        )
                      : const SizedBox()
                ],
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(
                      top: _height / (_devHeight / 10),
                      left: _width / (_devWidth / 20)),
                  child: Text(
                    "Lead II ECG Signal",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: _width / (_devWidth / 20)),
                  ),
                ),
                Expanded(child: SizedBox(child: _ecgPlot())),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    !_hasConnection
                        ? Padding(
                            padding: EdgeInsets.only(
                                bottom: _height / (_devHeight / 10)),
                            child: Text(
                              "No Network Connection!",
                              style: TextStyle(
                                  color: Colors.red,
                                  fontSize: _width / (_devWidth / 10)),
                            ),
                          )
                        : const SizedBox(),
                    Padding(
                      padding: EdgeInsets.only(
                          bottom: _height / (_devHeight / 10),
                          right: _width / (_devWidth / 10),
                          left: _width / (_devWidth / 10)),
                      child: ElevatedButton(
                        onPressed: _hasConnection
                            ? () {
                                _onClickBtnProceed();
                              }
                            : null,
                        style: ButtonStyle(
                          fixedSize: MaterialStateProperty.all<Size>(
                            Size(
                                _width / (_devWidth / 160.0),
                                _height /
                                    (_devHeight /
                                        40)), // Button width and height
                          ),
                        ),
                        child: Text(
                          "Proceed",
                          style: TextStyle(fontSize: _width / (_devWidth / 10)),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
    );
  }
}
