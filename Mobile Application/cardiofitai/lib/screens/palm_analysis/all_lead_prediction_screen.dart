import 'dart:convert';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AllLeadPredictionScreen extends StatefulWidget {
  const AllLeadPredictionScreen(this.l2Data, {super.key});

  final List<double> l2Data;

  @override
  State<AllLeadPredictionScreen> createState() =>
      _AllLeadPredictionScreenState();
}

class _AllLeadPredictionScreenState extends State<AllLeadPredictionScreen> {
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
      padding: const EdgeInsets.all(16.0),
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
    Map<String, dynamic> data = {
      'l2': widget.l2Data,
    };
    String jsonString = jsonEncode(data);
    var response = await http.post(Uri.parse(_predictionApiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonString);

    _resCode = response.statusCode;

    if (_resCode == 200) {
      print('Data sent successfully!');
      print(response.body);
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

      print(decodedData["l2"].runtimeType);
    } else {
      print('Failed to send data. Status code: ${_resCode}');
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Results"),
          backgroundColor: Colors.red,
        ),
        body: _resCode == 200
            ? SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    SizedBox(
                        height: 200,
                        child: _ecgPlot(
                            _l1Data, _calcMin(_l1Data), _calcMax(_l1Data))),
                    SizedBox(
                        height: 200,
                        child: _ecgPlot(
                            _l2Data, _calcMin(_l2Data), _calcMax(_l2Data))),
                    SizedBox(
                        height: 200,
                        child: _ecgPlot(
                            _l3Data, _calcMin(_l3Data), _calcMax(_l3Data))),
                    SizedBox(
                        height: 200,
                        child: _ecgPlot(
                            _avrData, _calcMin(_avrData), _calcMax(_avrData))),
                    SizedBox(
                        height: 200,
                        child: _ecgPlot(
                            _avlData, _calcMin(_avlData), _calcMax(_avlData))),
                    SizedBox(
                        height: 200,
                        child: _ecgPlot(
                            _avfData, _calcMin(_avfData), _calcMax(_avfData))),
                    SizedBox(
                        height: 200,
                        child: _ecgPlot(
                            _v1Data, _calcMin(_v1Data), _calcMax(_v1Data))),
                    SizedBox(
                        height: 200,
                        child: _ecgPlot(
                            _v2Data, _calcMin(_v2Data), _calcMax(_v2Data))),
                    SizedBox(
                        height: 200,
                        child: _ecgPlot(
                            _v3Data, _calcMin(_v3Data), _calcMax(_v3Data))),
                    SizedBox(
                        height: 200,
                        child: _ecgPlot(
                            _v4Data, _calcMin(_v4Data), _calcMax(_v4Data))),
                    SizedBox(
                        height: 200,
                        child: _ecgPlot(
                            _v5Data, _calcMin(_v5Data), _calcMax(_v5Data))),
                    SizedBox(
                        height: 200,
                        child: _ecgPlot(
                            _v6Data, _calcMin(_v6Data), _calcMax(_v6Data))),
                    ElevatedButton(onPressed: () {}, child: const Text("Back"))
                  ],
                ),
              )
            : _resCode == 0
                ? Center(child: CircularProgressIndicator())
                : Center(
                    child: Text("Error"),
                  ));
  }
}
