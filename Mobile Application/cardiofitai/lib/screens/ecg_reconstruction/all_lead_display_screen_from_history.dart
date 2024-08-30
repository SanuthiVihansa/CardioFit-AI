import 'package:cardiofitai/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class AllLeadDisplayScreenFromHistory extends StatefulWidget {
  const AllLeadDisplayScreenFromHistory(
      this._user,
      this.l1Data,
      this.l2Data,
      this.l3Data,
      this.avrData,
      this.avlData,
      this.avfData,
      this.v1Data,
      this.v2Data,
      this.v3Data,
      this.v4Data,
      this.v5Data,
      this.v6Data,
      this.datetime,
      {super.key});

  final List<double> l1Data;
  final List<double> l2Data;
  final List<double> l3Data;
  final List<double> avrData;
  final List<double> avlData;
  final List<double> avfData;
  final List<double> v1Data;
  final List<double> v2Data;
  final List<double> v3Data;
  final List<double> v4Data;
  final List<double> v5Data;
  final List<double> v6Data;
  final Timestamp datetime;
  final User _user;

  @override
  State<AllLeadDisplayScreenFromHistory> createState() =>
      _AllLeadDisplayScreenFromHistoryState();
}

class _AllLeadDisplayScreenFromHistoryState
    extends State<AllLeadDisplayScreenFromHistory> {
  late double _width;
  late double _height;
  final double _devWidth = 753.4545454545455;
  final double _devHeight = 392.72727272727275;

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

  void _onClickHomeBtn() {
    Navigator.pop(context);
    Navigator.pop(context);
  }

  Widget _plotsWithoutComparison() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(
            top: _height / (_devHeight / 10),
            left: _width / (_devWidth / 20),
            right: _width / (_devWidth / 20),
          ),
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
                        onPressed: () {},
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
                          fixedSize: MaterialStateProperty.all<Size>(
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
        Text(
          'Date: ${DateFormat('yyyy-MM-dd').format(widget.datetime.toDate())}         Time: ${DateFormat('HH:mm:ss').format(widget.datetime.toDate())}',
          style: TextStyle(
            fontSize: _height / (_devHeight / 10),
          ),
        )
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
            "Lead I",
            style: TextStyle(fontSize: _width / (_devWidth / 10)),
          ),
        ),
        SizedBox(
            height: _height / (_devHeight / 200),
            child: _ecgPlot(widget.l1Data, _calcMin(widget.l1Data),
                _calcMax(widget.l1Data), Colors.green)),
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
            child: _ecgPlot(widget.l2Data, _calcMin(widget.l2Data),
                _calcMax(widget.l2Data), Colors.blue)),
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
            child: _ecgPlot(widget.l3Data, _calcMin(widget.l3Data),
                _calcMax(widget.l3Data), Colors.blue)),
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
            child: _ecgPlot(widget.avrData, _calcMin(widget.avrData),
                _calcMax(widget.avrData), Colors.blue)),
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
            child: _ecgPlot(widget.avlData, _calcMin(widget.avlData),
                _calcMax(widget.avlData), Colors.blue)),
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
            child: _ecgPlot(widget.avfData, _calcMin(widget.avfData),
                _calcMax(widget.avfData), Colors.blue)),
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
            child: _ecgPlot(widget.v1Data, _calcMin(widget.v1Data),
                _calcMax(widget.v1Data), Colors.blue)),
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
            child: _ecgPlot(widget.v2Data, _calcMin(widget.v2Data),
                _calcMax(widget.v2Data), Colors.blue)),
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
            child: _ecgPlot(widget.v3Data, _calcMin(widget.v3Data),
                _calcMax(widget.v3Data), Colors.blue)),
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
            child: _ecgPlot(widget.v4Data, _calcMin(widget.v4Data),
                _calcMax(widget.v4Data), Colors.blue)),
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
            child: _ecgPlot(widget.v5Data, _calcMin(widget.v5Data),
                _calcMax(widget.v5Data), Colors.blue)),
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
            child: _ecgPlot(widget.v6Data, _calcMin(widget.v6Data),
                _calcMax(widget.v6Data), Colors.blue)),
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
            "ECG History",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
        body: _plotsWithoutComparison());
  }
}
