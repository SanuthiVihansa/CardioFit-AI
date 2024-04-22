import 'dart:convert';
import 'dart:io';
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
  late List<double> _tenSecData = [];
  double _maxValue = 0;
  double _minValue = 0;
  final String _predictionApiUrl =
      'http://poornasenadheera100.pythonanywhere.com/predict';
  final String _upServerUrl =
      'http://poornasenadheera100.pythonanywhere.com/upforunet';

  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);

    _upServer();
  }

  void _pickFile() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: false);

    if (result == null) return;

    final file = File(result.files.single.path.toString());
    String contents = await file.readAsString();
    contents = contents.substring(1);
    // print(contents);

    List<double> dataList = contents.split(',').map((String value) {
      return double.tryParse(value) ?? 0.0;
    }).toList();

    _tenSecData = dataList.sublist(0, 2560);
    _calcMinMax(_tenSecData);
    setState(() {});

    // print(_tenSecData);

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
      padding: const EdgeInsets.all(16.0),
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

  Future<void> _onClickBtnProceed() async {
    // print(_tenSecData);
    Map<String, dynamic> data = {
      'l2': _tenSecData,
    };
    String jsonString = jsonEncode(data);
    print(jsonString);
    var response = await http.post(Uri.parse(_predictionApiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonString);

    if (response.statusCode == 200) {
      print('Data sent successfully!');
      print(response.body);
      var decodedData = jsonDecode(response.body);
      print(decodedData["l2"].runtimeType);
    } else {
      print('Failed to send data. Status code: ${response.statusCode}');
    }
  }

  Future<void> _upServer() async {
    await http.get(Uri.parse(_upServerUrl), headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("File Selector"),
        backgroundColor: Colors.red,
      ),
      body: _tenSecData.length == 0
          ? Center(
              child: ElevatedButton(
                child: const Text("Select file"),
                onPressed: () {
                  _pickFile();
                },
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(child: SizedBox(child: _ecgPlot())),
                ElevatedButton(
                    onPressed: () {
                      _onClickBtnProceed();
                    },
                    child: const Text("Proceed"))
              ],
            ),
    );
  }
}
