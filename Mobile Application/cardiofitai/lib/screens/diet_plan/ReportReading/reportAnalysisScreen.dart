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
  // String compareValues(List<List<DataRow>> rows) {
  //   for (List<DataRow> dataRows in rows) {
  //     for (DataRow row in dataRows) {
  //       String Component = row.cells[0].child.toString();
  //       String Result = row.cells[1].child.toString();
  //       RegExp regex = RegExp(r'\d+');
  //       RegExpMatch? match = regex.firstMatch(Result);
  //       if (match != null) {
  //         String numericValue = match.group(0)!;
  //         Result = numericValue;
  //       }
  //       //String Unit = row.cells[2].child.toString();
  //
  //       if (Component.toLowerCase() == "text(\"fasting plasma glucose\")") {
  //         if (int.tryParse(Result) != null) {
  //           int numericResult = int.parse(Result);
  //           if (numericResult >= 126) {
  //             return "Diabetes Mellitus";
  //           } else if (numericResult > 100 && numericResult < 125) {
  //             return "Pre Diabetes";
  //           }
  //         }
  //       } else if (Component.toLowerCase() == "fasting blood sugar") {
  //         if (int.tryParse(Result) != null) {
  //           int numericResult = int.parse(Result);
  //           if (numericResult > 126) {
  //             return "Diabetes Mellitus";
  //           } else if (numericResult > 100 && numericResult < 125) {
  //             return "Pre Diabetes";
  //           }
  //         }
  //       } else if (Component.toLowerCase() == "text(\"cholesterol-total\")") {
  //         if (int.tryParse(Result) != null) {
  //           int numericResult = int.parse(Result);
  //           if (numericResult > 180) {
  //             return "High Cholestrol";
  //           }
  //         }
  //       } else if (Component.toLowerCase() == "text(\"ldl-c\")") {
  //         if (int.tryParse(Result) != null) {
  //           int numericResult = int.parse(Result);
  //           if (numericResult > 150) {
  //             return "LDL : High - Heart Disease Risk";
  //           }
  //         }
  //       } else if (Component.toLowerCase() == "text(\"hdl-c\")") {
  //         if (int.tryParse(Result) != null) {
  //           int numericResult = int.parse(Result);
  //           if (numericResult < 40) {
  //             return "HDL : Low - Heart Disease Risk";
  //           } else if (numericResult >= 60) {
  //             return "HDL : High";
  //           }
  //         }
  //       }
  //     }
  //   }
  //   return "Normal : No defects identified";
  // }
  String compareValues(List<List<DataRow>> rows) {
    int fastingPlasmaGlucose = 0;
    int fastingBloodSugar = 0;
    int cholesterolTotal = 0;
    int ldlC = 0;
    int hdlC = 0;

    for (List<DataRow> dataRows in rows) {
      for (DataRow row in dataRows) {
        String component = (row.cells[0].child as Text).data!.toLowerCase().trim();
        String result = (row.cells[1].child as Text).data!.toLowerCase().trim();

        RegExp regex = RegExp(r'\d+');
        RegExpMatch? match = regex.firstMatch(result);
        if (match != null) {
          String numericValue = match.group(0)!;
          result = numericValue;
        }

        int numericResult = int.tryParse(result) ?? 0;

        if (component.contains("fasting plasma glucose")) {
          fastingPlasmaGlucose = numericResult;
        } else if (component.contains("fasting blood sugar")) {
          fastingBloodSugar = numericResult;
        } else if (component.contains("cholesterol-total")) {
          cholesterolTotal = numericResult;
        } else if (component.contains("ldl-c")) {
          ldlC = numericResult;
        } else if (component.contains("hdl-c")) {
          hdlC = numericResult;
        }
      }
    }

    // Constructing the overall diagnosis
    List<String> diagnoses = [];

    if (fastingPlasmaGlucose >= 126 || fastingBloodSugar > 126) {
      diagnoses.add("Diabetes Mellitus");
    } else if ((fastingPlasmaGlucose > 100 && fastingPlasmaGlucose < 125) ||
        (fastingBloodSugar > 100 && fastingBloodSugar < 125)) {
      diagnoses.add("Pre Diabetes");
    }

    if (cholesterolTotal > 180) {
      diagnoses.add("High Cholesterol");
    }

    if (ldlC > 150) {
      diagnoses.add("LDL: High - Heart Disease Risk");
    }

    if (hdlC < 40) {
      diagnoses.add("HDL: Low - Heart Disease Risk");
    } else if (hdlC >= 60) {
      diagnoses.add("HDL: High");
    }

    if (diagnoses.isEmpty) {  // Corrected to use isEmpty without parentheses
      return "Normal: No defects identified";
    } else {
      return diagnoses.join(", ");
    }
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
                  findIndex += 1;
                  if (findIndex < widget.addMultipleReports.length) {
                    return Column(
                      children: [
                        Image.file(widget.addMultipleReports[findIndex]["UploadedImage"], width: 200, height: 200),
                        Text(widget.addMultipleReports[findIndex]['UploadedReport']),
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
                  } else {
                    return SizedBox.shrink(); // Safeguard against out-of-bound access
                  }
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
