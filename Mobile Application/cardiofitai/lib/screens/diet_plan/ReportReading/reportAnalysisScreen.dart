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
    int fastingBloodSugar = 0;
    int randomPlasmaGlucose=0;
    int randomBloodSugar=0;
    int cholesterolTotal = 0;
    int ldlC = 0;
    int hdlC = 0;
    int triglycerides = 0;
    int wbc = 0;


    int plateletCount = 0;


    print("Extracted data: $rows");

    for (List<DataRow> dataRows in rows) {
      for (DataRow row in dataRows) {
        String component = (row.cells[0].child as Text).data!.toLowerCase().trim();
        String result = (row.cells[1].child as Text).data!.toLowerCase().trim();

        RegExp regex = RegExp(r'\d+\.?\d*');
        RegExpMatch? match = regex.firstMatch(result);
        if (match != null) {
          result = match.group(0)!;
        }

        int numericResult = int.tryParse(result) ?? 0;

        // Handle glucose levels
        if (component.contains("fasting plasma glucose")) {
          fastingPlasmaGlucose = numericResult;
        } else if (component.contains("fasting blood sugar")) {
          fastingBloodSugar = numericResult;
        }else if(component.contains("random plasma glucose")){
          randomPlasmaGlucose = numericResult;
        }else if(component.contains("random blood sugar")){
          randomBloodSugar=numericResult;
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
        }  else if (component.contains("platelet count")) {
          plateletCount = numericResult;
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
    bloodGlucoseLevel = fastingPlasmaGlucose != 0 ? fastingPlasmaGlucose : fastingBloodSugar;
    if (bloodGlucoseLevel >= 126) {
      diagnoses.add("Diagnosed with Diabetes Mellitus condition.");
    } else if (bloodGlucoseLevel >= 100 && bloodGlucoseLevel <= 125) {
      diagnoses.add("Diagnosed with Pre Diabetes condition.");
    }

    // Diagnose Dyslipidemia
    if (cholesterolTotal > 0) {
      if (cholesterolTotal >= 200) {
        diagnoses.add(cholesterolTotal >= 240
            ? "High Total Cholesterol indicates increased risk of heart disease."
            : "Borderline High Total Cholesterol, lifestyle changes may be needed.");
      } else {
        diagnoses.add("Desirable Total Cholesterol: Your blood cholesterol is within a healthy range.");
      }

      if (triglycerides != 0) {
        if (triglycerides >= 150) {
          diagnoses.add(triglycerides >= 500
              ? "Very High Triglycerides: Risk of pancreatitis and cardiovascular diseases."
              : triglycerides >= 200
              ? "High Triglycerides: Risk of heart disease due to high fat levels."
              : "Borderline High Triglycerides: Slightly elevated fat levels, increasing risks for heart and liver diseases.");
        } else {
          diagnoses.add("Normal Triglycerides: Fat levels in your blood are well-managed.");
        }
      }

      if(hdlC !=0){
      if (hdlC < 40) {
        diagnoses.add("Low HDL Cholesterol: Insufficient 'good' cholesterol.");
      } else if (hdlC >= 60) {
        diagnoses.add("High HDL Cholesterol: 'Good' cholesterol is protecting against heart disease.");
      }}

      if(ldlC !=0){
      if (ldlC >= 100) {
        diagnoses.add(ldlC >= 190
            ? "Very High LDL Cholesterol: Significant risk for heart disease."
            : ldlC >= 160
            ? "High LDL Cholesterol: Increased risk for heart disease."
            : ldlC >= 130
            ? "Borderline High LDL Cholesterol: Approaching risky levels."
            : "Near Optimal LDL Cholesterol.");
      } else {
        diagnoses.add("Optimal LDL Cholesterol.");
      }
    }}

    // Diagnose Full Blood Count Issues
    if(wbc!=0){
    if (wbc > 11000) {
      diagnoses.add("High WBC: Possible Infection or Inflammation.");
    } else if (wbc < 4000) {
      diagnoses.add("Low WBC: Possible Autoimmune Disease or Bone Marrow Issue.");
    }}


    if(plateletCount!=0){
    if (plateletCount < 150000) {
      diagnoses.add("Low Platelet Count: Risk of Bleeding Disorder.");
    } else if (plateletCount > 450000) {
      diagnoses.add("High Platelet Count: Chronic Inflammation or Cancer Risk.");
    }}

    // Return the final diagnosis as a concatenated string
    return diagnoses.isNotEmpty ? diagnoses.join(", ") : "Normal: No defects identified.";
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
