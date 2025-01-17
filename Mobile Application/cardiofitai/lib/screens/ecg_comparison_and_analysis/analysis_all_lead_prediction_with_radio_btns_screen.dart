import 'dart:convert';

import 'package:cardiofitai/screens/facial_analysis/facial_analysis_home.dart';
import 'package:cardiofitai/screens/palm_analysis/temp_file_selection_screen.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class AnalysisAllLeadPredictionWithRadioBtnsScreen extends StatefulWidget {
  const AnalysisAllLeadPredictionWithRadioBtnsScreen(
      this.l1Data,
      this.l2Data,
      this.v1Data,
      this.v2Data,
      this.v3Data,
      this.v4Data,
      this.v5Data,
      this.v6Data,
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
  State<AnalysisAllLeadPredictionWithRadioBtnsScreen> createState() =>
      _AnalysisAllLeadPredictionWithRadioBtnsScreenState();
}

class _AnalysisAllLeadPredictionWithRadioBtnsScreenState
    extends State<AnalysisAllLeadPredictionWithRadioBtnsScreen> {
  late double _width;
  late double _height;
  final double _devWidth = 753.4545454545455;
  final double _devHeight = 392.72727272727275;
  final double _hDevWidth = 1280.0;
  final double _hDevHeight = 740.0;

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
          .timeout(const Duration(seconds: 60));

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

  void _onClickFacialAnalysisBtn() {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (BuildContext context) =>
            FacialAnalysisHome(_width, _height, _hDevHeight, _hDevWidth)));
  }

  void _onClickPalmAnalysisBtn() {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (BuildContext context) => const TempFileSelectionScreen()));
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
                      padding: EdgeInsets.symmetric(
                          horizontal: _width / (_devWidth / 4)),
                      child: ElevatedButton(
                        onPressed: () {
                          _onClickFacialAnalysisBtn();
                        },
                        style: ButtonStyle(
                          fixedSize: MaterialStateProperty.all<Size>(
                            Size(
                                _width / (_devWidth / 120.0),
                                _height /
                                    (_devHeight /
                                        40)), // Button width and height
                          ),
                        ),
                        child: Text(
                          "Facial Analysis",
                          style: TextStyle(fontSize: _width / (_devWidth / 10)),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: _width / (_devWidth / 4)),
                      child: ElevatedButton(
                        onPressed: () {
                          _onClickPalmAnalysisBtn();
                        },
                        style: ButtonStyle(
                          fixedSize: MaterialStateProperty.all<Size>(
                            Size(
                                _width / (_devWidth / 120.0),
                                _height /
                                    (_devHeight /
                                        40)), // Button width and height
                          ),
                        ),
                        child: Text(
                          "Palm Analysis",
                          style: TextStyle(fontSize: _width / (_devWidth / 10)),
                        ),
                      ),
                    ),
                    // ElevatedButton(
                    //   onPressed: () {
                    //     _onClickHomeBtn();
                    //   },
                    //   style: ButtonStyle(
                    //     fixedSize: MaterialStateProperty.all<Size>(
                    //       Size(
                    //           _width / (_devWidth / 120.0),
                    //           _height /
                    //               (_devHeight / 40)), // Button width and height
                    //     ),
                    //   ),
                    //   child: Text(
                    //     "Home",
                    //     style: TextStyle(fontSize: _width / (_devWidth / 10)),
                    //   ),
                    // )
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
                    Text(
                      "Selected Lead: ",
                      style: TextStyle(fontSize: _width / (_devWidth / 14)),
                    ),
                    _leadSelectionDropDown(),
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
                        "Compare with actual",
                        style: TextStyle(fontSize: _width / (_devWidth / 14)),
                      ),
                    ),
                    // ElevatedButton(
                    //   onPressed: () {
                    //     _onClickHomeBtn();
                    //   },
                    //   style: ButtonStyle(
                    //     fixedSize: MaterialStateProperty.all<Size>(
                    //       Size(
                    //           _width / (_devWidth / 120.0),
                    //           _height /
                    //               (_devHeight / 40)), // Button width and height
                    //     ),
                    //   ),
                    //   child: Text(
                    //     "Home",
                    //     style: TextStyle(fontSize: _width / (_devWidth / 10)),
                    //   ),
                    // )
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
                  ? _lead1PlotWithComparison()
                  : _selectedLead == "Lead II"
                      ? _lead2PlotWithComparison()
                      : _selectedLead == "Lead III"
                          ? _lead3PlotWithComparison()
                          : _selectedLead == "Lead aVR"
                              ? _leadAvrPlotWithComparison()
                              : _selectedLead == "Lead aVL"
                                  ? _leadAvlPlotWithComparison()
                                  : _selectedLead == "Lead aVF"
                                      ? _leadAvfPlotWithComparison()
                                      : _selectedLead == "Lead V1"
                                          ? _leadV1PlotWithComparison()
                                          : _selectedLead == "Lead V2"
                                              ? _leadV2PlotWithComparison()
                                              : _selectedLead == "Lead V3"
                                                  ? _leadV3PlotWithComparison()
                                                  : _selectedLead == "Lead V4"
                                                      ? _leadV4PlotWithComparison()
                                                      : _selectedLead ==
                                                              "Lead V5"
                                                          ? _leadV5PlotWithComparison()
                                                          : _selectedLead ==
                                                                  "Lead V6"
                                                              ? _leadV6PlotWithComparison()
                                                              : const SizedBox(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _leadSelectionDropDown() {
    return Container(
      width: 200,
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
            "Actual Lead II",
            style: TextStyle(fontSize: _width / (_devWidth / 11), fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
            height: _height / (_devHeight / 125),
            child: _ecgPlot(actl2Data, _calcMin(actl2Data), _calcMax(actl2Data),
                Colors.green)),
        Text(
          "Reconstructed Lead I from CardioFit AI",
          style: TextStyle(fontSize: _width / (_devWidth / 11), fontWeight: FontWeight.bold),
        ),
        SizedBox(
            height: _height / (_devHeight / 125),
            child: _ecgPlot(predl1Data, _calcMin(predl1Data),
                _calcMax(predl1Data), Colors.blue)),
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
            "Actual Lead II",
            style: TextStyle(fontSize: _width / (_devWidth / 11), fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
            height: _height / (_devHeight / 125),
            child: _ecgPlot(actl2Data, _calcMin(actl2Data), _calcMax(actl2Data),
                Colors.green)),
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
            "Actual Lead II",
            style: TextStyle(fontSize: _width / (_devWidth / 11), fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
            height: _height / (_devHeight / 125),
            child: _ecgPlot(actl2Data, _calcMin(actl2Data), _calcMax(actl2Data),
                Colors.green)),
        Text(
          "Reconstructed Lead III from CardioFit AI",
          style: TextStyle(fontSize: _width / (_devWidth / 11), fontWeight: FontWeight.bold),
        ),
        SizedBox(
            height: _height / (_devHeight / 125),
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
            "Actual Lead II",
            style: TextStyle(fontSize: _width / (_devWidth / 11), fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
            height: _height / (_devHeight / 125),
            child: _ecgPlot(actl2Data, _calcMin(actl2Data), _calcMax(actl2Data),
                Colors.green)),
        Text(
          "Reconstructed Lead aVR from CardioFit AI",
          style: TextStyle(fontSize: _width / (_devWidth / 11), fontWeight: FontWeight.bold),
        ),
        SizedBox(
            height: _height / (_devHeight / 125),
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
            "Actual Lead II",
            style: TextStyle(fontSize: _width / (_devWidth / 11), fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
            height: _height / (_devHeight / 125),
            child: _ecgPlot(actl2Data, _calcMin(actl2Data), _calcMax(actl2Data),
                Colors.green)),
        Text(
          "Reconstructed Lead aVL from CardioFit AI",
          style: TextStyle(fontSize: _width / (_devWidth / 11), fontWeight: FontWeight.bold),
        ),
        SizedBox(
            height: _height / (_devHeight / 125),
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
            "Actual Lead II",
            style: TextStyle(fontSize: _width / (_devWidth / 11), fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
            height: _height / (_devHeight / 125),
            child: _ecgPlot(actl2Data, _calcMin(actl2Data), _calcMax(actl2Data),
                Colors.green)),
        Text(
          "Reconstructed Lead aVF from CardioFit AI",
          style: TextStyle(fontSize: _width / (_devWidth / 11), fontWeight: FontWeight.bold),
        ),
        SizedBox(
            height: _height / (_devHeight / 125),
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
            "Actual Lead II",
            style: TextStyle(fontSize: _width / (_devWidth / 11), fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
            height: _height / (_devHeight / 125),
            child: _ecgPlot(actl2Data, _calcMin(actl2Data), _calcMax(actl2Data),
                Colors.green)),
        Text(
          "Reconstructed Lead V1 from CardioFit AI",
          style: TextStyle(fontSize: _width / (_devWidth / 11), fontWeight: FontWeight.bold),
        ),
        SizedBox(
            height: _height / (_devHeight / 125),
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
            "Actual Lead II",
            style: TextStyle(fontSize: _width / (_devWidth / 11), fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
            height: _height / (_devHeight / 125),
            child: _ecgPlot(actl2Data, _calcMin(actl2Data), _calcMax(actl2Data),
                Colors.green)),
        Text(
          "Reconstructed Lead V2 from CardioFit AI",
          style: TextStyle(fontSize: _width / (_devWidth / 11), fontWeight: FontWeight.bold),
        ),
        SizedBox(
            height: _height / (_devHeight / 125),
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
            "Actual Lead II",
            style: TextStyle(fontSize: _width / (_devWidth / 11), fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
            height: _height / (_devHeight / 125),
            child: _ecgPlot(actl2Data, _calcMin(actl2Data), _calcMax(actl2Data),
                Colors.green)),
        Text(
          "Reconstructed Lead V3 from CardioFit AI",
          style: TextStyle(fontSize: _width / (_devWidth / 11), fontWeight: FontWeight.bold),
        ),
        SizedBox(
            height: _height / (_devHeight / 125),
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
            "Actual Lead II",
            style: TextStyle(fontSize: _width / (_devWidth / 11), fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
            height: _height / (_devHeight / 125),
            child: _ecgPlot(actl2Data, _calcMin(actl2Data), _calcMax(actl2Data),
                Colors.green)),
        Text(
          "Reconstructed Lead V4 from CardioFit AI",
          style: TextStyle(fontSize: _width / (_devWidth / 11), fontWeight: FontWeight.bold),
        ),
        SizedBox(
            height: _height / (_devHeight / 125),
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
            "Actual Lead II",
            style: TextStyle(fontSize: _width / (_devWidth / 11), fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
            height: _height / (_devHeight / 125),
            child: _ecgPlot(actl2Data, _calcMin(actl2Data), _calcMax(actl2Data),
                Colors.green)),
        Text(
          "Reconstructed Lead V5 from CardioFit AI",
          style: TextStyle(fontSize: _width / (_devWidth / 11), fontWeight: FontWeight.bold),
        ),
        SizedBox(
            height: _height / (_devHeight / 125),
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
            "Actual Lead II",
            style: TextStyle(fontSize: _width / (_devWidth / 11), fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
            height: _height / (_devHeight / 125),
            child: _ecgPlot(actl2Data, _calcMin(actl2Data), _calcMax(actl2Data),
                Colors.green)),
        Text(
          "Reconstructed Lead V6 from CardioFit AI",
          style: TextStyle(fontSize: _width / (_devWidth / 11), fontWeight: FontWeight.bold),
        ),
        SizedBox(
            height: _height / (_devHeight / 125),
            child: _ecgPlot(predv6Data, _calcMin(predv6Data),
                _calcMax(predv6Data), Colors.blue)),
      ],
    );
  }

  Widget _lead1PlotWithComparison() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: EdgeInsets.only(
            left: _width / (_devWidth / 20),
            top: _height / (_devHeight / 8),
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
            height: _height / (_devHeight / 125),
            child: _ecgPlot(actl1Data, _calcMin(actl1Data), _calcMax(actl1Data),
                Colors.green)),
        Text(
          "Predicted Lead I",
          style: TextStyle(fontSize: _width / (_devWidth / 10)),
        ),
        SizedBox(
            height: _height / (_devHeight / 125),
            child: _ecgPlot(predl1Data, _calcMin(predl1Data),
                _calcMax(predl1Data), Colors.blue)),
      ],
    );
  }

  Widget _lead2PlotWithComparison() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: EdgeInsets.only(top: _height / (_devHeight / 25)),
          child: Text(
            "Actual Lead II",
            style: TextStyle(fontSize: _width / (_devWidth / 10)),
          ),
        ),
        SizedBox(
            height: _height / (_devHeight / 125),
            child: _ecgPlot(actl2Data, _calcMin(actl2Data), _calcMax(actl2Data),
                Colors.green)),
      ],
    );
  }

  Widget _lead3PlotWithComparison() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: EdgeInsets.only(
            left: _width / (_devWidth / 20),
            top: _height / (_devHeight / 8),
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
          "Actual Lead III",
          style: TextStyle(fontSize: _width / (_devWidth / 10)),
        ),
        SizedBox(
            height: _height / (_devHeight / 125),
            child: _ecgPlot(actl3Data, _calcMin(actl3Data), _calcMax(actl3Data),
                Colors.green)),
        Text(
          "Predicted Lead III",
          style: TextStyle(fontSize: _width / (_devWidth / 10)),
        ),
        SizedBox(
            height: _height / (_devHeight / 125),
            child: _ecgPlot(predl3Data, _calcMin(predl3Data),
                _calcMax(predl3Data), Colors.blue)),
      ],
    );
  }

  Widget _leadAvrPlotWithComparison() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: EdgeInsets.only(
            left: _width / (_devWidth / 20),
            top: _height / (_devHeight / 8),
          ),
          child: Row(
            children: [
              Text(
                "Similarity : ${(avrp * 100).toStringAsFixed(2)} %",
                style: TextStyle(fontSize: _width / (_devWidth / 13)),
              ),
            ],
          ),
        ),
        Text(
          "Actual Lead aVR",
          style: TextStyle(fontSize: _width / (_devWidth / 10)),
        ),
        SizedBox(
            height: _height / (_devHeight / 125),
            child: _ecgPlot(actavrData, _calcMin(actavrData),
                _calcMax(actavrData), Colors.green)),
        Text(
          "Predicted Lead aVR",
          style: TextStyle(fontSize: _width / (_devWidth / 10)),
        ),
        SizedBox(
            height: _height / (_devHeight / 125),
            child: _ecgPlot(predavrData, _calcMin(predavrData),
                _calcMax(predavrData), Colors.blue)),
      ],
    );
  }

  Widget _leadAvlPlotWithComparison() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: EdgeInsets.only(
            left: _width / (_devWidth / 20),
            top: _height / (_devHeight / 8),
          ),
          child: Row(
            children: [
              Text(
                "Similarity : ${(avlp * 100).toStringAsFixed(2)} %",
                style: TextStyle(fontSize: _width / (_devWidth / 13)),
              ),
            ],
          ),
        ),
        Text(
          "Actual Lead aVL",
          style: TextStyle(fontSize: _width / (_devWidth / 10)),
        ),
        SizedBox(
            height: _height / (_devHeight / 125),
            child: _ecgPlot(actavlData, _calcMin(actavlData),
                _calcMax(actavlData), Colors.green)),
        Text(
          "Predicted Lead aVL",
          style: TextStyle(fontSize: _width / (_devWidth / 10)),
        ),
        SizedBox(
            height: _height / (_devHeight / 125),
            child: _ecgPlot(predavlData, _calcMin(predavlData),
                _calcMax(predavlData), Colors.blue)),
      ],
    );
  }

  Widget _leadAvfPlotWithComparison() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: EdgeInsets.only(
            left: _width / (_devWidth / 20),
            top: _height / (_devHeight / 8),
          ),
          child: Row(
            children: [
              Text(
                "Similarity : ${(avfp * 100).toStringAsFixed(2)} %",
                style: TextStyle(fontSize: _width / (_devWidth / 13)),
              ),
            ],
          ),
        ),
        Text(
          "Actual Lead aVF",
          style: TextStyle(fontSize: _width / (_devWidth / 10)),
        ),
        SizedBox(
            height: _height / (_devHeight / 125),
            child: _ecgPlot(actavfData, _calcMin(actavfData),
                _calcMax(actavfData), Colors.green)),
        Text(
          "Predicted Lead aVF",
          style: TextStyle(fontSize: _width / (_devWidth / 10)),
        ),
        SizedBox(
            height: _height / (_devHeight / 125),
            child: _ecgPlot(predavfData, _calcMin(predavfData),
                _calcMax(predavfData), Colors.blue)),
      ],
    );
  }

  Widget _leadV1PlotWithComparison() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: EdgeInsets.only(
            left: _width / (_devWidth / 20),
            top: _height / (_devHeight / 8),
          ),
          child: Row(
            children: [
              Text(
                "Similarity : ${(v1p * 100).toStringAsFixed(2)} %",
                style: TextStyle(fontSize: _width / (_devWidth / 13)),
              ),
            ],
          ),
        ),
        Text(
          "Actual Lead V1",
          style: TextStyle(fontSize: _width / (_devWidth / 10)),
        ),
        SizedBox(
            height: _height / (_devHeight / 125),
            child: _ecgPlot(actv1Data, _calcMin(actv1Data), _calcMax(actv1Data),
                Colors.green)),
        Text(
          "Predicted Lead V1",
          style: TextStyle(fontSize: _width / (_devWidth / 10)),
        ),
        SizedBox(
            height: _height / (_devHeight / 125),
            child: _ecgPlot(predv1Data, _calcMin(predv1Data),
                _calcMax(predv1Data), Colors.blue)),
      ],
    );
  }

  Widget _leadV2PlotWithComparison() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: EdgeInsets.only(
            left: _width / (_devWidth / 20),
            top: _height / (_devHeight / 8),
          ),
          child: Row(
            children: [
              Text(
                "Similarity : ${(v2p * 100).toStringAsFixed(2)} %",
                style: TextStyle(fontSize: _width / (_devWidth / 13)),
              ),
            ],
          ),
        ),
        Text(
          "Actual Lead V2",
          style: TextStyle(fontSize: _width / (_devWidth / 10)),
        ),
        SizedBox(
            height: _height / (_devHeight / 125),
            child: _ecgPlot(actv2Data, _calcMin(actv2Data), _calcMax(actv2Data),
                Colors.green)),
        Text(
          "Predicted Lead V2",
          style: TextStyle(fontSize: _width / (_devWidth / 10)),
        ),
        SizedBox(
            height: _height / (_devHeight / 125),
            child: _ecgPlot(predv2Data, _calcMin(predv2Data),
                _calcMax(predv2Data), Colors.blue)),
      ],
    );
  }

  Widget _leadV3PlotWithComparison() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: EdgeInsets.only(
            left: _width / (_devWidth / 20),
            top: _height / (_devHeight / 8),
          ),
          child: Row(
            children: [
              Text(
                "Similarity : ${(v3p * 100).toStringAsFixed(2)} %",
                style: TextStyle(fontSize: _width / (_devWidth / 13)),
              ),
            ],
          ),
        ),
        Text(
          "Actual Lead V3",
          style: TextStyle(fontSize: _width / (_devWidth / 10)),
        ),
        SizedBox(
            height: _height / (_devHeight / 125),
            child: _ecgPlot(actv3Data, _calcMin(actv3Data), _calcMax(actv3Data),
                Colors.green)),
        Text(
          "Predicted Lead V3",
          style: TextStyle(fontSize: _width / (_devWidth / 10)),
        ),
        SizedBox(
            height: _height / (_devHeight / 125),
            child: _ecgPlot(predv3Data, _calcMin(predv3Data),
                _calcMax(predv3Data), Colors.blue)),
      ],
    );
  }

  Widget _leadV4PlotWithComparison() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: EdgeInsets.only(
            left: _width / (_devWidth / 20),
            top: _height / (_devHeight / 8),
          ),
          child: Row(
            children: [
              Text(
                "Similarity : ${(v4p * 100).toStringAsFixed(2)} %",
                style: TextStyle(fontSize: _width / (_devWidth / 13)),
              ),
            ],
          ),
        ),
        Text(
          "Actual Lead V4",
          style: TextStyle(fontSize: _width / (_devWidth / 10)),
        ),
        SizedBox(
            height: _height / (_devHeight / 125),
            child: _ecgPlot(actv4Data, _calcMin(actv4Data), _calcMax(actv4Data),
                Colors.green)),
        Text(
          "Predicted Lead V4",
          style: TextStyle(fontSize: _width / (_devWidth / 10)),
        ),
        SizedBox(
            height: _height / (_devHeight / 125),
            child: _ecgPlot(predv4Data, _calcMin(predv4Data),
                _calcMax(predv4Data), Colors.blue)),
      ],
    );
  }

  Widget _leadV5PlotWithComparison() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: EdgeInsets.only(
            left: _width / (_devWidth / 20),
            top: _height / (_devHeight / 8),
          ),
          child: Row(
            children: [
              Text(
                "Similarity : ${(v5p * 100).toStringAsFixed(2)} %",
                style: TextStyle(fontSize: _width / (_devWidth / 13)),
              ),
            ],
          ),
        ),
        Text(
          "Actual Lead V5",
          style: TextStyle(fontSize: _width / (_devWidth / 10)),
        ),
        SizedBox(
            height: _height / (_devHeight / 125),
            child: _ecgPlot(actv5Data, _calcMin(actv5Data), _calcMax(actv5Data),
                Colors.green)),
        Text(
          "Predicted Lead V5",
          style: TextStyle(fontSize: _width / (_devWidth / 10)),
        ),
        SizedBox(
            height: _height / (_devHeight / 125),
            child: _ecgPlot(predv5Data, _calcMin(predv5Data),
                _calcMax(predv5Data), Colors.blue)),
      ],
    );
  }

  Widget _leadV6PlotWithComparison() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: EdgeInsets.only(
            left: _width / (_devWidth / 20),
            top: _height / (_devHeight / 8),
          ),
          child: Row(
            children: [
              Text(
                "Similarity : ${(v6p * 100).toStringAsFixed(2)} %",
                style: TextStyle(fontSize: _width / (_devWidth / 13)),
              ),
            ],
          ),
        ),
        Text(
          "Actual Lead V6",
          style: TextStyle(fontSize: _width / (_devWidth / 10)),
        ),
        SizedBox(
            height: _height / (_devHeight / 125),
            child: _ecgPlot(actv6Data, _calcMin(actv6Data), _calcMax(actv6Data),
                Colors.green)),
        Text(
          "Predicted Lead V6",
          style: TextStyle(fontSize: _width / (_devWidth / 10)),
        ),
        SizedBox(
            height: _height / (_devHeight / 125),
            child: _ecgPlot(predv6Data, _calcMin(predv6Data),
                _calcMax(predv6Data), Colors.blue)),
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
            "ECG Analysis",
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
