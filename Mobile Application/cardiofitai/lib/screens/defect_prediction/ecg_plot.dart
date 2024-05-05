

//INTEGRATED FUNCTIONALITY
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';


class ECGDiagnosisScreen extends StatefulWidget {
  @override
  _ECGDiagnosisScreenState createState() => _ECGDiagnosisScreenState();
}

class _ECGDiagnosisScreenState extends State<ECGDiagnosisScreen> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
  }
  File? _selectedFile;
  String _predictedLabel = '';
  List<double> _ecgData = [];

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['txt'],
    );

    if (result != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
        _ecgData.clear(); // Clear previous ECG data when selecting a new file
        _predictedLabel = ''; // Clear predicted label when selecting a new file
      });

      try {
        // Read the file and plot ECG
        List<double> ecgData = await _readFile(_selectedFile!);

        setState(() {
          _ecgData = ecgData;
        });

        // Predict label from web service
        String predictedLabel = await _predictLabel(_selectedFile!);
        setState(() {
          _predictedLabel = predictedLabel;
        });
      } catch (e) {
        print('Error: $e');
        // Handle error
      }
    }
  }

  Future<List<double>> _readFile(File file) async {
    String fileContent = await file.readAsString();
    Map<String, dynamic> jsonData = json.decode(fileContent);

    if (jsonData.containsKey('l2')) {
      return (jsonData['l2'] as List).map<double>((value) {
        return value.toDouble();
      }).toList();
    } else {
      throw FormatException('No ECG data found in the file');
    }
  }

  Future<String> _predictLabel(File file) async {
    final url = Uri.parse('http://hilarinac.pythonanywhere.com/predict');
    var request = http.MultipartRequest('POST', url);
    request.files.add(await http.MultipartFile.fromPath('file', file.path));

    var response = await request.send();
    var responseBody = await response.stream.bytesToString();
    var jsonResponse = json.decode(responseBody);

    return jsonResponse['Predicted class'] ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ECG Diagnosis'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: _pickFile,
              child: Text('Select ECG File'),
            ),
            if (_selectedFile != null)
              Padding(
                padding: EdgeInsets.all(20.0),
                child: Text(
                  'Predicted Label: $_predictedLabel',
                  style: TextStyle(fontSize: 20),
                ),
              ),
            if (_ecgData.isNotEmpty)
              Padding(
                padding: EdgeInsets.all(20.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 200,
                  child: LineChart(
                    LineChartData(
                      lineBarsData: [
                        LineChartBarData(
                          spots: List.generate(
                            _ecgData.length,
                                (index) => FlSpot(index.toDouble(), _ecgData[index]),
                          ),
                          isCurved: false,
                          colors: [Colors.blue],
                          barWidth: 2,
                          isStrokeCapRound: true,
                          dotData: FlDotData(show: false),
                        ),
                      ],
                      minY: _ecgData.reduce((min, current) => min < current ? min : current),
                      maxY: _ecgData.reduce((max, current) => max > current ? max : current),
                      titlesData: FlTitlesData(
                        bottomTitles: SideTitles(showTitles: true),
                        leftTitles: SideTitles(showTitles: true),
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
              ),
          ],
        ),
      ),
    );
  }
}
