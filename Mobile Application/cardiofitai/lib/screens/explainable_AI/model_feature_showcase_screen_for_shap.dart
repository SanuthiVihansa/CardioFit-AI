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

  const ECGPlotScreen({required this.ecgFile, required this.user,/* required this.ecgData12Lead,*/ super.key});

  @override
  State<ECGPlotScreen> createState() => _ECGPlotScreenState();
}

class _ECGPlotScreenState extends State<ECGPlotScreen> {
  // variables
  late double _width;
  late double _height;
  bool _isLoading = true;
  String _errorMessage = '';
  final double _devWidth = 753.4545454545455;
  final double _devHeight = 392.72727272727275;
  List<Map<String, dynamic>> filteredShapValues = [];

  Map<String, List<double>> ecgData12Lead = {};

  // methods
  void initState(){
    super.initState();
    loadECGData();
  }

  Future<Map<String, List<double>>> _readFile(File file) async {
    Map<String, List<double>> leadsData = {};

    try{
      String fileContent = await file.readAsString();
      Map<String, dynamic> jsonData = jsonDecode(fileContent);

      List<String> leadNames = [
        'l1', 'l2', 'l3', 'avr', 'avl', 'avf', 'v1', 'v2', 'v3', 'v4', 'v5', 'v6'
      ];

      for (String lead in leadNames){
        if(jsonData.containsKey(lead)){
          leadsData[lead] = (jsonData[lead] as List<dynamic>)
              .map<double>((value) => value.toDouble())
              .toList();
        } else {
          throw FormatException('Lead $lead not found in the file');
        }
      }

      return leadsData;
    } catch(e){
      throw FormatException('Failed to read the file: $e');
    }
  }

  Future<void> _processFile() async {
    try{
      // var ecgData = await _readFile(_selectedFile!);
    } catch(e){

    }
  }

  Future<void> loadECGData() async{
    try {
      String jsonString = await widget.ecgFile.readAsString();
      ecgData12Lead = (jsonDecode(jsonString) as Map<String, dynamic>).map((key, value) => MapEntry(key, List<double>.from(value)));
      sendECGData(ecgData12Lead);
    } catch (e){
      setState(() {
        _errorMessage = 'Error: $e';
        _isLoading = false;
      });

      if (kDebugMode) {
        print('Error reading ECG data from file: $e');
      }
    }
  }

  Future<void> sendECGData(Map<String, List<double>> ecgData) async{ //what does Future mean? what is async?
    final url = Uri.parse('http://swije.pythonanywhere.com/explain/shap');
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({'ecg': ecgData}),
    );

    if (response.statusCode == 200){
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
          padding: EdgeInsets.only(top: _height / (_devHeight / 8), left: _width / (_devWidth / 8), right: _width / (_devWidth / 8), bottom: _height / (_devHeight / 8),),
          child: ListView.builder(itemCount: ecgData12Lead.length, itemBuilder: (context, index){
            String leadName = ecgData12Lead.keys.elementAt(index);
            return Column(
              children: [
                Text(leadName, style: TextStyle(fontSize: _width / (_devWidth / 18), fontWeight: FontWeight.bold)),
                SizedBox(height: _height / (_devHeight / 200), child: ECGLeadChart(ecgData: ecgData12Lead[leadName]!, shapValues: filteredShapValues.firstWhere((element) => element['lead'] == index + 1, orElse: () => {}))),
                SizedBox(height: _height / (_devHeight / 20)),
              ],
            );
          }),
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