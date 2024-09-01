import 'package:cardiofitai/components/navigation_panel_component.dart';
import 'package:cardiofitai/models/user.dart';
import 'package:cardiofitai/screens/ecg_reconstruction/ecg_history_screen.dart';
import 'package:cardiofitai/screens/palm_analysis/for_pp2/electrode_placement_instructions_screen.dart';
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

  // ignore: unused_field
  final double _hDevWidth = 1280.0;

  // ignore: unused_field
  final double _hDevHeight = 740.0;

  final double iconSize = 100;
  final double iconTextFontSize = 30;
  final double buttonLength = 400;
  final double buttonRoundness = 150;

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

  Widget _ecgHistoryBtn() {
    return Container(
      height: _height / (_devHeight / 130),
      width: _width / (_devWidth / 300),
      margin: EdgeInsets.only(
          right: _width / (_devWidth / 10), bottom: _height / (_devHeight / 4)),
      child: Material(
        borderRadius: const BorderRadius.all(Radius.circular(20)),
        elevation: 4,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Flexible(
              fit: FlexFit.loose,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: Image.asset(
                  'assets/ecg_reconstruction/ecg_history_btn_bg.png',
                  width: _width / (_devWidth / 300),
                  fit: BoxFit.fitWidth,
                ),
              ),
            ),
            Flexible(
              fit: FlexFit.tight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Center(
                    child: Text("ECG History",
                        style: TextStyle(
                            color: Colors.blueGrey,
                            fontSize: _height / (_devHeight / 8),
                            fontWeight: FontWeight.w700)),
                  ),
                  const Center(child: Text("Explore ECG History")),
                  SizedBox(height: _height / (_devHeight / 4))
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _takeECGBtn() {
    return Container(
      height: _height / (_devHeight / 130),
      width: _width / (_devWidth / 300),
      margin: EdgeInsets.only(
          right: _width / (_devWidth / 10), bottom: _height / (_devHeight / 4)),
      child: Material(
        borderRadius: const BorderRadius.all(Radius.circular(20)),
        elevation: 4,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Flexible(
              fit: FlexFit.loose,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: Image.asset(
                  'assets/ecg_reconstruction/take_ecg_btn_bg.jpeg',
                  width: _width / (_devWidth / 300),
                  fit: BoxFit.fitWidth,
                ),
              ),
            ),
            Flexible(
              fit: FlexFit.tight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Center(
                    child: Text("Take ECG",
                        style: TextStyle(
                            color: Colors.blueGrey,
                            fontSize: _height / (_devHeight / 8),
                            fontWeight: FontWeight.w700)),
                  ),
                  const Center(child: Text("Record Your ECG")),
                  SizedBox(height: _height / (_devHeight / 4))
                ],
              ),
            )
          ],
        ),
      ),
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
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        GestureDetector(
                          child: _ecgHistoryBtn(),
                          onTap: () {
                            _onClickHistoryBtn();
                          },
                        ),
                        GestureDetector(
                          child: _takeECGBtn(),
                          onTap: () {
                            _onClickTakeECGBtn();
                          },
                        ),
                        // ElevatedButton(
                        //     onPressed: () {
                        //       _onTapTempBtn();
                        //     },
                        //     child: Text("Temp button for Diagnosis"))
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                        left: _width / (_devWidth / 8),
                        right: _width / (_devWidth / 8),
                        bottom: _height / (_devHeight / 8),
                        top: _height / (_devHeight / 1)),
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
                        const SizedBox(height: 8),
                        Container(
                          height: _height / (_devHeight / 180),
                          width: _width,
                          color: Colors.blueGrey[50], // Placeholder for graph
                          child: _lastEcgIsLoading == true
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const CircularProgressIndicator(),
                                    Padding(
                                      padding: EdgeInsets.only(
                                          top: _height / (_devHeight / 8)),
                                      child: const Text('Loading'),
                                    ),
                                  ],
                                )
                              : _lastEcgData.isEmpty
                                  ? const Center(
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
