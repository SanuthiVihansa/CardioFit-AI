import 'package:cardiofitai/models/user.dart';
import 'package:cardiofitai/screens/ecg_reconstruction/all_lead_display_screen.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class RecordingPlot extends StatelessWidget {
  RecordingPlot(this._countdown, this._ecgData, this._user, {super.key});

  final int _countdown;
  final List<double> _ecgData;
  final User _user;
  double _maxValue = 0;
  double _minValue = 0;

  late double _width;
  late double _height;
  final double _devWidth = 753.4545454545455;
  final double _devHeight = 392.72727272727275;

  double _getMinValue() {
    return _ecgData
            .reduce((value, element) => value < element ? value : element) -
        0.1;
  }

  double _getMaxValue() {
    return _ecgData
            .reduce((value, element) => value > element ? value : element) +
        0.1;
  }

  Widget _ecgPlot() {
    return Padding(
      padding: EdgeInsets.only(
          top: _height / (_devHeight / 16),
          bottom: _height / (_devHeight / 1),
          left: _width / (_devWidth / 16),
          right: _width / (_devWidth / 16)),
      child: IgnorePointer(
        ignoring: true,
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
                dotData: FlDotData(
                  show: false,
                ),
              ),
            ],
            minY: _getMinValue(),
            // minY: 500,
            // Adjust these values based on your data range
            maxY: _getMaxValue(),
            // maxY: 0,
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

  void _onTapProceedBtn(BuildContext context) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (BuildContext conext) => AllLeadDisplayScreen(_ecgData, _user)));
  }

  @override
  Widget build(BuildContext context) {
    _width = MediaQuery.of(context).size.width;
    _height = MediaQuery.of(context).size.height;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Lead II ECG Signal",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              // Text("Remaining time: $_countdown s")
            ],
          ),
        ),
        Expanded(child: SizedBox(child: _ecgPlot())),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
              padding: EdgeInsets.only(
                  left: _width / (_devWidth / 20),
                  right: _width / (_devWidth / 20),
                  bottom: _height / (_devHeight / 5)),
              child: ElevatedButton(
                  onPressed: () {
                    _onTapProceedBtn(context);
                  },
                  child: Text("Proceed")),
            ),
          ],
        )

        // Text(_ecgData[_ecgData.length - 1].toString())
      ],
    );
  }
}
