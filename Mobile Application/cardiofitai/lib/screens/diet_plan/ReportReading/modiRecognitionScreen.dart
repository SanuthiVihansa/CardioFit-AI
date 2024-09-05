import 'dart:convert';
import 'dart:io';
import 'package:cardiofitai/components/navigation_panel_component.dart';
import 'package:cardiofitai/models/user.dart';
import 'package:cardiofitai/screens/common/dashboard_screen.dart';
import 'package:cardiofitai/screens/diet_plan/ReportReading/reportAnalysisScreen.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import '../../../models/response.dart';
import '../../../services/user_information_service.dart';

class RecognitionScreen extends StatefulWidget {
  const RecognitionScreen(this.user, {super.key});

  final User user;

  @override
  State<RecognitionScreen> createState() => _RecognitionScreenState();
}

class _RecognitionScreenState extends State<RecognitionScreen> {
  File? pickedImage;
  XFile? image;
  late double halfScreenWidth;
  String? _selectedReport = 'Select Report';
  late List<Map<String, dynamic>> _selectedReports = [];
  List<DataRow> _rows = [];
  List<List<DataRow>> _reportDataRows = [];
  List<File> _pickedImages = [];
  bool _isLoading = false;

  //Drop down control values
  List<String> reports = [
    'Select Report',
    'Fasting blood Sugar',
    'Urine Full Report',
    'Lipid profile',
    'Full Blood Count Report'
  ];

