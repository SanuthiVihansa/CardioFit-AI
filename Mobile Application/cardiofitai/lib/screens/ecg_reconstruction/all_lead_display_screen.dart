import 'dart:convert';
import 'dart:io';

import 'package:cardiofitai/models/user.dart';
import 'package:cardiofitai/services/ecg_service.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../../models/response.dart';
import '../defect_prediction/ecg_plot.dart';

class AllLeadDisplayScreen extends StatefulWidget {
  const AllLeadDisplayScreen(this.l1Data, this._user, {super.key});

  final List<double> l1Data;
  final User _user;

  @override
  State<AllLeadDisplayScreen> createState() => _AllLeadDisplayScreenState();
}

class _AllLeadDisplayScreenState extends State<AllLeadDisplayScreen> {
  late double _width;
  late double _height;
  final double _devWidth = 753.4545454545455;
  final double _devHeight = 392.72727272727275;
  String _loadingSpinnerText = "Loading...";

  final String _predictionApiUrl =
      'http://poornasenadheera100.pythonanywhere.com/predict';

  List<double> actl1Data = [];
  List<double> predl2Data = [];
  List<double> predl3Data = [];

  List<double> predavrData = [];

  List<double> predavlData = [];

  List<double> predavfData = [];

  List<double> predv1Data = [];

  List<double> predv2Data = [];

  List<double> predv3Data = [];

  List<double> predv4Data = [];

  List<double> predv5Data = [];

  List<double> predv6Data = [];

  int _resCode = 0;
  final List<String> _dropDownMenuItems = [
    "Lead I",
    "Lead II",
    "Lead III",
    "Lead aVR",
    "Lead aVL",
    "Lead aVF",
    "Lead V1",
    "Lead V2",
    "Lead V3",
    "Lead V4",
    "Lead V5",
    "Lead V6"
  ];
  late String _selectedLead;

  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    _selectedLead = _dropDownMenuItems.first;
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

  Widget _ecgPlot(
      List<double> data, double minValue, double maxValue, Color color) {
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
                colors: [color],
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
      Map<String, dynamic> data = {'l1': widget.l1Data};
      String jsonString = jsonEncode(data);
      var response = await http
          .post(Uri.parse(_predictionApiUrl),
              headers: <String, String>{
                'Content-Type': 'application/json; charset=UTF-8',
              },
              body: jsonString)
          .timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);
        actl1Data = List<double>.from(
            decodedData["l1"].map((element) => element.toDouble()));
        predl2Data = List<double>.from(
            decodedData["l2"].map((element) => element.toDouble()));
        predl3Data = List<double>.from(
            decodedData["l3"].map((element) => element.toDouble()));
        predavrData = List<double>.from(
            decodedData["avr"].map((element) => element.toDouble()));
        predavlData = List<double>.from(
            decodedData["avl"].map((element) => element.toDouble()));
        predavfData = List<double>.from(
            decodedData["avf"].map((element) => element.toDouble()));
        predv1Data = List<double>.from(
            decodedData["v1"].map((element) => element.toDouble()));
        predv2Data = List<double>.from(
            decodedData["v2"].map((element) => element.toDouble()));
        predv3Data = List<double>.from(
            decodedData["v3"].map((element) => element.toDouble()));
        predv4Data = List<double>.from(
            decodedData["v4"].map((element) => element.toDouble()));
        predv5Data = List<double>.from(
            decodedData["v5"].map((element) => element.toDouble()));
        predv6Data = List<double>.from(
            decodedData["v6"].map((element) => element.toDouble()));

        await _saveToDB();

