import 'package:flutter/material.dart';
import '../../../models/user.dart';
import '../../../services/user_information_service.dart';
import '../../common/dashboard_screen.dart';
import '../../palm_analysis/for_pp2/electrode_placement_instructions_screen.dart';
import 'modiRecognitionScreen.dart';

class ReportAnalysisScreen extends StatefulWidget {
  ReportAnalysisScreen(
      // this._extractedResult,
      this._selectedReports,
      this.rows,
      this.user,
      {super.key});

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
    int triglycerides = 0;
    int wbc = 0;
    int neutrophils = 0;
    int lymphocytes = 0;
    int eosinophils = 0;
    int pusCells = 0;
    int redCells = 0;
    int protein = 0;
    int sugar = 0;
    int albumin = 0;

    for (List<DataRow> dataRows in rows) {
      for (DataRow row in dataRows) {
        String component =
            (row.cells[0].child as Text).data!.toLowerCase().trim();
        String result = (row.cells[1].child as Text).data!.toLowerCase().trim();

        RegExp regex = RegExp(r'\d+');
        RegExpMatch? match = regex.firstMatch(result);
        if (match != null) {
          String numericValue = match.group(0)!;
          result = numericValue;
        }

        int numericResult = int.tryParse(result) ?? 0;

        // Handle glucose levels
        if (component.contains("fasting plasma glucose")) {
          fastingPlasmaGlucose = numericResult;
        } else if (component.contains("fasting blood sugar")) {
          fastingBloodSugar = numericResult;
        } else if (component.contains("random plasma glucose")) {
          randomPlasmaGlucose = numericResult;
        } else if (component.contains("random blood sugar")) {
          randomBloodSugar = numericResult;
        }

        // Handle Lipid Profile
        else if (component.contains("total cholestrol")) {
          cholesterolTotal = numericResult;
        } else if (component.contains("ldl cholesterol")) {
          ldlC = numericResult;
        } else if (component.contains("hdl cholesterol")) {
          hdlC = numericResult;
        } else if (component.contains("triglycerides")) {
          triglycerides = numericResult;
        }

        // Handle Full Blood Count
        else if (component.contains("wbc")) {
          wbc = numericResult;
        } else if (component.contains("neutrophils")) {
          neutrophils = numericResult;
        } else if (component.contains("lymphocytes")) {
          lymphocytes = numericResult;
        } else if (component.contains("eosinophils")) {
          eosinophils = numericResult;
        }

        // Handle Urine Full Report
        else if (component.contains("pus cells")) {
          pusCells = numericResult;
        } else if (component.contains("red cells")) {
          redCells = numericResult;
        } else if (component.contains("protein")) {
          protein = numericResult;
        } else if (component.contains("Glucose")) {
          sugar = numericResult;
        } else if (component.contains("albumin")) {
          albumin = numericResult;
        }
      }
    }

    // Determine blood glucose level
    int bloodGlucoseLevel = randomPlasmaGlucose != 0
        ? randomPlasmaGlucose
        : (randomBloodSugar != 0
            ? randomBloodSugar
            : (fastingPlasmaGlucose != 0
                ? fastingPlasmaGlucose
                : fastingBloodSugar));

