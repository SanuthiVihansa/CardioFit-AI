import 'package:flutter/material.dart';

class ReportAnalysisScreen extends StatefulWidget {
  const ReportAnalysisScreen(this.extractedResult,{super.key});

  final List extractedResult;

  @override
  State<ReportAnalysisScreen> createState() => _ReportAnalysisScreenState();
}

class _ReportAnalysisScreenState extends State<ReportAnalysisScreen> {

  Widget _displayOutputTable() {
    return DataTable(
      columns: [
        DataColumn(label: Text('Component')),
        DataColumn(label: Text('Result')),
      ],
      rows: widget.extractedResult
          .map(
            (pair) => DataRow(
          cells: [
            DataCell(Text(pair.word)),      // Accessing word directly
            DataCell(Text(pair.nextWord)),  // Accessing nextWord directly
          ],
        ),
      )
          .toList(),
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.extractedResult.isNotEmpty
          ? _displayOutputTable()
          : Text("Hi"),

    );
  }
}







