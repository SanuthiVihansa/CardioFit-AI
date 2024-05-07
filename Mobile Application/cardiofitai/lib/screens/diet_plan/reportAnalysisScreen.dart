import 'package:flutter/material.dart';

import 'modiRecognitionScreen.dart';

class ReportAnalysisScreen extends StatefulWidget {
  ReportAnalysisScreen(this.extractedResult, this.addMultipleReports, this.rows,
      {super.key});

  final List<List<WordPair>> extractedResult;
  final List<Map<String, dynamic>> addMultipleReports;
  final List<List<DataRow>> rows;

  @override
  State<ReportAnalysisScreen> createState() => _ReportAnalysisScreenState();
}

class _ReportAnalysisScreenState extends State<ReportAnalysisScreen> {
  int findIndex = -1;
  String compareValues(List<List<DataRow>> rows) {
    for (List<DataRow> dataRows in rows) {
      for (DataRow row in dataRows) {
        String Component = row.cells[0].child.toString();
        String Result = row.cells[1].child.toString();
        //String Unit = row.cells[2].child.toString();

        if (Component.toLowerCase() == "fasting plasma glucose") {
          if (int.tryParse(Result) != null) {
            int numericResult = int.parse(Result);
            if (numericResult >= 126) {
              return "Diabetes Mellitus";
            } else if (numericResult > 100 && numericResult < 125) {
              return "Pre Diabetes";
            }
          }
        } else if (Component.toLowerCase() == "fasting blood sugar") {
          if (int.tryParse(Result) != null) {
            int numericResult = int.parse(Result);
            if (numericResult > 126) {
              return "Diabetes Mellitus";
            } else if (numericResult > 100 && numericResult < 125) {
              return "Pre Diabetes";
            }
          }
        } else if (Component.toLowerCase() == "Cholestrol-Total") {
          if (int.tryParse(Result) != null) {
            int numericResult = int.parse(Result);
            if (numericResult > 180) {
              return "High Cholestrol";
            }
          }
        } else if (Component.toLowerCase() == "LDL-C") {
          if (int.tryParse(Result) != null) {
            int numericResult = int.parse(Result);
            if (numericResult > 150) {
              return "LDL : High - Heart Disease Risk";
            }
          }
        } else if (Component.toLowerCase() == "HDL-C") {
          if (int.tryParse(Result) != null) {
            int numericResult = int.parse(Result);
            if (numericResult < 40) {
              return "HDL : Low - Heart Disease Risk";
            } else if (numericResult >= 60) {
              return "HDL : High";
            }
          }
        }
      }
    }
    return "Normal : No defects identified";
  }

  @override
  Widget build(BuildContext context) {
    String overallDiagnosis = compareValues(widget.rows);
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
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Column(
              children: [
                ...widget.rows.map((e) {
                  findIndex=findIndex+1;
                  return Column(
                    children: [
                      Image.file(widget.addMultipleReports[findIndex]["UploadedImage"], width: 200, height: 200),
                      Text(widget.addMultipleReports[findIndex]['UploadedReport']),
                      //Text(widget.addMultipleReports[findIndex]['UploadedReport']),
                      DataTable(
                        columns: const [
                          DataColumn(label: Text('Component')),
                          DataColumn(label: Text('Result')),
                          DataColumn(label: Text('Unit')),
                        ],
                        rows: e,
                      ),
                    ],
                  );
                }).toList(),
                SizedBox(height: 20),
                Text(
                  "Overall Diagnosis: $overallDiagnosis",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// body:SingleChildScrollView(
//   scrollDirection: Axis.horizontal,
//   child: SingleChildScrollView(
//     child: SizedBox(
//       width: MediaQuery.of(context).size.width,
//       child: Column(
//         children:
//         widget.rows.map((e) => DataTable(
//           columns: const [
//             DataColumn(label: Text('Component')),
//             DataColumn(label: Text('Result')),
//             DataColumn(label: Text('Unit')),
//           ],
//           rows:e,
//         )).toList(),
//       ),
//     ),
//   ),
// ),

//SingleChildScrollView(
//   child: widget.extractedResult.isNotEmpty
//       ? Text("")
//       : Text("Hi"),
// ),
//     );
//   }
// }
