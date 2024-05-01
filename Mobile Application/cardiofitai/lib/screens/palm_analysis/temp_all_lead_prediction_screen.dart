import 'dart:convert';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class TempAllLeadPredictionScreen extends StatefulWidget {
  const TempAllLeadPredictionScreen(this.l1Data, this.l2Data, this.v1Data,
      this.v2Data, this.v3Data, this.v4Data, this.v5Data, this.v6Data,
      {super.key});

  final List<double> l1Data;
  final List<double> l2Data;
  final List<double> v1Data;
  final List<double> v2Data;
  final List<double> v3Data;
  final List<double> v4Data;
  final List<double> v5Data;
  final List<double> v6Data;

  @override
  State<TempAllLeadPredictionScreen> createState() =>
      _TempAllLeadPredictionScreenState();
}

class _TempAllLeadPredictionScreenState
    extends State<TempAllLeadPredictionScreen> {
  late double _width;
  late double _height;
  final double _devWidth = 753.4545454545455;
  final double _devHeight = 392.72727272727275;

  final String _predictionApiUrl =
      'http://poornasenadheera100.pythonanywhere.com/temppredict';

  List<double> _predl1Data = [];
  List<double> _actl2Data = [];
  List<double> _predl3Data = [];
  List<double> _predavrData = [];
  List<double> _predavlData = [];
  List<double> _predavfData = [];
  List<double> _predv1Data = [];
  List<double> _predv2Data = [];
  List<double> _predv3Data = [];
  List<double> _predv4Data = [];
  List<double> _predv5Data = [];
  List<double> _predv6Data = [];

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
        'l1' : widget.l1Data,
        'l2': widget.l2Data,
        'v1': widget.v1Data,
        'v2': widget.v2Data,
        'v3': widget.v3Data,
        'v4': widget.v4Data,
        'v5': widget.v5Data,
        'v6': widget.v6Data,
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
        _predl1Data = List<double>.from(
            decodedData["predl1"].map((element) => element.toDouble()));
        _actl2Data = List<double>.from(
            decodedData["actl2"].map((element) => element.toDouble()));
        _predl3Data = List<double>.from(
            decodedData["predl3"].map((element) => element.toDouble()));
        _predavrData = List<double>.from(
            decodedData["predavr"].map((element) => element.toDouble()));
        _predavlData = List<double>.from(
            decodedData["predavl"].map((element) => element.toDouble()));
        _predavfData = List<double>.from(
            decodedData["predavf"].map((element) => element.toDouble()));
        _predv1Data = List<double>.from(
            decodedData["predv1"].map((element) => element.toDouble()));
        _predv2Data = List<double>.from(
            decodedData["predv2"].map((element) => element.toDouble()));
        _predv3Data = List<double>.from(
            decodedData["predv3"].map((element) => element.toDouble()));
        _predv4Data = List<double>.from(
            decodedData["predv4"].map((element) => element.toDouble()));
        _predv5Data = List<double>.from(
            decodedData["predv5"].map((element) => element.toDouble()));
        _predv6Data = List<double>.from(
            decodedData["predv6"].map((element) => element.toDouble()));
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
                                child: _ecgPlot(_predl1Data, _calcMin(_predl1Data),
                                    _calcMax(_predl1Data))),
                            Text(
                              "Lead II",
                              style: TextStyle(
                                  fontSize: _width / (_devWidth / 10)),
                            ),
                            SizedBox(
                                height: _height / (_devHeight / 200),
                                child: _ecgPlot(_actl2Data, _calcMin(_actl2Data),
                                    _calcMax(_actl2Data))),
                            Text(
                              "Lead III",
                              style: TextStyle(
                                  fontSize: _width / (_devWidth / 10)),
                            ),
                            SizedBox(
                                height: _height / (_devHeight / 200),
                                child: _ecgPlot(_predl3Data, _calcMin(_predl3Data),
                                    _calcMax(_predl3Data))),
                            Text(
                              "Lead aVR",
                              style: TextStyle(
                                  fontSize: _width / (_devWidth / 10)),
                            ),
                            SizedBox(
                                height: _height / (_devHeight / 200),
                                child: _ecgPlot(_predavrData, _calcMin(_predavrData),
                                    _calcMax(_predavrData))),
                            Text(
                              "Lead aVL",
                              style: TextStyle(
                                  fontSize: _width / (_devWidth / 10)),
                            ),
                            SizedBox(
                                height: _height / (_devHeight / 200),
                                child: _ecgPlot(_predavlData, _calcMin(_predavlData),
                                    _calcMax(_predavlData))),
                            Text(
                              "Lead aVF",
                              style: TextStyle(
                                  fontSize: _width / (_devWidth / 10)),
                            ),
                            SizedBox(
                                height: _height / (_devHeight / 200),
                                child: _ecgPlot(_predavfData, _calcMin(_predavfData),
                                    _calcMax(_predavfData))),
                            Text(
                              "Lead V1",
                              style: TextStyle(
                                  fontSize: _width / (_devWidth / 10)),
                            ),
                            SizedBox(
                                height: _height / (_devHeight / 200),
                                child: _ecgPlot(_predv1Data, _calcMin(_predv1Data),
                                    _calcMax(_predv1Data))),
                            Text(
                              "Lead V2",
                              style: TextStyle(
                                  fontSize: _width / (_devWidth / 10)),
                            ),
                            SizedBox(
                                height: _height / (_devHeight / 200),
                                child: _ecgPlot(_predv2Data, _calcMin(_predv2Data),
                                    _calcMax(_predv2Data))),
                            Text(
                              "Lead V3",
                              style: TextStyle(
                                  fontSize: _width / (_devWidth / 10)),
                            ),
                            SizedBox(
                                height: _height / (_devHeight / 200),
                                child: _ecgPlot(_predv3Data, _calcMin(_predv3Data),
                                    _calcMax(_predv3Data))),
                            Text(
                              "Lead V4",
                              style: TextStyle(
                                  fontSize: _width / (_devWidth / 10)),
                            ),
                            SizedBox(
                                height: _height / (_devHeight / 200),
                                child: _ecgPlot(_predv4Data, _calcMin(_predv4Data),
                                    _calcMax(_predv4Data))),
                            Text(
                              "Lead V5",
                              style: TextStyle(
                                  fontSize: _width / (_devWidth / 10)),
                            ),
                            SizedBox(
                                height: _height / (_devHeight / 200),
                                child: _ecgPlot(_predv5Data, _calcMin(_predv5Data),
                                    _calcMax(_predv5Data))),
                            Text(
                              "Lead V6",
                              style: TextStyle(
                                  fontSize: _width / (_devWidth / 10)),
                            ),
                            SizedBox(
                                height: _height / (_devHeight / 200),
                                child: _ecgPlot(_predv6Data, _calcMin(_predv6Data),
                                    _calcMax(_predv6Data))),
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
