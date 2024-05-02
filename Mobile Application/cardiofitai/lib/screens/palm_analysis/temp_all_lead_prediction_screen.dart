import 'dart:convert';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
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

  List<double> actl1Data = [];
  List<double> predl1Data = [];
  List<double> actl2Data = [];
  List<double> actl3Data = [];
  List<double> predl3Data = [];
  List<double> actavrData = [];
  List<double> predavrData = [];
  List<double> actavlData = [];
  List<double> predavlData = [];
  List<double> actavfData = [];
  List<double> predavfData = [];
  List<double> actv1Data = [];
  List<double> predv1Data = [];
  List<double> actv2Data = [];
  List<double> predv2Data = [];
  List<double> actv3Data = [];
  List<double> predv3Data = [];
  List<double> actv4Data = [];
  List<double> predv4Data = [];
  List<double> actv5Data = [];
  List<double> predv5Data = [];
  List<double> actv6Data = [];
  List<double> predv6Data = [];

  double l1mse = 0;
  double l1p = 0;
  double l1r2 = 0;
  double l3mse = 0;
  double l3p = 0;
  double l3r2 = 0;
  double avrmse = 0;
  double avrp = 0;
  double avrr2 = 0;
  double avlmse = 0;
  double avlp = 0;
  double avlr2 = 0;
  double avfmse = 0;
  double avfp = 0;
  double avfr2 = 0;
  double v1mse = 0;
  double v1p = 0;
  double v1r2 = 0;
  double v2mse = 0;
  double v2p = 0;
  double v2r2 = 0;
  double v3mse = 0;
  double v3p = 0;
  double v3r2 = 0;
  double v4mse = 0;
  double v4p = 0;
  double v4r2 = 0;
  double v5mse = 0;
  double v5p = 0;
  double v5r2 = 0;
  double v6mse = 0;
  double v6p = 0;
  double v6r2 = 0;

  int _resCode = 0;

  bool _isComparisonOn = false;

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
        'l1': widget.l1Data,
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
        actl1Data = List<double>.from(
            decodedData["actl1"].map((element) => element.toDouble()));
        predl1Data = List<double>.from(
            decodedData["predl1"].map((element) => element.toDouble()));
        l1mse = decodedData["l1mse"];
        l1p = decodedData["l1p"];
        l1r2 = decodedData["l1r2"];

        actl2Data = List<double>.from(
            decodedData["actl2"].map((element) => element.toDouble()));

        actl3Data = List<double>.from(
            decodedData["actl3"].map((element) => element.toDouble()));
        predl3Data = List<double>.from(
            decodedData["predl3"].map((element) => element.toDouble()));
        l3mse = decodedData["l3mse"];
        l3p = decodedData["l3p"];
        l3r2 = decodedData["l3r2"];

        actavrData = List<double>.from(
            decodedData["actavr"].map((element) => element.toDouble()));
        predavrData = List<double>.from(
            decodedData["predavr"].map((element) => element.toDouble()));
        avrmse = decodedData["avrmse"];
        avrp = decodedData["avrp"];
        avrr2 = decodedData["avrr2"];

        actavlData = List<double>.from(
            decodedData["actavl"].map((element) => element.toDouble()));
        predavlData = List<double>.from(
            decodedData["predavl"].map((element) => element.toDouble()));
        avlmse = decodedData["avlmse"];
        avlp = decodedData["avlp"];
        avlr2 = decodedData["avlr2"];

        actavfData = List<double>.from(
            decodedData["actavf"].map((element) => element.toDouble()));
        predavfData = List<double>.from(
            decodedData["predavf"].map((element) => element.toDouble()));
        avfmse = decodedData["avfmse"];
        avfp = decodedData["avfp"];
        avfr2 = decodedData["avfr2"];

        actv1Data = List<double>.from(
            decodedData["actv1"].map((element) => element.toDouble()));
        predv1Data = List<double>.from(
            decodedData["predv1"].map((element) => element.toDouble()));
        v1mse = decodedData["v1mse"];
        v1p = decodedData["v1p"];
        v1r2 = decodedData["v1r2"];

        actv2Data = List<double>.from(
            decodedData["actv2"].map((element) => element.toDouble()));
        predv2Data = List<double>.from(
            decodedData["predv2"].map((element) => element.toDouble()));
        v2mse = decodedData["v2mse"];
        v2p = decodedData["v2p"];
        v2r2 = decodedData["v2r2"];

        actv3Data = List<double>.from(
            decodedData["actv3"].map((element) => element.toDouble()));
        predv3Data = List<double>.from(
            decodedData["predv3"].map((element) => element.toDouble()));
        v3mse = decodedData["v3mse"];
        v3p = decodedData["v3p"];
        v3r2 = decodedData["v3r2"];

        actv4Data = List<double>.from(
            decodedData["actv4"].map((element) => element.toDouble()));
        predv4Data = List<double>.from(
            decodedData["predv4"].map((element) => element.toDouble()));
        v4mse = decodedData["v4mse"];
        v4p = decodedData["v4p"];
        v4r2 = decodedData["v4r2"];

        actv5Data = List<double>.from(
            decodedData["actv5"].map((element) => element.toDouble()));
        predv5Data = List<double>.from(
            decodedData["predv5"].map((element) => element.toDouble()));
        v5mse = decodedData["v5mse"];
        v5p = decodedData["v5p"];
        v5r2 = decodedData["v5r2"];

        actv6Data = List<double>.from(
            decodedData["actv6"].map((element) => element.toDouble()));
        predv6Data = List<double>.from(
            decodedData["predv6"].map((element) => element.toDouble()));
        v6mse = decodedData["v6mse"];
        v6p = decodedData["v6p"];
        v6r2 = decodedData["v6r2"];
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

  Widget _plotsWithoutComparison() {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(
              top: _height / (_devHeight / 10),
              left: _width / (_devWidth / 20),
              right: _width / (_devWidth / 20)),
          child: Row(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "ECG Results",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: _width / (_devWidth / 20)),
                  ),
                ],
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Checkbox(
                        value: _isComparisonOn,
                        onChanged: (value) {
                          setState(() {
                            _isComparisonOn = value!;
                          });
                        }),
                    Padding(
                      padding:
                          EdgeInsets.only(right: _width / (_devWidth / 15)),
                      child: Text(
                        "Compare with Actual",
                        style: TextStyle(fontSize: _width / (_width / 14)),
                      ),
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
                                  (_devHeight / 40)), // Button width and height
                        ),
                      ),
                      child: Text(
                        "Home",
                        style: TextStyle(fontSize: _width / (_devWidth / 10)),
                      ),
                    )
                  ],
                ),
              ),
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
                    style: TextStyle(fontSize: _width / (_devWidth / 10)),
                  ),
                  SizedBox(
                      height: _height / (_devHeight / 200),
                      child: _ecgPlot(predl1Data, _calcMin(predl1Data),
                          _calcMax(predl1Data))),
                  Text(
                    "Lead II",
                    style: TextStyle(fontSize: _width / (_devWidth / 10)),
                  ),
                  SizedBox(
                      height: _height / (_devHeight / 200),
                      child: _ecgPlot(
                          actl2Data, _calcMin(actl2Data), _calcMax(actl2Data))),
                  Text(
                    "Lead III",
                    style: TextStyle(fontSize: _width / (_devWidth / 10)),
                  ),
                  SizedBox(
                      height: _height / (_devHeight / 200),
                      child: _ecgPlot(predl3Data, _calcMin(predl3Data),
                          _calcMax(predl3Data))),
                  Text(
                    "Lead aVR",
                    style: TextStyle(fontSize: _width / (_devWidth / 10)),
                  ),
                  SizedBox(
                      height: _height / (_devHeight / 200),
                      child: _ecgPlot(predavrData, _calcMin(predavrData),
                          _calcMax(predavrData))),
                  Text(
                    "Lead aVL",
                    style: TextStyle(fontSize: _width / (_devWidth / 10)),
                  ),
                  SizedBox(
                      height: _height / (_devHeight / 200),
                      child: _ecgPlot(predavlData, _calcMin(predavlData),
                          _calcMax(predavlData))),
                  Text(
                    "Lead aVF",
                    style: TextStyle(fontSize: _width / (_devWidth / 10)),
                  ),
                  SizedBox(
                      height: _height / (_devHeight / 200),
                      child: _ecgPlot(predavfData, _calcMin(predavfData),
                          _calcMax(predavfData))),
                  Text(
                    "Lead V1",
                    style: TextStyle(fontSize: _width / (_devWidth / 10)),
                  ),
                  SizedBox(
                      height: _height / (_devHeight / 200),
                      child: _ecgPlot(predv1Data, _calcMin(predv1Data),
                          _calcMax(predv1Data))),
                  Text(
                    "Lead V2",
                    style: TextStyle(fontSize: _width / (_devWidth / 10)),
                  ),
                  SizedBox(
                      height: _height / (_devHeight / 200),
                      child: _ecgPlot(predv2Data, _calcMin(predv2Data),
                          _calcMax(predv2Data))),
                  Text(
                    "Lead V3",
                    style: TextStyle(fontSize: _width / (_devWidth / 10)),
                  ),
                  SizedBox(
                      height: _height / (_devHeight / 200),
                      child: _ecgPlot(predv3Data, _calcMin(predv3Data),
                          _calcMax(predv3Data))),
                  Text(
                    "Lead V4",
                    style: TextStyle(fontSize: _width / (_devWidth / 10)),
                  ),
                  SizedBox(
                      height: _height / (_devHeight / 200),
                      child: _ecgPlot(predv4Data, _calcMin(predv4Data),
                          _calcMax(predv4Data))),
                  Text(
                    "Lead V5",
                    style: TextStyle(fontSize: _width / (_devWidth / 10)),
                  ),
                  SizedBox(
                      height: _height / (_devHeight / 200),
                      child: _ecgPlot(predv5Data, _calcMin(predv5Data),
                          _calcMax(predv5Data))),
                  Text(
                    "Lead V6",
                    style: TextStyle(fontSize: _width / (_devWidth / 10)),
                  ),
                  SizedBox(
                      height: _height / (_devHeight / 200),
                      child: _ecgPlot(predv6Data, _calcMin(predv6Data),
                          _calcMax(predv6Data))),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _plotsWithComparison() {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(
              top: _height / (_devHeight / 10),
              left: _width / (_devWidth / 20),
              right: _width / (_devWidth / 20)),
          child: Row(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "ECG Results",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: _width / (_devWidth / 20)),
                  ),
                ],
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Checkbox(
                        value: _isComparisonOn,
                        onChanged: (value) {
                          setState(() {
                            _isComparisonOn = value!;
                          });
                        }),
                    Padding(
                      padding:
                          EdgeInsets.only(right: _width / (_devWidth / 15)),
                      child: Text(
                        "Compare with Actual",
                        style: TextStyle(fontSize: _width / (_width / 14)),
                      ),
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
                                  (_devHeight / 40)), // Button width and height
                        ),
                      ),
                      child: Text(
                        "Home",
                        style: TextStyle(fontSize: _width / (_devWidth / 10)),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: SizedBox(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      left: _width / (_devWidth / 20),
                    ),
                    child: Row(
                      children: [
                        Text(
                          "Similarity : ${(l1p * 100).toStringAsFixed(2)} %",
                          style: TextStyle(fontSize: _width / (_devWidth / 13)),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    "Actual Lead I",
                    style: TextStyle(fontSize: _width / (_devWidth / 10)),
                  ),
                  SizedBox(
                      height: _height / (_devHeight / 200),
                      child: _ecgPlot(
                          actl1Data, _calcMin(actl1Data), _calcMax(actl1Data))),
                  Text(
                    "Predicted Lead I",
                    style: TextStyle(fontSize: _width / (_devWidth / 10)),
                  ),
                  SizedBox(
                      height: _height / (_devHeight / 200),
                      child: _ecgPlot(predl1Data, _calcMin(predl1Data),
                          _calcMax(predl1Data))),
                  const Divider(
                    height: 1,
                    thickness: 13,
                    color: Colors.black,

                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      left: _width / (_devWidth / 20),
                    ),
                    child: Row(
                      children: [
                        Text(
                          "Similarity : ${(l3p * 100).toStringAsFixed(2)} %",
                          style: TextStyle(fontSize: _width / (_devWidth / 13)),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    "Actual Lead II",
                    style: TextStyle(fontSize: _width / (_devWidth / 10)),
                  ),
                  SizedBox(
                      height: _height / (_devHeight / 200),
                      child: _ecgPlot(
                          actl2Data, _calcMin(actl2Data), _calcMax(actl2Data))),
                  Text(
                    "Actual Lead III",
                    style: TextStyle(fontSize: _width / (_devWidth / 10)),
                  ),
                  SizedBox(
                      height: _height / (_devHeight / 200),
                      child: _ecgPlot(
                          actl3Data, _calcMin(actl3Data), _calcMax(actl3Data))),
                  Text(
                    "Predicted Lead III",
                    style: TextStyle(fontSize: _width / (_devWidth / 10)),
                  ),
                  SizedBox(
                      height: _height / (_devHeight / 200),
                      child: _ecgPlot(predl3Data, _calcMin(predl3Data),
                          _calcMax(predl3Data))),
                  Text(
                    "Actual Lead aVR",
                    style: TextStyle(fontSize: _width / (_devWidth / 10)),
                  ),
                  SizedBox(
                      height: _height / (_devHeight / 200),
                      child: _ecgPlot(actavrData, _calcMin(actavrData),
                          _calcMax(actavrData))),
                  Text(
                    "Predicted Lead aVR",
                    style: TextStyle(fontSize: _width / (_devWidth / 10)),
                  ),
                  SizedBox(
                      height: _height / (_devHeight / 200),
                      child: _ecgPlot(predavrData, _calcMin(predavrData),
                          _calcMax(predavrData))),
                  Text(
                    "Actual Lead aVL",
                    style: TextStyle(fontSize: _width / (_devWidth / 10)),
                  ),
                  SizedBox(
                      height: _height / (_devHeight / 200),
                      child: _ecgPlot(actavlData, _calcMin(actavlData),
                          _calcMax(actavlData))),
                  Text(
                    "Predicted Lead aVL",
                    style: TextStyle(fontSize: _width / (_devWidth / 10)),
                  ),
                  SizedBox(
                      height: _height / (_devHeight / 200),
                      child: _ecgPlot(predavlData, _calcMin(predavlData),
                          _calcMax(predavlData))),
                  Text(
                    "Actual Lead aVF",
                    style: TextStyle(fontSize: _width / (_devWidth / 10)),
                  ),
                  SizedBox(
                      height: _height / (_devHeight / 200),
                      child: _ecgPlot(actavfData, _calcMin(actavfData),
                          _calcMax(actavfData))),
                  Text(
                    "Predicted Lead aVF",
                    style: TextStyle(fontSize: _width / (_devWidth / 10)),
                  ),
                  SizedBox(
                      height: _height / (_devHeight / 200),
                      child: _ecgPlot(predavfData, _calcMin(predavfData),
                          _calcMax(predavfData))),
                  Text(
                    "Actual Lead V1",
                    style: TextStyle(fontSize: _width / (_devWidth / 10)),
                  ),
                  SizedBox(
                      height: _height / (_devHeight / 200),
                      child: _ecgPlot(
                          actv1Data, _calcMin(actv1Data), _calcMax(actv1Data))),
                  Text(
                    "Predicted Lead V1",
                    style: TextStyle(fontSize: _width / (_devWidth / 10)),
                  ),
                  SizedBox(
                      height: _height / (_devHeight / 200),
                      child: _ecgPlot(predv1Data, _calcMin(predv1Data),
                          _calcMax(predv1Data))),
                  Text(
                    "Actual Lead V2",
                    style: TextStyle(fontSize: _width / (_devWidth / 10)),
                  ),
                  SizedBox(
                      height: _height / (_devHeight / 200),
                      child: _ecgPlot(
                          actv2Data, _calcMin(actv2Data), _calcMax(actv2Data))),
                  Text(
                    "Predicted Lead V2",
                    style: TextStyle(fontSize: _width / (_devWidth / 10)),
                  ),
                  SizedBox(
                      height: _height / (_devHeight / 200),
                      child: _ecgPlot(predv2Data, _calcMin(predv2Data),
                          _calcMax(predv2Data))),
                  Text(
                    "Actual Lead V3",
                    style: TextStyle(fontSize: _width / (_devWidth / 10)),
                  ),
                  SizedBox(
                      height: _height / (_devHeight / 200),
                      child: _ecgPlot(
                          actv3Data, _calcMin(actv3Data), _calcMax(actv3Data))),
                  Text(
                    "Predicted Lead V3",
                    style: TextStyle(fontSize: _width / (_devWidth / 10)),
                  ),
                  SizedBox(
                      height: _height / (_devHeight / 200),
                      child: _ecgPlot(predv3Data, _calcMin(predv3Data),
                          _calcMax(predv3Data))),
                  Text(
                    "Actual Lead V4",
                    style: TextStyle(fontSize: _width / (_devWidth / 10)),
                  ),
                  SizedBox(
                      height: _height / (_devHeight / 200),
                      child: _ecgPlot(
                          actv4Data, _calcMin(actv4Data), _calcMax(actv4Data))),
                  Text(
                    "Predicted Lead V4",
                    style: TextStyle(fontSize: _width / (_devWidth / 10)),
                  ),
                  SizedBox(
                      height: _height / (_devHeight / 200),
                      child: _ecgPlot(predv4Data, _calcMin(predv4Data),
                          _calcMax(predv4Data))),
                  Text(
                    "Actual Lead V5",
                    style: TextStyle(fontSize: _width / (_devWidth / 10)),
                  ),
                  SizedBox(
                      height: _height / (_devHeight / 200),
                      child: _ecgPlot(
                          actv5Data, _calcMin(actv5Data), _calcMax(actv5Data))),
                  Text(
                    "Predicted Lead V5",
                    style: TextStyle(fontSize: _width / (_devWidth / 10)),
                  ),
                  SizedBox(
                      height: _height / (_devHeight / 200),
                      child: _ecgPlot(predv5Data, _calcMin(predv5Data),
                          _calcMax(predv5Data))),
                  Text(
                    "Actual Lead V6",
                    style: TextStyle(fontSize: _width / (_devWidth / 10)),
                  ),
                  SizedBox(
                      height: _height / (_devHeight / 200),
                      child: _ecgPlot(
                          actv6Data, _calcMin(actv6Data), _calcMax(actv6Data))),
                  Text(
                    "Predicted Lead V6",
                    style: TextStyle(fontSize: _width / (_devWidth / 10)),
                  ),
                  SizedBox(
                      height: _height / (_devHeight / 200),
                      child: _ecgPlot(predv6Data, _calcMin(predv6Data),
                          _calcMax(predv6Data))),
                ],
              ),
            ),
          ),
        ),
      ],
    );
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
            ? _isComparisonOn
                ? _plotsWithComparison()
                : _plotsWithoutComparison()
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
