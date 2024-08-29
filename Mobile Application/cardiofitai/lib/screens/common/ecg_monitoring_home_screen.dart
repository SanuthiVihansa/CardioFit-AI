import 'package:cardiofitai/components/navigation_panel_component.dart';
import 'package:cardiofitai/models/user.dart';
import 'package:cardiofitai/screens/defect_prediction/ecg_plot.dart';
import 'package:cardiofitai/screens/defect_prediction/report_home_screen.dart';
import 'package:cardiofitai/screens/ecg_reconstruction/ecg_history_screen.dart';
import 'package:cardiofitai/screens/facial_analysis/facial_analysis_home.dart';
import 'package:cardiofitai/screens/palm_analysis/for_future_use/file_selection_screen.dart';
import 'package:cardiofitai/screens/palm_analysis/for_pp2/electrode_placement_instructions_screen.dart';
import 'package:cardiofitai/screens/palm_analysis/temp_file_selection_screen.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../services/ecg_service.dart';

class ECGMonitoringHomeScreen extends StatefulWidget {
  const ECGMonitoringHomeScreen(this._user, {super.key});

  final User _user;

  @override
  State<ECGMonitoringHomeScreen> createState() =>
      _ECGMonitoringHomeScreenState();
}

class _ECGMonitoringHomeScreenState extends State<ECGMonitoringHomeScreen> {
  late double _width;
  late double _height;
  final double _devWidth = 753.4545454545455;
  final double _devHeight = 392.72727272727275;
  final double _hDevWidth = 1280.0;
  final double _hDevHeight = 740.0;

  final double iconSize = 100;
  final double iconTextFontSize = 30;
  final double buttonLength = 400;
  final double buttonRoundness = 150;

  late double responsiveIconSize = _height / (_hDevHeight / iconSize);
  late double responsiveIconTextFontSize =
      _width / (_hDevWidth / iconTextFontSize);
  late double responsiveButtonLength = _width / (_hDevWidth / buttonLength);
  late double responsiveButtonRoundness =
      _width / (_hDevWidth / buttonRoundness);
  List<Map<String, dynamic>> _lastEcgData = [];
  bool _lastEcgIsLoading = true;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    _getLastEcg();
  }

  Future<void> _getLastEcg() async {
    _lastEcgData = await EcgService.getLastEcg(widget._user.email);
    setState(() {
      _lastEcgIsLoading = false;
    });
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

  Widget _lead1Plot(List<double> l1Data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: EdgeInsets.only(top: _height / (_devHeight / 10)),
          child: Text(
            "Lead I",
            style: TextStyle(fontSize: _width / (_devWidth / 10)),
          ),
        ),
        SizedBox(
            height: _height / (_devHeight / 130),
            child: _ecgPlot(
                l1Data, _calcMin(l1Data), _calcMax(l1Data), Colors.blue)),
      ],
    );
  }

  void _onClickHistoryBtn() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) => EcgHistoryScreen(widget._user)));
  }

  void _onClickTakeECGBtn() {
    Navigator.push(
        context,
        MaterialPageRoute(
            // builder: (BuildContext context) => const FileSelectionScreen()));
            builder: (BuildContext context) =>
                ElectrodePlacementInstructionsScreen(widget._user)));
  }

  void _onTapTempBtn() {
    Navigator.push(context,
        MaterialPageRoute(builder: (BuildContext context) => ReportHome()));
  }

  @override
  Widget build(BuildContext context) {
    _width = MediaQuery.of(context).size.width;
    _height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: const Text(
          "ECG Monitoring",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.red,
      ),
      body: Row(
        children: [
          NavigationPanelComponent("ecg", widget._user),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                          style: ButtonStyle(
                              fixedSize: MaterialStateProperty.all<Size>(Size(
                                  responsiveButtonLength,
                                  responsiveButtonRoundness))),
                          onPressed: () {
                            _onClickHistoryBtn();
                          },
                          icon: Image.asset(
                              'assets/ecg_reconstruction/history.png',
                              width: responsiveIconSize,
                              height: responsiveIconSize,
                              fit: BoxFit.contain),
                          label: Text(
                            "ECG History",
                            style: TextStyle(
                                fontSize: responsiveIconTextFontSize,
                                color: Colors.purple),
                          )),
                      ElevatedButton.icon(
                          style: ButtonStyle(
                              fixedSize: MaterialStateProperty.all<Size>(Size(
                                  responsiveButtonLength,
                                  responsiveButtonRoundness))),
                          onPressed: () {
                            _onClickTakeECGBtn();
                          },
                          icon: Image.asset('assets/palm_analysis/praying.png',
                              width: responsiveIconSize,
                              height: responsiveIconSize,
                              fit: BoxFit.contain),
                          label: Text(
                            "Take ECG",
                            style: TextStyle(
                                fontSize: responsiveIconTextFontSize,
                                color: Colors.purple),
                          )),
                      ElevatedButton(
                          onPressed: () {
                            _onTapTempBtn();
                          },
                          child: Text("Temp button for Diagnosis"))
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 16.0, right: 16, bottom: 16, top: 50),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Recent ECG Report         ',
                          style: TextStyle(
                            fontSize: _height / (_devHeight / 10),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Container(
                          height: _height / (_devHeight / 180),
                          width: _width,
                          color: Colors.blueGrey[50], // Placeholder for graph
                          child: _lastEcgIsLoading == true
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircularProgressIndicator(),
                                    Padding(
                                      padding: EdgeInsets.only(
                                          top: _height / (_devHeight / 8)),
                                      child: Text('Loading'),
                                    ),
                                  ],
                                )
                              : _lastEcgData.length == 0
                                  ? Center(
                                      child: Text('No ECG Report'),
                                    )
                                  : Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _lead1Plot(_lastEcgData[0]["l1"]
                                            .cast<double>()),
                                        Padding(
                                          padding: EdgeInsets.only(
                                              left: _width / (_devWidth / 30)),
                                          child: Text(
                                            'Date: ${DateFormat('yyyy-MM-dd').format(_lastEcgData[0]["datetime"].toDate())}         Time: ${DateFormat('HH:mm:ss').format(_lastEcgData[0]["datetime"].toDate())}',
                                            style: TextStyle(
                                              fontSize:
                                                  _height / (_devHeight / 10),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
