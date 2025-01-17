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
  int userInfoFontSize = 17;
  late double _width, _height;
  bool _isLoading = true;
  String _errorMessage = '', _selectedLead = '', _disease = '', _conclusion = '';
  List<String> _doctorLeads = [], _modelLeads = [];
  final double _devWidth = 753.4545454545455, _devHeight = 392.72727272727275;
  Map<String, List<double>> ecgData12Lead = {};
  List<Map<String, dynamic>> filteredShapValues = [];
  final List<String> _ecgLeadKeys = ['l1', 'l2', 'l3', 'avr', 'avl', 'avf', 'v1', 'v2', 'v3', 'v4', 'v5', 'v6'];
  final List<String> _dropDownMenuItems = ['Lead I', 'Lead II', 'Lead III', 'Lead aVR', 'Lead aVL', 'Lead aVF', 'Lead V1', 'Lead V2', 'Lead V3', 'Lead V4', 'Lead V5', 'Lead V6'];
  final String _upBaseLineServerUrl = 'http://swije.pythonanywhere.com/load/model';

  @override
  void initState() {
    super.initState();
    loadECGData();
  }

  Future<void> upBaseLineServerAndLoadTrainData() async {
    await http.get(Uri.parse(_upBaseLineServerUrl), headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    });
  }

  Future<void> loadECGData() async {
    try {
      upBaseLineServerAndLoadTrainData();

      String jsonString = await widget.ecgFile.readAsString();
      ecgData12Lead = (jsonDecode(jsonString) as Map<String, dynamic>).map((key, value) => MapEntry(key, List<double>.from(value)));
      sendECGData(ecgData12Lead);
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e'; _isLoading = false;
      });
      if (kDebugMode) print('Error reading ECG data from file: $e');
    }
  }

  Future<void> sendECGData(Map<String, List<double>> ecgData) async {
    final url = Uri.parse('http://swije.pythonanywhere.com/explain/combined');
    final response = await http.post(url, headers: {"Content-Type": "application/json"}, body: jsonEncode({'ecg': ecgData}));

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      setState(() {
        _selectedLead = responseData['model_leads'].isNotEmpty ? responseData['model_leads'].first : 'No Leads';
        _dropDownMenuItems.clear();
        _dropDownMenuItems.addAll(List<String>.from(responseData['model_leads']));
        _disease = responseData['disease'];
        _conclusion = responseData['conclusion'];
        _doctorLeads = responseData['doctor_leads'] == '' ? [] : List<String>.from(responseData['doctor_leads']);
        _modelLeads = List<String>.from(responseData['model_leads'])
            .map((lead) => lead.replaceAll('Lead ', ''))
            .toList();

        filteredShapValues = List<Map<String, dynamic>>.from(responseData['filtered_values']); _isLoading = false;
      });
    } else {
      setState(() {
        _errorMessage = 'Error: ${response.statusCode} - ${response.reasonPhrase}'; _isLoading = false;
      });
      if (kDebugMode) print('Error: ${response.statusCode} - ${response.reasonPhrase}');
    }
  }

  @override
  Widget build(BuildContext context) {
    _width = MediaQuery.of(context).size.width;
    _height = MediaQuery.of(context).size.height;

    return Scaffold(
        appBar: AppBar(
            title: const Text('Diagnosis focused features', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
            foregroundColor: Colors.white, backgroundColor: Colors.red),
        body: Center(
            child: _isLoading ? Column(
                mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
              Padding(padding: const EdgeInsets.all(20.0), child: Text('Identifying model focused features', style: TextStyle(fontSize: _width / (_devWidth / 20)))),
              const CircularProgressIndicator()
            ]) :
            _errorMessage.isNotEmpty ? Padding(
                padding: const EdgeInsets.all(20.0), child: Text(_errorMessage, style: TextStyle(fontSize: _width / (_devWidth / 20), color: Colors.red)))
                : SingleChildScrollView(
                  child: Padding(
                  padding: EdgeInsets.only(top: _height / (_devHeight / 16), left: _width / (_devWidth / 16), right: _width / (_devWidth / 16), bottom: _height / (_devHeight / 16)),
                  child: Column(children: [
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text("ECG Results", style: TextStyle(fontWeight: FontWeight.bold, fontSize: _width / (_devWidth / 20))),
                      Row(children: [
                        Text("Selected Lead: ", style: TextStyle(fontSize: _width / (_devWidth / 14))),
                        _leadSelectionDropDown()
                      ])
                    ]),
                    SizedBox(
                        height: _height / (_devHeight / 200), child: _selectedLeadPlot()),
                    Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                      RichText(
                        text: TextSpan(
                          text: 'Disease diagnosis: ',
                          style: TextStyle(fontSize: _width / (_devWidth / 15), fontWeight: FontWeight.bold, color: Colors.black),
                          children: [
                            TextSpan(
                              text: _disease,
                              style: const TextStyle(fontWeight: FontWeight.normal),
                            ),
                          ],
                        ),
                      ),
                    ]),
                    _doctorLeads.isNotEmpty ? Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                      RichText(
                        text: TextSpan(
                          text: 'Doctor Leads: ',
                          style: TextStyle(fontSize: _width / (_devWidth / 15), fontWeight: FontWeight.bold, color: Colors.black),
                          children: [
                            TextSpan(
                              text: _doctorLeads.join(', '),
                              style: const TextStyle(fontWeight: FontWeight.normal),
                            ),],),),]) : const SizedBox.shrink(),
                    Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                      RichText(text: TextSpan(text: 'Focused ECG leads: ', style: TextStyle(fontSize: _width / (_devWidth / 15), fontWeight: FontWeight.bold, color: Colors.black),
                          children: [TextSpan(text: _modelLeads.join(', '), style: const TextStyle(fontWeight: FontWeight.normal),)])),
                    ]),
                    Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                      RichText(text: TextSpan(text: 'Conclusion: ', style: TextStyle(fontSize: _width / (_devWidth / 15), fontWeight: FontWeight.bold, color: Colors.black),
                          children: [TextSpan(text: _conclusion, style: const TextStyle(fontWeight: FontWeight.normal),)])),
                    ]),
                  ])
                              ),
                )
        )
    );
  }

  Widget _leadSelectionDropDown() {
    return Container(
        width: _width / (_devWidth / 100), decoration: BoxDecoration(border: Border.all(color: Colors.black)),
        child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
                alignment: AlignmentDirectional.centerEnd, value: _selectedLead,
                items: _dropDownMenuItems.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem(value: value, child: Text(value, style: TextStyle(fontSize: _width / (_devWidth / 14))));
                }).toList(),
                onChanged: (String? value) {
                  setState(() { _selectedLead = value!; });
                })));
  }

  Widget _selectedLeadPlot() {
    String transformedKey = _ecgLeadKeys[_dropDownMenuItems.indexOf(_selectedLead)];
    List<double> leadData = ecgData12Lead[transformedKey] ?? [];
    Map<String, dynamic> shapValues = filteredShapValues.firstWhere((element) => element['lead'] == _dropDownMenuItems.indexOf(_selectedLead) + 1, orElse: () => {});
    return leadData.isNotEmpty ? _ecgPlotWithFocus(leadData, shapValues, leadData.reduce((a, b) => a < b ? a : b), leadData.reduce((a, b) => a > b ? a : b), Colors.blue, Colors.redAccent) : const Center(child: Text('No data available for the selected lead.'));
  }

  Widget _ecgPlotWithFocus(List<double> data, Map<String, dynamic> shapValues, double minValue, double maxValue, Color color, Color focusPointColor) {
    List<int> importantTimePoints = shapValues.isNotEmpty ? List<int>.from(shapValues['important_time_points']) : [];
    double opacity = 1;
    return Padding(
        padding: EdgeInsets.only(top: _height / (_devHeight / 10), left: _width / (_devWidth / 16), right: _width / (_devWidth / 16), bottom: _height / (_devHeight / 16)),
        child: IgnorePointer(
            ignoring: true, child: LineChart(LineChartData(
            lineBarsData: [
              LineChartBarData(
                  spots: List.generate(data.length, (index) => FlSpot(index.toDouble(), data[index])),
                  isCurved: false, colors: [color], barWidth: 2, isStrokeCapRound: true,
                  dotData: FlDotData(show: true, getDotPainter: (spot, _, __, ___) => FlDotCirclePainter(strokeColor: focusPointColor, radius: 0.4, color: focusPointColor,),checkToShowDot: (spot, _) => importantTimePoints.contains(spot.x.toInt()))),
            ],
            minY: minValue, maxY: maxValue,
            titlesData: FlTitlesData(
                bottomTitles: SideTitles(showTitles: true, getTitles: (value) => value % 500 == 0 ? (value ~/ 500).toString() : ""),
                leftTitles: SideTitles(showTitles: true)),
            borderData: FlBorderData(show: true, border: Border.all(color: Colors.black)),
            gridData: FlGridData(show: true, drawHorizontalLine: true, drawVerticalLine: true)))));
  }
}