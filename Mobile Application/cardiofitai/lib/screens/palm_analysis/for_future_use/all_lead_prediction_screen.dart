import 'dart:convert';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class AllLeadPredictionScreen extends StatefulWidget {
  const AllLeadPredictionScreen(this.l2Data, {super.key});

  final List<double> l2Data;

  @override
  State<AllLeadPredictionScreen> createState() =>
      _AllLeadPredictionScreenState();
}

class _AllLeadPredictionScreenState extends State<AllLeadPredictionScreen> {
  late double _width;
  late double _height;
  final double _devWidth = 753.4545454545455;
  final double _devHeight = 392.72727272727275;

  final String _predictionApiUrl =
      'http://poornasenadheera100.pythonanywhere.com/predict';

  List<double> _l1Data = [];
  List<double> _l2Data = [];
  List<double> _l3Data = [];
  List<double> _avrData = [];
  List<double> _avlData = [];
  List<double> _avfData = [];
  List<double> _v1Data = [];
  List<double> _v2Data = [];
  List<double> _v3Data = [];
  List<double> _v4Data = [];
  List<double> _v5Data = [];
  List<double> _v6Data = [];

  int _resCode = 0;

  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    _getPredictions();
  }

  @override
  void dispose() {
    super.dispose();
  }

  double _calcMin(List<double> data) {
    double minValue =
        data.reduce((value, element) => value < element ? value : element) -
            0.1;
    return minValue;
  }

  double _calcMax(List<double> data) {
    double maxValue =
        data.reduce((value, element) => value > element ? value : element) +
            0.1;
    return maxValue;
  }

  Widget _ecgPlot(List<double> data, double minValue, double maxValue) {
    return Padding(
      padding: EdgeInsets.only(
          top: _height / (_devHeight / 1),
          left: _width / (_devWidth / 16),
          right: _width / (_devWidth / 16),
          bottom: _height / (_devHeight / 16)),
      child: IgnorePointer(
        ignoring: true,
        child: LineChart(
          LineChartData(
            lineBarsData: [
              LineChartBarData(
                spots: List.generate(
                  data.length,
                  (index) => FlSpot(index.toDouble(), data[index]),
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
            minY: minValue,
            // Adjust these values based on your data range
            maxY: maxValue,
            titlesData: FlTitlesData(
              bottomTitles: SideTitles(
                showTitles: true,
                getTitles: (value) {
                  if (value % 500 == 0) {
                    return (value ~/ 500).toString();
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

  Future<void> _getPredictions() async {
    try {
      Map<String, dynamic> data = {
        'l2': widget.l2Data,
      };
      String jsonString = jsonEncode(data);
      var response = await http
          .post(Uri.parse(_predictionApiUrl),
              headers: <String, String>{
                'Content-Type': 'application/json; charset=UTF-8',
              },
              body: jsonString)
          .timeout(const Duration(seconds: 30));

      _resCode = response.statusCode;

      if (_resCode == 200) {
        var decodedData = jsonDecode(response.body);
        _l1Data = List<double>.from(
            decodedData["l1"].map((element) => element.toDouble()));
        _l2Data = List<double>.from(
            decodedData["l2"].map((element) => element.toDouble()));
        _l3Data = List<double>.from(
            decodedData["l3"].map((element) => element.toDouble()));
        _avrData = List<double>.from(
            decodedData["avr"].map((element) => element.toDouble()));
        _avlData = List<double>.from(
            decodedData["avl"].map((element) => element.toDouble()));
        _avfData = List<double>.from(
            decodedData["avf"].map((element) => element.toDouble()));
        _v1Data = List<double>.from(
            decodedData["v1"].map((element) => element.toDouble()));
        _v2Data = List<double>.from(
            decodedData["v2"].map((element) => element.toDouble()));
        _v3Data = List<double>.from(
            decodedData["v3"].map((element) => element.toDouble()));
        _v4Data = List<double>.from(
            decodedData["v4"].map((element) => element.toDouble()));
        _v5Data = List<double>.from(
            decodedData["v5"].map((element) => element.toDouble()));
        _v6Data = List<double>.from(
            decodedData["v6"].map((element) => element.toDouble()));
      } else {
        // print('Failed to send data. Status code: ${_resCode}');
      }
    } catch (e) {
      _resCode = 408;
      _showTimeoutErrorMsg();
    }

    setState(() {});
  }

  Future<void> _showTimeoutErrorMsg() async {
    await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text("Request Timed Out!"),
              actionsAlignment: MainAxisAlignment.center,
              content: const Text(
                  'The request timed out. Please check your network connection.'),
              actions: <Widget>[
                TextButton(
                  onPressed: () async {
                    return Navigator.pop(context, true);
                  },
                  child: const Text('OK'),
                ),
              ],
            ));
    Navigator.pop(context);
  }

  void _onClickHomeBtn() {
    Navigator.pop(context);
    Navigator.pop(context);
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
        body: _resCode == 200
            ? Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                        top: _height / (_devHeight / 10),
                        left: _width / (_devWidth / 20),
                        right: _width / (_devWidth / 20)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "ECG Results",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: _width / (_devWidth / 20)),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            _onClickHomeBtn();
                          },
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
                            "Home",
                            style:
                                TextStyle(fontSize: _width / (_devWidth / 10)),
                          ),
                        )
                      ],
                    ),
                  ),
                  Expanded(
                    child: SizedBox(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "Lead I",
                              style: TextStyle(
                                  fontSize: _width / (_devWidth / 10)),
                            ),
                            SizedBox(
                                height: _height / (_devHeight / 200),
                                child: _ecgPlot(_l1Data, _calcMin(_l1Data),
                                    _calcMax(_l1Data))),
                            Text(
                              "Lead II",
                              style: TextStyle(
                                  fontSize: _width / (_devWidth / 10)),
                            ),
                            SizedBox(
                                height: _height / (_devHeight / 200),
                                child: _ecgPlot(_l2Data, _calcMin(_l2Data),
                                    _calcMax(_l2Data))),
                            Text(
                              "Lead III",
                              style: TextStyle(
                                  fontSize: _width / (_devWidth / 10)),
                            ),
                            SizedBox(
                                height: _height / (_devHeight / 200),
                                child: _ecgPlot(_l3Data, _calcMin(_l3Data),
                                    _calcMax(_l3Data))),
                            Text(
                              "Lead aVR",
                              style: TextStyle(
                                  fontSize: _width / (_devWidth / 10)),
                            ),
                            SizedBox(
                                height: _height / (_devHeight / 200),
                                child: _ecgPlot(_avrData, _calcMin(_avrData),
                                    _calcMax(_avrData))),
                            Text(
                              "Lead aVL",
                              style: TextStyle(
                                  fontSize: _width / (_devWidth / 10)),
                            ),
                            SizedBox(
                                height: _height / (_devHeight / 200),
                                child: _ecgPlot(_avlData, _calcMin(_avlData),
                                    _calcMax(_avlData))),
                            Text(
                              "Lead aVF",
                              style: TextStyle(
                                  fontSize: _width / (_devWidth / 10)),
                            ),
                            SizedBox(
                                height: _height / (_devHeight / 200),
                                child: _ecgPlot(_avfData, _calcMin(_avfData),
                                    _calcMax(_avfData))),
                            Text(
                              "Lead V1",
                              style: TextStyle(
                                  fontSize: _width / (_devWidth / 10)),
                            ),
                            SizedBox(
                                height: _height / (_devHeight / 200),
                                child: _ecgPlot(_v1Data, _calcMin(_v1Data),
                                    _calcMax(_v1Data))),
                            Text(
                              "Lead V2",
                              style: TextStyle(
                                  fontSize: _width / (_devWidth / 10)),
                            ),
                            SizedBox(
                                height: _height / (_devHeight / 200),
                                child: _ecgPlot(_v2Data, _calcMin(_v2Data),
                                    _calcMax(_v2Data))),
                            Text(
                              "Lead V3",
                              style: TextStyle(
                                  fontSize: _width / (_devWidth / 10)),
                            ),
                            SizedBox(
                                height: _height / (_devHeight / 200),
                                child: _ecgPlot(_v3Data, _calcMin(_v3Data),
                                    _calcMax(_v3Data))),
                            Text(
                              "Lead V4",
                              style: TextStyle(
                                  fontSize: _width / (_devWidth / 10)),
                            ),
                            SizedBox(
                                height: _height / (_devHeight / 200),
                                child: _ecgPlot(_v4Data, _calcMin(_v4Data),
                                    _calcMax(_v4Data))),
                            Text(
                              "Lead V5",
                              style: TextStyle(
                                  fontSize: _width / (_devWidth / 10)),
                            ),
                            SizedBox(
                                height: _height / (_devHeight / 200),
                                child: _ecgPlot(_v5Data, _calcMin(_v5Data),
                                    _calcMax(_v5Data))),
                            Text(
                              "Lead V6",
                              style: TextStyle(
                                  fontSize: _width / (_devWidth / 10)),
                            ),
                            SizedBox(
                                height: _height / (_devHeight / 200),
                                child: _ecgPlot(_v6Data, _calcMin(_v6Data),
                                    _calcMax(_v6Data))),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : _resCode == 0
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(),
                        Padding(
                          padding:
                              EdgeInsets.only(top: _height / (_devHeight / 10)),
                          child: Text(
                            "Loading...",
                            style:
                                TextStyle(fontSize: _width / (_devWidth / 10)),
                          ),
                        )
                      ],
                    ),
                  )
                : _resCode == 408
                    ? const Center(
                        child: Text("The request timed out!"),
                      )
                    : const Center(
                        child: Text("Error"),
                      ));
  }
}
