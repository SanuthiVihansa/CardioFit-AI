import 'dart:convert';
import 'dart:io';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

import '../../models/user.dart';

class ECGPlotScreen extends StatefulWidget {
  final File ecgFile;
  final User user;

  const ECGPlotScreen({required this.ecgFile, required this.user, super.key});

  @override
  State<ECGPlotScreen> createState() => _ECGPlotScreenState();
}

class _ECGPlotScreenState extends State<ECGPlotScreen> {
  // variables
  late double _width;
  late double _height;
  bool _isLoading = true;
  String _errorMessage = '';
  String _selectedLead = "Lead I"; //this has to change because Lead I may not always be there
  final double _devWidth = 753.4545454545455;
  final double _devHeight = 392.72727272727275;
  Map<String, List<double>> ecgData12Lead = {};
  List<Map<String, dynamic>> filteredShapValues = [];
  final List<String> _ecgLeadKeys = ['l1', 'l2', 'l3', 'avr', 'avl', 'avf', 'v1', 'v2', 'v3', 'v4', 'v5', 'v6'];
  final List<String> _dropDownMenuItems = ['Lead I', 'Lead II', 'Lead III', 'Lead aVR', 'Lead aVL', 'Lead aVF', 'Lead V1', 'Lead V2', 'Lead V3', 'Lead V4', 'Lead V5', 'Lead V6'];

  // methods
  @override
  void initState() {
    super.initState();
    loadECGData();
  }

  Future<void> loadECGData() async {
    try {
      String jsonString = await widget.ecgFile.readAsString();
      ecgData12Lead = (jsonDecode(jsonString) as Map<String, dynamic>).map((key, value) => MapEntry(key, List<double>.from(value)));
      sendECGData(ecgData12Lead);
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
        _isLoading = false;
      });

      if (kDebugMode) {
        print('Error reading ECG data from file: $e');
      }
    }
  }

  Future<void> sendECGData(Map<String, List<double>> ecgData) async { //what does Future mean? what is async?
    final url = Uri.parse('http://swije.pythonanywhere.com/explain/shap');
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({'ecg': ecgData}),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      setState(() {
        filteredShapValues = List<Map<String, dynamic>>.from(responseData['filtered_shap_values']);
        _isLoading = false;
      });
    } else {
      setState(() {
        _errorMessage = 'Error:  ${response.statusCode} - ${response.reasonPhrase}';
        _isLoading = false;
      });
      if (kDebugMode) {
        print('Error:  ${response.statusCode} - ${response.reasonPhrase}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _width = MediaQuery.of(context).size.width;
    _height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text('ECG Plot with Model Focus', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),),
        foregroundColor: Colors.white,
        backgroundColor: Colors.red,
      ),
      body: Center(
        child: _isLoading ?
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                'Identifying model focused features',
                style: TextStyle(fontSize: _width / (_devWidth / 20)),
              ),
            ),
            const CircularProgressIndicator(),
          ],
        ) :
        _errorMessage.isNotEmpty
            ? Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            _errorMessage,
            style: TextStyle(fontSize: _width / (_devWidth / 20), color: Colors.red),
          ),
        )
            :
        Padding(
          padding: EdgeInsets.only(
            top: _height / (_devHeight / 16),
            left: _width / (_devWidth / 16),
            right: _width / (_devWidth / 16),
            bottom: _height / (_devHeight / 16),
          ),
          child: Column(
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
                  Row(
                    children: [
                      Text(
                        "Selected Lead: ",
                        style: TextStyle(fontSize: _width / (_devWidth / 14)),
                      ),
                      _leadSelectionDropDown(),
                    ],
                  ),
                ],
              ),
              Expanded(
                child: SizedBox(
                  height: _height / (_devHeight / 200),
                  child: _selectedLeadPlot(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _leadSelectionDropDown() {
    return Container(
      width: _width / (_devWidth / 100),
      decoration: BoxDecoration(border: Border.all(color: Colors.black)),
      child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            alignment: AlignmentDirectional.centerEnd,
            value: _selectedLead,
            items: _dropDownMenuItems.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem(
                value: value,
                child: Text(
                  value,
                  style: TextStyle(fontSize: _width / (_devWidth / 14)),
                ),
              );
            }).toList(),
            onChanged: (String? value) {
              setState(() {
                _selectedLead = value!;
              });
            },
          )),
    );
  }

  Widget _selectedLeadPlot() {
    String transformedKey = _ecgLeadKeys[_dropDownMenuItems.indexOf(_selectedLead)];
    print("Transformed key for selected lead: $transformedKey");
    print("Keys in ecgData12Lead: ${ecgData12Lead.keys.toList()}");
    print("Lead data found: ${ecgData12Lead.containsKey(transformedKey)}");
    List<double> leadData = ecgData12Lead[transformedKey] ?? [];
    Map<String, dynamic> shapValues = filteredShapValues.firstWhere((element) => element['lead'] == _dropDownMenuItems.indexOf(_selectedLead) + 1, orElse: () => {});
    return leadData.isNotEmpty ? _ecgPlotWithFocus(leadData, shapValues, leadData.reduce((a, b) => a < b ? a : b), leadData.reduce((a, b) => a > b ? a : b), Colors.blue) : const Center(child: Text('No data available for the selected lead.'));
  }

  Widget _ecgPlotWithFocus(List<double> data, Map<String, dynamic> shapValues, double minValue, double maxValue, Color color) {
    List<int> importantTimePoints = shapValues.isNotEmpty ? List<int>.from(shapValues['important_time_points']) : [];

    return Padding(
      padding: EdgeInsets.only(
        top: _height / (_devHeight / 1),
        left: _width / (_devWidth / 16),
        right: _width / (_devWidth / 16),
        bottom: _height / (_devHeight / 16),
      ),
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
                colors: [color],
                barWidth: 2,
                isStrokeCapRound: true,
                dotData: FlDotData(
                  show: true,
                  checkToShowDot: (spot, _) => importantTimePoints.contains(spot.x.toInt()),
                ),
              ),
            ],
            minY: minValue,
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
}

class ECGLeadChart extends StatelessWidget {
  final List<double> ecgData;
  final Map<String, dynamic> shapValues;

  const ECGLeadChart({required this.ecgData, required this.shapValues, super.key});

  @override
  Widget build(BuildContext context) {
    List<int> importantTimePoints = shapValues.isNotEmpty ? List<int>.from(shapValues['important_time_points']) : []; //what does List<int>.from() mean? does it return a list?

    return LineChart(
      LineChartData(
        gridData: FlGridData(show: false), //what does FlGridData(show: false) mean?
        titlesData: FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: ecgData.asMap().entries.map((entry) {
              int index = entry.key;
              double value = entry.value;
              return FlSpot(index.toDouble(), value);
            }).toList(),
            isCurved: false,
            colors: [Colors.blue],
            dotData: FlDotData(
              show: true,
              checkToShowDot: (spot, _) => importantTimePoints.contains(spot.x.toInt()),
            ),
          ),
        ],
      ),
    );
  }
}