        _resCode = response.statusCode;
      } else {
        // print('Failed to send data. Status code: ${_resCode}');
      }
    } catch (e) {
      _resCode = 408;
      _showTimeoutErrorMsg();
    }

    setState(() {});
  }

  Future<void> _saveToDB() async {
    setState(() {
      _loadingSpinnerText = "Please wait...";
    });
    Response response = await EcgService.addECG(
        widget._user.email,
        actl1Data,
        predl2Data,
        predl3Data,
        predavrData,
        predavlData,
        predavfData,
        predv1Data,
        predv2Data,
        predv3Data,
        predv4Data,
        predv5Data,
        predv6Data);
    if (response.code == 200) {
      Fluttertoast.showToast(
          msg: "ECG Data Reconstructed Successfully!🎉",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0);
    } else {
      Fluttertoast.showToast(
          msg: "Sorry! We have trouble in saving your ECG data. ☹️",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
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
                    Text(
                      "Selected Lead: ",
                      style: TextStyle(fontSize: _width / (_devWidth / 14)),
                    ),
                    _leadSelectionDropDown(),
                    Padding(
                      padding: EdgeInsets.only(left: _width / (_devWidth / 20)),
                      child: ElevatedButton(
                        onPressed: () {
                          _onTapDiagnoseBtn();
                        },
                        style: ButtonStyle(
                          fixedSize: WidgetStateProperty.all<Size>(
                            Size(
                                _width / (_devWidth / 120.0),
                                _height /
                                    (_devHeight /
                                        40)), // Button width and height
                          ),
                        ),
                        child: Text(
                          "Diagnose",
                          style: TextStyle(fontSize: _width / (_devWidth / 10)),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: _width / (_devWidth / 20)),
                      child: ElevatedButton(
                        onPressed: () {
                          _onClickHomeBtn();
                        },
                        style: ButtonStyle(
                          fixedSize: WidgetStateProperty.all<Size>(
                            Size(
                                _width / (_devWidth / 120.0),
                                _height /
                                    (_devHeight /
                                        40)), // Button width and height
                          ),
                        ),
                        child: Text(
                          "Home",
                          style: TextStyle(fontSize: _width / (_devWidth / 10)),
                        ),
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
              child: _selectedLead == "Lead I"
                  ? _lead1PlotWithoutComparison()
                  : _selectedLead == "Lead II"
                      ? _lead2PlotWithoutComparison()
                      : _selectedLead == "Lead III"
                          ? _lead3PlotWithoutComparison()
                          : _selectedLead == "Lead aVR"
                              ? _leadAvrPlotWithoutComparison()
                              : _selectedLead == "Lead aVL"
                                  ? _leadAvlPlotWithoutComparison()
                                  : _selectedLead == "Lead aVF"
                                      ? _leadAvfPlotWithoutComparison()
                                      : _selectedLead == "Lead V1"
                                          ? _leadV1PlotWithoutComparison()
                                          : _selectedLead == "Lead V2"
                                              ? _leadV2PlotWithoutComparison()
                                              : _selectedLead == "Lead V3"
                                                  ? _leadV3PlotWithoutComparison()
                                                  : _selectedLead == "Lead V4"
                                                      ? _leadV4PlotWithoutComparison()
                                                      : _selectedLead ==
                                                              "Lead V5"
                                                          ? _leadV5PlotWithoutComparison()
                                                          : _selectedLead ==
                                                                  "Lead V6"
                                                              ? _leadV6PlotWithoutComparison()
                                                              : const SizedBox(),
            ),
          ),
        ),
      ],
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

  Widget _lead1PlotWithoutComparison() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: EdgeInsets.only(top: _height / (_devHeight / 25)),
          child: Text(
            "Lead I",
            style: TextStyle(fontSize: _width / (_devWidth / 10)),
          ),
        ),
        SizedBox(
            height: _height / (_devHeight / 200),
            child: _ecgPlot(actl1Data, _calcMin(actl1Data), _calcMax(actl1Data),
                Colors.green)),
      ],
    );
  }

  Widget _lead2PlotWithoutComparison() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: EdgeInsets.only(top: _height / (_devHeight / 25)),
          child: Text(
            "Lead II",
            style: TextStyle(fontSize: _width / (_devWidth / 10)),
          ),
        ),
        SizedBox(
            height: _height / (_devHeight / 200),
            child: _ecgPlot(predl2Data, _calcMin(predl2Data),
                _calcMax(predl2Data), Colors.blue)),
      ],
    );
  }

  Widget _lead3PlotWithoutComparison() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: EdgeInsets.only(top: _height / (_devHeight / 25)),
          child: Text(
            "Lead III",
            style: TextStyle(fontSize: _width / (_devWidth / 10)),
          ),
        ),
        SizedBox(
            height: _height / (_devHeight / 200),
            child: _ecgPlot(predl3Data, _calcMin(predl3Data),
                _calcMax(predl3Data), Colors.blue)),
      ],
    );
  }

  Widget _leadAvrPlotWithoutComparison() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: EdgeInsets.only(top: _height / (_devHeight / 25)),
          child: Text(
            "Lead aVR",
            style: TextStyle(fontSize: _width / (_devWidth / 10)),
          ),
        ),
        SizedBox(
            height: _height / (_devHeight / 200),
            child: _ecgPlot(predavrData, _calcMin(predavrData),
                _calcMax(predavrData), Colors.blue)),
      ],
    );
  }

  Widget _leadAvlPlotWithoutComparison() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: EdgeInsets.only(top: _height / (_devHeight / 25)),
          child: Text(
            "Lead aVL",
            style: TextStyle(fontSize: _width / (_devWidth / 10)),
          ),
        ),
        SizedBox(
            height: _height / (_devHeight / 200),
            child: _ecgPlot(predavlData, _calcMin(predavlData),
                _calcMax(predavlData), Colors.blue)),
      ],
    );
  }

  Widget _leadAvfPlotWithoutComparison() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: EdgeInsets.only(top: _height / (_devHeight / 25)),
          child: Text(
            "Lead aVF",
            style: TextStyle(fontSize: _width / (_devWidth / 10)),
          ),
        ),
        SizedBox(
            height: _height / (_devHeight / 200),
            child: _ecgPlot(predavfData, _calcMin(predavfData),
                _calcMax(predavfData), Colors.blue)),
      ],
    );
  }

  Widget _leadV1PlotWithoutComparison() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: EdgeInsets.only(top: _height / (_devHeight / 25)),
          child: Text(
            "Lead V1",
            style: TextStyle(fontSize: _width / (_devWidth / 10)),
          ),
        ),
        SizedBox(
            height: _height / (_devHeight / 200),
            child: _ecgPlot(predv1Data, _calcMin(predv1Data),
                _calcMax(predv1Data), Colors.blue)),
      ],
    );
  }

  Widget _leadV2PlotWithoutComparison() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: EdgeInsets.only(top: _height / (_devHeight / 25)),
          child: Text(
            "Lead V2",
            style: TextStyle(fontSize: _width / (_devWidth / 10)),
          ),
        ),
        SizedBox(
            height: _height / (_devHeight / 200),
            child: _ecgPlot(predv2Data, _calcMin(predv2Data),
                _calcMax(predv2Data), Colors.blue)),
      ],
    );
  }

  Widget _leadV3PlotWithoutComparison() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: EdgeInsets.only(top: _height / (_devHeight / 25)),
          child: Text(
            "Lead V3",
            style: TextStyle(fontSize: _width / (_devWidth / 10)),
          ),
        ),
        SizedBox(
            height: _height / (_devHeight / 200),
            child: _ecgPlot(predv3Data, _calcMin(predv3Data),
                _calcMax(predv3Data), Colors.blue)),
      ],
    );
  }

  Widget _leadV4PlotWithoutComparison() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: EdgeInsets.only(top: _height / (_devHeight / 25)),
          child: Text(
            "Lead V4",
            style: TextStyle(fontSize: _width / (_devWidth / 10)),
          ),
        ),
        SizedBox(
            height: _height / (_devHeight / 200),
            child: _ecgPlot(predv4Data, _calcMin(predv4Data),
                _calcMax(predv4Data), Colors.blue)),
      ],
    );
  }

  Widget _leadV5PlotWithoutComparison() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: EdgeInsets.only(top: _height / (_devHeight / 25)),
          child: Text(
            "Lead V5",
            style: TextStyle(fontSize: _width / (_devWidth / 10)),
          ),
        ),
        SizedBox(
            height: _height / (_devHeight / 200),
            child: _ecgPlot(predv5Data, _calcMin(predv5Data),
                _calcMax(predv5Data), Colors.blue)),
      ],
    );
  }

  Widget _leadV6PlotWithoutComparison() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: EdgeInsets.only(top: _height / (_devHeight / 25)),
          child: Text(
            "Lead V6",
            style: TextStyle(fontSize: _width / (_devWidth / 10)),
          ),
        ),
        SizedBox(
            height: _height / (_devHeight / 200),
            child: _ecgPlot(predv6Data, _calcMin(predv6Data),
                _calcMax(predv6Data), Colors.blue)),
      ],
    );
  }

  Future<void> _onTapDiagnoseBtn() async {
    try {
      File ecgFile = await _saveLeadsToFile();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) =>
              ECGDiagnosisScreen(file: ecgFile, user: widget._user),
        ),
      );
    } catch (e) {
      // print("Error saving ECG data to file: $e");
      // Optionally, show an error message to the user
    }
  }

  Future<File> _saveLeadsToFile() async {
    Map<String, List<double>> ecgData = {
      'l1': widget.l1Data,
      'l2': predl2Data,
      'l3': predl3Data,
      'avr': predavrData,
      'avl': predavlData,
      'avf': predavfData,
      'v1': predv1Data,
      'v2': predv2Data,
      'v3': predv3Data,
      'v4': predv4Data,
      'v5': predv5Data,
      'v6': predv6Data,
    };

    String jsonString = jsonEncode(ecgData);

    Directory directory = await getApplicationDocumentsDirectory();
    String filePath = '${directory.path}/ecg_data.txt';
    File file = File(filePath);

    return file.writeAsString(jsonString);
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
            ? _plotsWithoutComparison()
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
                            _loadingSpinnerText,
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
