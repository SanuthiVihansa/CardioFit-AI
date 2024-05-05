import 'package:flutter/material.dart';

import 'modiRecognitionScreen.dart';

class ReportAnalysisScreen extends StatefulWidget {
  const ReportAnalysisScreen(this.extractedResult, {super.key});

  final List<List<WordPair>> extractedResult;

  @override
  State<ReportAnalysisScreen> createState() => _ReportAnalysisScreenState();
}

class _ReportAnalysisScreenState extends State<ReportAnalysisScreen> {
  Widget _displayOutputTable() {
    return Center(
      child: DataTable(
        columns: [
          DataColumn(label: Text('Component')),
          DataColumn(label: Text('Result')),
        ],
        rows: widget.extractedResult.expand((item) {
          return item.map((pair) {
            return DataRow(
              cells: [
                DataCell(Text(pair.word)), // Accessing word directly
                DataCell(Text(pair.nextWord)), // Accessing nextWord directly
              ],
            );
          });
        }).toList(),
      ),
    );
  }
      // rows: widget.extractedResult[0]
      //     .map(
      //       (pair) => DataRow(
      //         cells: [
      //           DataCell(Text(pair.word)), // Accessing word directly
      //           DataCell(Text(pair.nextWord)), // Accessing nextWord directly
      //         ],
      //       ),
      //     )
      //     .toList(),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          color: Colors.white,
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          "CardioFit AI",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.red,
      ),
      body: SingleChildScrollView(
        child: widget.extractedResult.isNotEmpty
            ? _displayOutputTable()
            : Text("Hi"),
      ),
    );
  }
}