    // Update the user object with extracted information
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
        bloodGlucoseLevel != 0
            ? bloodGlucoseLevel.toString()
            : widget.user.bloodGlucoseLevel,
        cholesterolTotal != 0
            ? cholesterolTotal.toString()
            : widget.user.bloodCholestrolLevel,
        "No",
        "0",
        widget.user.memberName,
        widget.user.memberRelationship,
        widget.user.memberPhoneNo,
        widget.user.newUser,
        widget.user.gender);

    // Update the user information in the database
    updateUserInformation(updatedUser);

    // Diagnose based on extracted values
    List<String> diagnoses = [];

    // Diagnose Diabetes or Pre-Diabetes
    if (fastingPlasmaGlucose >= 126 ||
        fastingBloodSugar >= 126 ||
        randomPlasmaGlucose >= 200 ||
        randomBloodSugar >= 200) {
      diagnoses.add("Diagnosed with Diabetes Mellitus condition.");
    } else if ((fastingPlasmaGlucose >= 100 && fastingPlasmaGlucose <= 125) ||
        (fastingBloodSugar >= 100 && fastingBloodSugar <= 125) ||
        (randomPlasmaGlucose >= 140 && randomPlasmaGlucose <= 199) ||
        (randomBloodSugar >= 140 && randomBloodSugar <= 199)) {
      diagnoses.add("Diagnosed with Pre Diabetes condition.");
    }

    // Diagnose Dyslipidemia
    if (cholesterolTotal > 0) {
      if (cholesterolTotal >= 200) {
        diagnoses.add(cholesterolTotal >= 240
            ? "High Total Cholesterol indicates increased risk of heart disease due to excess cholesterol in the blood."
            : "Borderline High Total Cholesterol suggests you are approaching risky levels, and lifestyle changes may be needed.");
      } else {
        diagnoses.add(
            "Desirable Total Cholesterol means your blood cholesterol is within a healthy range, reducing the risk of heart disease.");
      }

      if (triglycerides >= 150) {
        if (triglycerides >= 500) {
          diagnoses.add(
              "Very High Triglycerides puts you at serious risk for pancreatitis and cardiovascular diseases due to extremely high fat levels.");
        } else if (triglycerides >= 200) {
          diagnoses.add(
              "High Triglycerides increases the risk of heart disease, indicating too much fat is circulating in your blood.");
        } else {
          diagnoses.add(
              "Borderline High Triglycerides means slightly elevated fat levels, which can increase risk for heart and liver diseases.");
        }
      } else {
        diagnoses.add(
            "Normal Triglycerides suggests that your fat levels in the blood are well-managed, reducing risks of heart disease.");
      }

      if (hdlC < 40) {
        diagnoses.add(
            "Low HDL Cholesterol means inadequate 'good' cholesterol, reducing the body's ability to remove excess fat from arteries.");
      } else if (hdlC >= 60) {
        diagnoses.add(
            "High HDL Cholesterol means your 'good' cholesterol is efficiently protecting against heart disease by clearing bad cholesterol.");
      }

      if (ldlC >= 100) {
        if (ldlC >= 190) {
          diagnoses.add(
              "Very High LDL Cholesterol signals a major risk for heart disease as too much 'bad' cholesterol clogs arteries.");
        } else if (ldlC >= 160) {
          diagnoses.add(
              "High LDL Cholesterol significantly increases your risk for heart attack and stroke due to excess cholesterol in the arteries.");
        } else if (ldlC >= 130) {
          diagnoses.add(
              "Borderline High LDL Cholesterol suggests that you're near the risk zone for heart problems, requiring dietary changes.");
        } else {
          diagnoses.add(
              "Near Optimal LDL Cholesterol means your 'bad' cholesterol levels are close to being ideal but could improve further.");
        }
      } else {
        diagnoses.add(
            "Optimal LDL Cholesterol indicates a healthy level of 'bad' cholesterol, minimizing your risk of developing heart disease.");
      }
    }

    // Diagnose Full Blood Count Issues
    if (wbc > 11000) {
      diagnoses.add("High WBC: Possible Infection or Inflammation");
    }
    if (neutrophils > 7000) {
      diagnoses.add("High Neutrophils: Possible Bacterial Infection");
    }
    if (lymphocytes > 4000) {
      diagnoses.add("High Lymphocytes: Possible Viral Infection");
    }
    if (eosinophils > 500) {
      diagnoses.add("High Eosinophils: Possible Allergic Response");
    }

    // Diagnose Urine Full Report Issues
    if (pusCells > 5) {
      diagnoses.add("High Pus Cells: Possible Urine Infection");
    }
    if (redCells > 3) {
      diagnoses.add(
          "High Red Cells: Possible Renal Disease, Urine Infection, Renal Calculi, or Cancer");
    }
    if (protein > 150) {
      diagnoses.add("High Protein: Possible Renal Disease");
    }
    if (sugar > 0) {
      diagnoses.add("High Sugar: Possible Diabetes");
    }
    if (albumin > 0) {
      diagnoses.add("High Albumin: Possible Renal Disease");
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
        leading: widget.user.newUser == false
            ? IconButton(
                color: Colors.white,
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context);
                },
              )
            : IconButton(
                color: Colors.red,
                icon: const Icon(Icons.arrow_back),
                onPressed: () {},
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
                SizedBox(
                  height: 50,
                ),
                if (widget.user.newUser)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 20.0, horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        OutlinedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      DashboardScreen(widget.user)),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.red, width: 2),
                            // Red border
                            backgroundColor: Colors.white,
                            // White background
                            padding: EdgeInsets.all(16), // Even padding
                          ),
                          child: Text(
                            "Skip",
                            style: TextStyle(color: Colors.black), // Black text
                          ),
                        ),
                        SizedBox(width: 20),
                        OutlinedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ElectrodePlacementInstructionsScreen(
                                        widget.user),
                              ),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.red, width: 2),
                            // Red border
                            backgroundColor: Colors.white,
                            // White background
                            padding: EdgeInsets.all(16), // Even padding
                          ),
                          child: Text(
                            "Next",
                            style: TextStyle(color: Colors.black), // Black text
                          ),
                        ),
                      ],
                    ),
                  ),
                SizedBox(
                  height: 80,
                ),
                ...widget.rows.map((e) {
                  findIndex += 1;
                  if (findIndex < widget._selectedReports.length) {
                    return Column(
                      children: [
                        Image.file(
                            widget._selectedReports[findIndex]["UploadedImage"],
                            width: 200,
                            height: 200),
                        Text(widget._selectedReports[findIndex]
                            ['UploadedReport']),
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
                    return SizedBox
                        .shrink(); // Safeguard against out-of-bound access
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
