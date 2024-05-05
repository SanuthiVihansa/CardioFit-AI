import 'package:flutter/material.dart';

import 'modiRecognitionScreen.dart';

class ReportAnalysisScreen extends StatefulWidget {
  const ReportAnalysisScreen(this.extractedResult,this.addMultipleReports, {super.key});

  final List<List<WordPair>> extractedResult;
  final List<Map<String, dynamic>> addMultipleReports;


  @override
  State<ReportAnalysisScreen> createState() => _ReportAnalysisScreenState();
}

class _ReportAnalysisScreenState extends State<ReportAnalysisScreen> {
  int findIndex =0;
  // Widget _displayOutputTable() {
  //   for(int i=0; i <= widget.extractedResult.length; i++ ){
  //     return Center(
  //       child: DataTable(
  //         columns: [
  //           DataColumn(label: Text('Component')),
  //           DataColumn(label: Text('Result')),
  //         ],
  //         rows: widget.extractedResult.expand((item) {
  //           findIndex=findIndex+1;
  //           return item.map((pair) {
  //             return DataRow(
  //               cells: [
  //                 DataCell(Text(pair.word)), // Accessing word directly
  //                 DataCell(Text(pair.nextWord)), // Accessing nextWord directly
  //               ],
  //             );
  //           }
  //           );
  //         }).toList(),
  //       ),
  //     );
  //   }
  // }

  //working
  // Widget _displayOutputTable() {
  //   List<DataRow> rows = [];
  //
  //   // Loop through widget.extractedResult
  //   for (var item in widget.extractedResult) {
  //     rows.addAll(item.map((pair) {
  //       return DataRow(
  //         cells: [
  //           DataCell(Text(pair.word)), // Accessing word directly
  //           DataCell(Text(pair.nextWord)), // Accessing nextWord directly
  //         ],
  //       );
  //     }));
  //   }
  //
  //   // Building DataTable outside the loop
  //   DataTable dataTable = DataTable(
  //     columns: [
  //       DataColumn(label: Text('Component')),
  //       DataColumn(label: Text('Result')),
  //     ],
  //     rows: rows,
  //   );
  //
  //
  //   // Returning the DataTable
  //   return Center(
  //     child: dataTable,
  //   );
  // }
  Widget _displayOutputTable() {
    List<Widget> tableWidgets = [];
    // Loop through widget.extractedResult
    for (var item in widget.extractedResult) {
      List<DataRow> rows = item.map((pair) {
        return DataRow(
          cells: [
            DataCell(Text(pair.word)), // Accessing word directly
            DataCell(Text(pair.nextWord)), // Accessing nextWord directly
          ],
        );
      }).toList();

      // Add DataTable and Divider to tableWidgets list
      tableWidgets.add(Text(widget.addMultipleReports[findIndex]["UploadedReport"])); // Add a Divider after each DataTable
      findIndex+1;
      tableWidgets.add(
        DataTable(
          columns: [
            DataColumn(label: Text('Component')),
            DataColumn(label: Text('Result')),
          ],
          rows: rows,
        ),
      );
      tableWidgets.add(Text(reportDiagnosis(widget.addMultipleReports[findIndex],findIndex)));
      tableWidgets.add(Divider()); // Add a Divider after each DataTable
    }

    // Remove the last Divider
    if (tableWidgets.isNotEmpty) {
      tableWidgets.removeLast();
    }

    // Return the list of DataTables and Dividers
    return Center(
      child: Column(
        children: tableWidgets,
      ),
    );
  }


  String reportDiagnosis(Map<String, dynamic> item,int index) {
    List<WordPair> wordPairs = widget.extractedResult[index];
    String selectedReport = item["UploadedReport"];
    String diagnosis = "";

    if (selectedReport == "Full Blood Count Report") {
      if (wordPairs.any((pair) =>
      pair.word == "WBC" && (int.tryParse(pair.nextWord) ?? 0) > 10000)) {
        diagnosis = "You are facing an infection";
      } else if (wordPairs.any((pair) =>
      pair.word == "Neutrophils" &&
          (int.tryParse(pair.nextWord) ?? 0) > 80)) {
        diagnosis = "You are facing an Bacterial infection";
      } else if (wordPairs.any((pair) =>
      pair.word == "Lymphocytes" &&
          (int.tryParse(pair.nextWord) ?? 0) > 40)) {
        diagnosis = "You are facing a Viral Fever";
      } else if (wordPairs.any((pair) =>
      pair.word == "Eosinophils" &&
          (int.tryParse(pair.nextWord) ?? 0) > 6)) {
        diagnosis = "You are facing an Allergic reaction";
      } else if (wordPairs.any((pair) =>
      pair.word == "Platelet Count" &&
          (int.tryParse(pair.nextWord) ?? 0) < 150000)) {
        diagnosis =
        "Your platelet Count is very low, you could be suffering from\n▪️Viral Fever\n▪️Dengue\n▪️ITP\nIf the fever last for >3 days immediately go for doctor";
      } else {
        diagnosis = "No defect identified";
      }
    } else if (selectedReport == "Urine Full Report") {
      if (wordPairs.any((pair) =>
      pair.word == "Pus Cells" &&
          (int.tryParse(pair.nextWord) ?? 0) < 10)) {
        diagnosis = "You are facing an Urine infection";
      } else if (wordPairs.any((pair) =>
      pair.word == "Protein" && pair.nextWord.toLowerCase() != "nil")) {
        diagnosis = "You are facing a Renal disease";
      } else if (wordPairs.any((pair) =>
      pair.word == "Glucose" && pair.nextWord.toLowerCase() != "nil")) {
        diagnosis = "You have Diabetics";
      } else if (wordPairs.any((pair) =>
      pair.word == "Red Blood Cells" &&
          pair.nextWord.toLowerCase() != "occasional")) {
        diagnosis =
        "Your Red Blood Count is very high, you could be suffering from\n▪️Renal disease\n▪️Urine infection\n▪️Renal Culculy\n▪️Cancer\nIf the fever last for >3 days immediately go for doctor";
      } else {
        diagnosis = "No defect identified";
      }
    }

    return diagnosis;
  }



  // Widget _displayOutputTable() {
  //   List<Widget> tables = [];
  //
  //   for (int i = 0; i < widget.extractedResult.length; i++) {
  //     List<DataRow> rows = [];
  //     widget.extractedResult[i].forEach((pair) {
  //       rows.add(
  //         DataRow(
  //           cells: [
  //             DataCell(Text(pair.word)), // Accessing word directly
  //             DataCell(Text(pair.nextWord)), // Accessing nextWord directly
  //           ],
  //         ),
  //       );
  //     });
  //
  //     tables.add(
  //       Center(
  //         child: DataTable(
  //           columns: [
  //             DataColumn(label: Text('Component')),
  //             DataColumn(label: Text('Result')),
  //           ],
  //           rows: rows,
  //         ),
  //       ),
  //     );
  //   }
  //   print("Tables length: ${tables.length}");
  //   return tables[findIndex % tables.length];
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