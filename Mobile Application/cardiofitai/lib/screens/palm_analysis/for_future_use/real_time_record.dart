import 'dart:async';

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class RealTimeRecord extends StatefulWidget {
  const RealTimeRecord({super.key});

  @override
  State<RealTimeRecord> createState() => _RealTimeRecordState();
}

class _RealTimeRecordState extends State<RealTimeRecord> {
  int _countdown = 10;
  late Timer _timer;

  late TooltipBehavior _tooltipBehavior;

  @override
  void initState() {
    super.initState();
    startCountdown();
    _tooltipBehavior = TooltipBehavior(enable: true);
  }

  void switch_capturing() {
    // TODO
  }

  void startCountdown() {
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
      (Timer timer) {
        setState(() {
          if (_countdown < 1) {
            timer.cancel();
          } else {
            _countdown = _countdown - 1;
          }
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "CardioFit AI",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.red,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Real-time Lead II ECG Signal",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text("Remaining time: $_countdown s")
                ],
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
              child: Row(
                children: [
                  Image.asset(
                    "assets/palm_analysis/recording.gif",
                    scale: 15,
                  ),
                  const Text("Capturing")
                ],
              ),
            ),
            SfCartesianChart(
              primaryXAxis: CategoryAxis(),
              title: ChartTitle(text: "Lead II"),
              legend: Legend(isVisible: true),
              tooltipBehavior: _tooltipBehavior,
              // series: [],
            )
          ],
        ),
      ),
    );
  }
}
