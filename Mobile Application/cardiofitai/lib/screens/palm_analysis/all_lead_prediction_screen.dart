import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class AllLeadPredictionScreen extends StatefulWidget {
  const AllLeadPredictionScreen(this.l2Data, {super.key});

  final List l2Data;

  @override
  State<AllLeadPredictionScreen> createState() => _AllLeadPredictionScreenState();
}

class _AllLeadPredictionScreenState extends State<AllLeadPredictionScreen> {

  @override
  void initState() {
    super.initState();
  }

  Widget _ecgPlot(data, minValue, maxValue) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: LineChart(
        LineChartData(
          lineBarsData: [
            LineChartBarData(
              spots: List.generate(
                data.length,
                    (index) => FlSpot(index.toDouble(), data[index]),
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
          minY: minValue,
          // Adjust these values based on your data range
          maxY: maxValue,
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

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
