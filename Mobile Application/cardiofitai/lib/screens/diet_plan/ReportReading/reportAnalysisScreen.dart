import 'package:flutter/material.dart';
import '../../../models/user.dart';
import '../../../services/user_information_service.dart';
import 'modiRecognitionScreen.dart';

class ReportAnalysisScreen extends StatefulWidget {
  ReportAnalysisScreen(
      // this._extractedResult,
      this._selectedReports, this.rows, this.user, {super.key});

  // final List<List<WordPair>> _extractedResult;
  final List<Map<String, dynamic>> _selectedReports;
  final List<List<DataRow>> rows;
  final User user;

  @override
  State<ReportAnalysisScreen> createState() => _ReportAnalysisScreenState();
}

class _ReportAnalysisScreenState extends State<ReportAnalysisScreen> {
  @override
  int findIndex = -1;

  String compareValues(List<List<DataRow>> rows) {
    int fastingPlasmaGlucose = 0;
    int randomPlasmaGlucose = 0;
    int randomBloodSugar = 0;
    int fastingBloodSugar = 0;
    int cholesterolTotal = 0;
    int ldlC = 0;
    int hdlC = 0;

    for (List<DataRow> dataRows in rows) {
      for (DataRow row in dataRows) {
        String component = (row.cells[0].child as Text).data!
            .toLowerCase()
            .trim();
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
        } else if (component.contains("random plasma glucose")) {
          randomPlasmaGlucose = numericResult;
        } else if (component.contains("random blood sugar")) {
          randomBloodSugar = numericResult;
        }
      }
    }

    int bloodGlucoseLevel = randomPlasmaGlucose != 0
        ? randomPlasmaGlucose
        : (randomBloodSugar != 0
        ? randomBloodSugar
        : (fastingPlasmaGlucose != 0
        ? fastingPlasmaGlucose
        : fastingBloodSugar));

    String cardiacCondition = ldlC > 150 || hdlC < 40 ? "Yes" : "No";

    User updatedUser = User(
      widget.user.name,
      widget.user.email,
      widget.user.password,
      widget.user.age,
      widget.user.height,
      widget.user.weight,
      widget.user.bmi,
      widget.user.dob,
      widget.user.activeLevel,
      widget.user.type,
      bloodGlucoseLevel != 0 ? bloodGlucoseLevel.toString() : widget.user.bloodGlucoseLevel,
      cholesterolTotal != 0 ? cholesterolTotal.toString() : widget.user.bloodCholestrolLevel,
      "No",
      "0",
      widget.user.memberName,
      widget.user.memberRelationship,
      widget.user.memberPhoneNo,
        widget.user.newUser

    );

    // Update the user information in the database
    updateUserInformation(updatedUser);

    List<String> diagnoses = [];

    if (fastingPlasmaGlucose >= 126 ||
        fastingBloodSugar >= 126 ||
        randomPlasmaGlucose > 200 ||
        randomBloodSugar > 200) {
      diagnoses.add("Diabetes Mellitus");
    } else if ((fastingPlasmaGlucose > 100 && fastingPlasmaGlucose < 125) ||
        (fastingBloodSugar > 100 && fastingBloodSugar < 125) ||
        (randomPlasmaGlucose > 140 && randomPlasmaGlucose < 199) ||
        (randomBloodSugar > 140 && randomBloodSugar < 199)) {
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

    if (diagnoses.isEmpty) {
      return "Normal: No defects identified";
    } else {
      return diagnoses.join(", ");
    }
  }


  void updateUserInformation(User updatedUser) async {
    await UserLoginService.updateUser(updatedUser);
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
                  if (findIndex < widget._selectedReports.length) {
                    return Column(
                      children: [
                        Image.file(widget._selectedReports[findIndex]["UploadedImage"], width: 200, height: 200),
                        Text(widget._selectedReports[findIndex]['UploadedReport']),
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