  Widget _multipleAttachmentControl() {
    return Container(
      height: 300,
      width: 500,
      margin: const EdgeInsets.only(right: 20, bottom: 10),
      child: Material(
        borderRadius: BorderRadius.all(Radius.circular(20)),
        //color: Colors.white54,
        //elevation: 4,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              height: 80,
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  width: 250,
                  decoration: BoxDecoration(
                    border:
                        Border.all(color: Colors.deepOrangeAccent, width: 2.0),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: DropdownButton<String>(
                    value: _selectedReport,
                    elevation: 16,
                    style: const TextStyle(color: Colors.blueGrey),
                    alignment: Alignment.topLeft,
                    underline: SizedBox(),
                    // Remove the underline
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedReport = newValue;
                        });
                      }
                    },
                    items:
                        reports.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Center(
                          child: Text(value, textAlign: TextAlign.start),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Flexible(
                  child: ElevatedButton(
                    onPressed: () async {
                      final image = await ImagePicker()
                          .pickImage(source: ImageSource.gallery);
                      if (image != null) {
                        File pickedImage = File(image.path);
                        if (pickedImage.path.isNotEmpty &&
                            _selectedReport != 'Select Report') {
                          _selectedReports.add({
                            "UploadedReport": _selectedReport,
                            "UploadedImage": pickedImage,
                            "ScannedItems": "",
                            "ExtractedText": "",
                            "obtainedRows": _rows,
                          });
                          _pickedImages
                              .add(pickedImage); // Add image to the list
                          setState(() {});
                        }
                      }
                    },
                    child: Text("Attach"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _showAttachedItems() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 108.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              'Uploaded Report Files', // Your header text here
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
          SizedBox(height: 10), // Add space between header and table
          DataTable(
            columnSpacing: 50,
            dataRowHeight: 70,
            columns: [
              DataColumn(label: Text('Report')),
              DataColumn(label: Text('Report Type')),
              DataColumn(label: Text('Action')),
            ],
            rows: _selectedReports.map((e) {
              return DataRow(cells: [
                DataCell(
                  Image.file(e["UploadedImage"], width: 50, height: 50),
                ),
                DataCell(
                  Text(e["UploadedReport"]),
                ),
                DataCell(
                  GestureDetector(
                    child: Icon(Icons.restore_from_trash_outlined),
                    onTap: () {
                      _removeItem(e);
                    },
                  ),
                ),
              ]);
            }).toList(),
          ),
        ],
      ),
    );
  }

  //Remove confirmation widget
  void _removeItem(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm'),
          content: Text('Are you sure you want to remove this item?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _selectedReports.remove(item);
                  _pickedImages.remove(
                      item["UploadedImage"]); // Remove image from the list
                });
                Navigator.of(context).pop();
              },
              child: Text('Remove'),
            ),
          ],
        );
      },
    );
  }

  void _onTapAnalyseBtn() async {
    setState(() {
      _isLoading = true;
    });
    _reportDataRows = [];
    if (_pickedImages.isNotEmpty) {
      for (int i = 0; i < _pickedImages.length; i++) {
        List<DataRow> _singleReportDataRows = [];
        if (_selectedReports[i]["UploadedReport"] == "Fasting blood Sugar") {
          var request = http.MultipartRequest(
              "POST",
              Uri.parse(
                  "https://sanuthivihansa.pythonanywhere.com/glucose/extract-text"));
          request.files.add(
              await http.MultipartFile.fromPath('file', _pickedImages[i].path));
          final response = await request.send();
          if (response.statusCode == 200) {
            final responseData = await http.Response.fromStream(response);
            final Map<String, dynamic> responseJson =
                json.decode(responseData.body);

            if (responseJson["extracted_text"]["Fasting Blood Sugar value?"] ==
                null) {
              _singleReportDataRows.add(DataRow(cells: [
                DataCell(Text("Fasting Plasma Glucose")),
                DataCell(Text(responseJson["extracted_text"]
                    ["Fasting Plasma Glucose value?"])),
                DataCell(Text(responseJson["extracted_text"]
                    ["Fasting Plasma Glucose unit?"]))
              ]));
            } else {
              _singleReportDataRows.add(DataRow(cells: [
                const DataCell(Text("Fasting Blood Sugar")),
                DataCell(Text(responseJson["extracted_text"]
                    ["Fasting Blood Sugar value?"])),
                DataCell(Text(responseJson["extracted_text"]
                    ["Fasting Blood Sugar unit?"]))
              ]));
            }
            _reportDataRows.add(_singleReportDataRows);
          }
        } else if (_selectedReports[i]["UploadedReport"] ==
            "Urine Full Report") {
          var request = http.MultipartRequest(
              "POST",
              Uri.parse(
                  "https://sanuthivihansa.pythonanywhere.com/urine/extract-text"));
          request.files.add(
              await http.MultipartFile.fromPath('file', _pickedImages[i].path));
          final response = await request.send();
          if (response.statusCode == 200) {
            final responseData = await http.Response.fromStream(response);
            Map<String, dynamic> responseJson = json.decode(responseData.body);
            responseJson = responseJson["extracted_text"];

            _singleReportDataRows.add(DataRow(cells: [
              DataCell(Text("Appearance")),
              DataCell(Text(responseJson["Appearance result?"].toString())),
              DataCell(Text(""))
            ]));
            _singleReportDataRows.add(DataRow(cells: [
              DataCell(Text("Bacteria")),
              DataCell(Text(responseJson["Bacteria result?"].toString())),
              DataCell(Text(responseJson["Bacteria unit?"].toString()))
            ]));
            _singleReportDataRows.add(DataRow(cells: [
              DataCell(Text("Bilirubin")),
              DataCell(Text(responseJson["Bilirubin result?"].toString())),
              DataCell(Text(""))
            ]));
            _singleReportDataRows.add(DataRow(cells: [
              DataCell(Text("Blood")),
              DataCell(Text(responseJson["Blood result?"].toString())),
              DataCell(Text(""))
            ]));
            _singleReportDataRows.add(DataRow(cells: [
              DataCell(Text("Color")),
              DataCell(Text(responseJson["Color result?"].toString())),
              DataCell(Text(""))
            ]));
            _singleReportDataRows.add(DataRow(cells: [
              DataCell(Text("Epithelial cells")),
              DataCell(
                  Text(responseJson["Epithelial cells result?"].toString())),
              DataCell(Text(responseJson["Epithelial cells units"].toString()))
            ]));
            _singleReportDataRows.add(DataRow(cells: [
              DataCell(Text("Specific Gravity")),
              DataCell(
                  Text(responseJson["Specific Gravity result?"].toString())),
              DataCell(Text(""))
            ]));
            _singleReportDataRows.add(DataRow(cells: [
              DataCell(Text("pH")),
              DataCell(Text(responseJson["pH result"].toString())),
              DataCell(Text(""))
            ]));
            _singleReportDataRows.add(DataRow(cells: [
              DataCell(Text("Protein")),
              DataCell(Text(responseJson["Protein result?"].toString())),
              DataCell(Text(""))
            ]));
            _singleReportDataRows.add(DataRow(cells: [
              DataCell(Text("Glucose-Urine ")),
              DataCell(Text(responseJson["Glucose-Urine result?"].toString())),
              DataCell(Text(""))
            ]));
            _singleReportDataRows.add(DataRow(cells: [
              DataCell(Text("Ketone bodies")),
              DataCell(Text(responseJson["Ketone bodies result?"].toString())),
              DataCell(Text(""))
            ]));
            _singleReportDataRows.add(DataRow(cells: [
              DataCell(Text("Urobilinogen")),
              DataCell(Text(responseJson["Urobilinogen result"].toString())),
              DataCell(Text(""))
            ]));
            _singleReportDataRows.add(DataRow(cells: [
              DataCell(Text("Nitrite")),
              DataCell(Text(responseJson["Nitrite result"].toString())),
              DataCell(Text(""))
            ]));
            _singleReportDataRows.add(DataRow(cells: [
              DataCell(Text("Leucocyte test")),
              DataCell(Text(responseJson["Leucocyte test result"].toString())),
              DataCell(Text(""))
            ]));
            _singleReportDataRows.add(DataRow(cells: [
              DataCell(Text("White Blood Cells")),
              DataCell(
                  Text(responseJson["White Blood Cells result?"].toString())),
              DataCell(
                  Text(responseJson["White Blood Cells units?"].toString()))
            ]));
            _singleReportDataRows.add(DataRow(cells: [
              DataCell(Text("Red Blood Cells")),
              DataCell(
                  Text(responseJson["Red Blood Cells result?"].toString())),
              DataCell(Text(responseJson["Red Blood Cells units?"].toString()))
            ]));
            _singleReportDataRows.add(DataRow(cells: [
              DataCell(Text("Bacteria")),
              DataCell(Text(responseJson["Bacteria result?"].toString())),
              DataCell(Text(responseJson["Bacteria unit?"].toString()))
            ]));
            _singleReportDataRows.add(DataRow(cells: [
              DataCell(Text("casts")),
              DataCell(Text(responseJson["casts result?"].toString())),
              DataCell(Text(responseJson["casts unit?"].toString()))
            ]));
            _singleReportDataRows.add(DataRow(cells: [
              DataCell(Text("crystals")),
              DataCell(Text(responseJson["crystals results?"].toString())),
              DataCell(Text(responseJson["crystals units?"].toString()))
            ]));
            _singleReportDataRows.add(DataRow(cells: [
              DataCell(Text("Other")),
              DataCell(Text(responseJson["other results?"].toString())),
              DataCell(Text(responseJson["other units?"].toString()))
            ]));

            _reportDataRows.add(_singleReportDataRows);
          }
        } else if (_selectedReports[i]["UploadedReport"] == "Lipid profile") {
          var request = http.MultipartRequest(
              "POST",
              Uri.parse(
                  "https://sanuthivihansa.pythonanywhere.com/lipid/extract-text"));
          request.files.add(
              await http.MultipartFile.fromPath('file', _pickedImages[i].path));
          final response = await request.send();
          if (response.statusCode == 200) {
            final responseData = await http.Response.fromStream(response);
            Map<String, dynamic> responseJson = json.decode(responseData.body);
            responseJson = responseJson["extracted_text"];

            _singleReportDataRows.add(DataRow(cells: [
              DataCell(Text("Total Cholestrol")),
              DataCell(Text(responseJson["Total Cholestrol?"].toString())),
              DataCell(Text(responseJson["Total Cholestrol Result"].toString()))
            ]));
            _singleReportDataRows.add(DataRow(cells: [
              DataCell(Text("Triglycerides")),
              DataCell(Text(responseJson["Triglycerides?"].toString())),
              DataCell(Text(responseJson["Triglycerides Result"].toString()))
            ]));
            _singleReportDataRows.add(DataRow(cells: [
              DataCell(Text("HDL Cholesterol")),
              DataCell(Text(responseJson["HDL Cholesterol?"].toString())),
              DataCell(Text(responseJson["HDL Cholesterol Result"].toString()))
            ]));
            _singleReportDataRows.add(DataRow(cells: [
              DataCell(Text("LDL Cholesterol")),
              DataCell(Text(responseJson["LDL Cholesterol?"].toString())),
              DataCell(Text(responseJson["LDL Cholesterol Result"].toString()))
            ]));
            _singleReportDataRows.add(DataRow(cells: [
              DataCell(Text("VLDL")),
              DataCell(Text(responseJson["VLDL?"].toString())),
              DataCell(Text(responseJson["VLDL Result?"].toString()))
            ]));
            _singleReportDataRows.add(DataRow(cells: [
              DataCell(Text("CHOL/HDLC")),
              DataCell(Text(responseJson["CHOL/HDLC?"].toString())),
              DataCell(Text(responseJson["CHOL/HDLC Result"].toString()))
            ]));
            _singleReportDataRows.add(DataRow(cells: [
              DataCell(Text("Non HDL Cholestrol")),
              DataCell(Text(responseJson["Non HDL Cholestrol?"].toString())),
              DataCell(Text(responseJson["Non HDL Cholestrol unit"].toString()))
            ]));

            _reportDataRows.add(_singleReportDataRows);
          }
        } else if (_selectedReports[i]["UploadedReport"] ==
            "Full Blood Count Report") {
          var request = http.MultipartRequest(
              "POST",
              Uri.parse(
                  "https://sanuthivihansa.pythonanywhere.com/fbc/extract-text"));
          request.files.add(
              await http.MultipartFile.fromPath('file', _pickedImages[i].path));
          final response = await request.send();
          if (response.statusCode == 200) {
            final responseData = await http.Response.fromStream(response);
            Map<String, dynamic> responseJson = json.decode(responseData.body);
            responseJson = responseJson["extracted_text"];
            _singleReportDataRows.add(DataRow(cells: [
              DataCell(Text("WBC")),
              DataCell(Text(responseJson["WBC?"].toString())),
              DataCell(Text(""))
            ]));
            _singleReportDataRows.add(DataRow(cells: [
              DataCell(Text("Neutrophils")),
              DataCell(Text(responseJson["Neutrophils"].toString())),
              DataCell(Text(""))
            ]));
            _singleReportDataRows.add(DataRow(cells: [
              DataCell(Text("Lymphocytes")),
              DataCell(Text(responseJson["Lymphocytes?"].toString())),
              DataCell(Text(""))
            ]));
            _singleReportDataRows.add(DataRow(cells: [
              DataCell(Text("Eosinophils")),
              DataCell(Text(responseJson["Eosinophils"].toString())),
              DataCell(Text(""))
            ]));
            _singleReportDataRows.add(DataRow(cells: [
              DataCell(Text("Monocytes")),
              DataCell(Text(responseJson["Monocytes?"].toString())),
              DataCell(Text(""))
            ]));
            _singleReportDataRows.add(DataRow(cells: [
              DataCell(Text("Basophils")),
              DataCell(Text(responseJson["Basophils"].toString())),
              DataCell(Text(""))
            ]));
            _singleReportDataRows.add(DataRow(cells: [
              DataCell(Text("Haemoglobin")),
              DataCell(Text(responseJson["Haemoglobin?"].toString())),
              DataCell(Text(""))
            ]));
            _singleReportDataRows.add(DataRow(cells: [
              DataCell(Text("PCV")),
              DataCell(Text(responseJson["PCV?"].toString())),
              DataCell(Text(""))
            ]));
            _singleReportDataRows.add(DataRow(cells: [
              DataCell(Text("MCHC")),
              DataCell(Text(responseJson["MCHC?"].toString())),
              DataCell(Text(""))
            ]));
            _singleReportDataRows.add(DataRow(cells: [
              DataCell(Text("RBC")),
              DataCell(Text(responseJson["RBC?"].toString())),
              DataCell(Text(""))
            ]));
            _singleReportDataRows.add(DataRow(cells: [
              DataCell(Text("MCH")),
              DataCell(Text(responseJson["MCH?"].toString())),
              DataCell(Text(""))
            ]));
            _singleReportDataRows.add(DataRow(cells: [
              DataCell(Text("MCV")),
              DataCell(Text(responseJson["MCV?"].toString())),
              DataCell(Text(""))
            ]));
            _singleReportDataRows.add(DataRow(cells: [
              DataCell(Text("Neutrophils absolute count")),
              DataCell(
                  Text(responseJson["Neutrophils absolute count?"].toString())),
              DataCell(Text(""))
            ]));
            _singleReportDataRows.add(DataRow(cells: [
              DataCell(Text("Lymphocytes absolute count")),
              DataCell(
                  Text(responseJson["Lymphocytes absolute count?"].toString())),
              DataCell(Text(""))
            ]));
            _singleReportDataRows.add(DataRow(cells: [
              DataCell(Text("Eosinophil absolute count")),
              DataCell(
                  Text(responseJson["Eosinophil absolute count?"].toString())),
              DataCell(Text(""))
            ]));
            _singleReportDataRows.add(DataRow(cells: [
              DataCell(Text("Monocytes absolute count")),
              DataCell(
                  Text(responseJson["Monocytes absolute count?"].toString())),
              DataCell(Text(""))
            ]));
            _singleReportDataRows.add(DataRow(cells: [
              DataCell(Text("Basophils absolute count")),
              DataCell(
                  Text(responseJson["Basophils absolute count?"].toString())),
              DataCell(Text(""))
            ]));
            _singleReportDataRows.add(DataRow(cells: [
              DataCell(Text("Platelet count")),
              DataCell(Text(responseJson["Platelet count?"].toString())),
              DataCell(Text(""))
            ]));
// Set validations here
            _reportDataRows.add(_singleReportDataRows);
          }
        }
      }
    }
    setState(() {
      _isLoading = false;
    });

    Navigator.of(context).push(MaterialPageRoute(
        builder: (BuildContext context) => ReportAnalysisScreen(
            _selectedReports, _reportDataRows, widget.user)));
  }

  @override
  Widget build(BuildContext context) {
    halfScreenWidth = (MediaQuery.of(context).size.width - 10) - 50;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Laboratory Report Diagnosis",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.red,
      ),
      body: Row(
        children: [
          NavigationPanelComponent("reports", widget.user),
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                alignment: Alignment.center,
                child: Column(
                  children: [
                    SizedBox(
                      height: 55 + MediaQuery.of(context).viewInsets.top,
                    ),
                    Text("Please upload your medical reports",
                        style: TextStyle(
                            fontSize: 30,
                            color: Colors.blueGrey,
                            fontWeight: FontWeight.w700)),
                    SizedBox(
                      height: 30,
                    ),
                    _multipleAttachmentControl(),
                    SizedBox(
                      height: 30,
                    ),
                    _selectedReports.length != 0
                        ? _showAttachedItems()
                        : SizedBox(),
                    SizedBox(
                      height: 30,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        ElevatedButton(
                            onPressed: () async {
                              if (widget.user.newUser == true) {
                                User updateNewUserField = User(
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
                                    widget.user.bloodGlucoseLevel,
                                    widget.user.bloodCholestrolLevel,
                                    widget.user.cardiacCondition,
                                    widget.user.bloodTestType,
                                    widget.user.memberName,
                                    widget.user.memberRelationship,
                                    widget.user.memberPhoneNo,
                                    false,
                                    widget.user.gender);

                                Response response =
                                    await UserLoginService.updateNewUser(
                                        updateNewUserField);

                              }

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        DashboardScreen(widget.user)),
                              );
                            },
                            child: Text(widget.user.newUser ? "Skip" : "Back")),
                        SizedBox(width: 30),
                        ElevatedButton(
                            onPressed: _isLoading == false
                                ? () {
                                    _onTapAnalyseBtn();
                                  }
                                : null,
                            child: Text("Analyse")),
                        _isLoading == true
                            ? Padding(
                                padding: const EdgeInsets.only(left: 20.0),
                                child: CircularProgressIndicator(),
                              )
                            : SizedBox()
                      ],
                    ),

                    SizedBox(height: 30),
                    // wordPairs.length != 0 ? _displayOutputTable() : SizedBox()
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
