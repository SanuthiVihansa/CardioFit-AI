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
  List<double> _lavrData = [];
  List<double> _lavlData = [];
  List<double> _lavfData = [];
  List<double> _lv1Data = [];
  List<double> _lv2Data = [];
  List<double> _lv3Data = [];
  List<double> _lv4Data = [];
  List<double> _lv5Data = [];
  List<double> _lv6Data = [];

  double _l1MinValue = 0;
  double _l2MinValue = 0;
  double _l3MinValue = 0;
  double _lavrMinValue = 0;
  double _lavlMinValue = 0;
  double _lavfMinValue = 0;
  double _lv1MinValue = 0;
  double _lv2MinValue = 0;
  double _lv3MinValue = 0;
  double _lv4MinValue = 0;
  double _lv5MinValue = 0;
  double _lv6MinValue = 0;

  double _l1MaxValue = 0;
  double _l2MaxValue = 0;
  double _l3MaxValue = 0;
  double _lavrMaxValue = 0;
  double _lavlMaxValue = 0;
  double _lavfMaxValue = 0;
  double _lv1MaxValue = 0;
  double _lv2MaxValue = 0;
  double _lv3MaxValue = 0;
  double _lv4MaxValue = 0;
  double _lv5MaxValue = 0;
  double _lv6MaxValue = 0;

  @override
  void initState() {
    super.initState();
  }

  double _calcMin(List<double> data) {
    double minValue =
        data.reduce((value, element) => value < element ? value : element) -
            0.5;
    return minValue;
  }

  double _calcMax(List<double> data) {
    double maxValue =
        data.reduce((value, element) => value > element ? value : element) +
            0.5;
    return maxValue;
  }

  Widget _ecgPlot(List<double> data, double minValue, double maxValue) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
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
                return (value ~/ 256).toString();
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

    if (response.statusCode == 200) {
      print('Data sent successfully!');
      print(response.body);
      var decodedData = jsonDecode(response.body);
      _l2Data = decodedData["l2"];
      print(decodedData["l2"].runtimeType);
    } else {
      print('Failed to send data. Status code: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Results"),
        backgroundColor: Colors.red,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
              child: SizedBox(
                  child: _ecgPlot(widget.l2Data, _calcMin(widget.l2Data),
                      _calcMax(widget.l2Data)))),
          ElevatedButton(onPressed: () {}, child: const Text("Back"))
        ],
      ),
    );
  }
}
