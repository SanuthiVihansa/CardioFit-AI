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
import '../../../services/prescription_reading_api_service.dart';
import '../../../services/user_information_service.dart';

class RecognitionScreen extends StatefulWidget {
  const RecognitionScreen(this.user, {super.key});

  final User user;

  @override
  State<RecognitionScreen> createState() => _RecognitionScreenState();
}

class WordIndex {
  final String phrase;
  final int startIndex;
  final int endIndex;
  final String nextWord;
  final int nextWordIndex;

  WordIndex(this.phrase, this.startIndex, this.endIndex, this.nextWord,
      this.nextWordIndex);
}

class WordPair {
  final String word;
  final String nextWord;

  WordPair(this.word, this.nextWord);
}

class _RecognitionScreenState extends State<RecognitionScreen> {
  final apiService = ApiService();
  File? pickedImage;
  XFile? image;
  bool detecting = false;
  late double halfScreenWidth;
  late double height;
  bool scanning = false;
  String scannedText = '';

  Map<String, dynamic> apiData = {};
  List<WordPair> wordPairs = [];
  List<List<WordPair>> extractedText = [];
  String? _selectedReport = 'Select Report';
  String diagnosis = "";
  late List<Map<String, dynamic>> _selectedReports = [];
  String noSpace = "";
  List<DataRow> _rows = [];
  List<List<DataRow>> _reportDataRows = [];
  List<File> _pickedImages = [];

  //Drop down control values
  List<String> reports = [
    'Select Report',
    'Fasting blood Sugar',
    'Urine Full Report',
    'Lipid profile',
    'Full Blood Count Report'
  ];

  User? get user => null;

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
    // =======================================================================================
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
          List<String> results = [];
          results = await apiService.sendImagesToGPT4VisionReports(
              images: _pickedImages);
          Map<String, dynamic> decodedJson =
              json.decode(results[0].substring(8, results[0].length - 4));
          for (int i = 0; i < decodedJson.keys.toList().length; i++) {
            _singleReportDataRows.add(DataRow(cells: [
              DataCell(Text(decodedJson.keys.toList()[i])),
              DataCell(
                  Text(decodedJson[decodedJson.keys.toList()[i].toString()])),
              const DataCell(Text(""))
            ]));
          }
          _reportDataRows.add(_singleReportDataRows);
        } else if (_selectedReports[i]["UploadedReport"] == "Lipid Profile") {

        } else if (_selectedReports[i]["UploadedReport"] ==
            "Full Blood Count Report") {
          List<String> results = [];
          results = await apiService.sendImagesToGPT4VisionReports(
              images: _pickedImages);
          Map<String, dynamic> decodedJson =
          json.decode(results[0].substring(8, results[0].length - 4));
          for (int i = 0; i < decodedJson.keys.toList().length; i++) {
            _singleReportDataRows.add(DataRow(cells: [
              DataCell(Text(decodedJson.keys.toList()[i])),
              DataCell(
                  Text(decodedJson[decodedJson.keys.toList()[i].toString()])),
              const DataCell(Text(""))
            ]));
          }
          _reportDataRows.add(_singleReportDataRows);
        }
      }
      // =======================================================================================

      // List<String> results = [];
      // List<Map<String, dynamic>> newResults = [];
      // if (_selectedReport != "Urine Full Report" &&
      //     _selectedReport != "Full Blood Count Report") {
      //   if (_selectedReport == "Fasting blood Sugar") {
      //     for (File img in _pickedImages) {
      //       var request = await http.MultipartRequest(
      //           "POST",
      //           Uri.parse(
      //               "https://sanuthivihansa.pythonanywhere.com/glucose/extract-text"));
      //       request.files
      //           .add(await http.MultipartFile.fromPath('file', img.path));
      //       final response = await request.send();
      //       if (response.statusCode == 200) {
      //         final responseData = await http.Response.fromStream(response);
      //         final Map<String, dynamic> responseJson =
      //             json.decode(responseData.body);
      //         newResults.add(responseJson);
      //       }
      //     }
      //   }
      // } else {
      //   results = await apiService.sendImagesToGPT4VisionReports(
      //       images: _pickedImages);
      // }

      // for (int i = 0; i < results.length; i++) {
      //   String scannedText = results[i];
      //   if (i >= _selectedReports.length) {
      //     print('Index out of bounds: $i');
      //     continue;
      //   }
      //   Map<String, dynamic> item = _selectedReports[i];
      //   item["ScannedText"] =
      //       scannedText; // Add or update the ScannedText field
      //   print(scannedText);
      //   _removeSpaces(scannedText);
      //   List<String> lines = noSpace.split('\n');
      //
      //   if (item["UploadedReport"] != 'Select Report') {
      //     List<String> bloodComponents = [];
      //     List<String> unitsComponents = [];
      //
      //     switch (item["UploadedReport"]) {
      //       case 'Full Blood Count Report':
      //         bloodComponents = [
      //           'WBC',
      //           'Neutrophils',
      //           'Lymphocytes',
      //           'Monocytes',
      //           'Eosinophils',
      //           'Basophills',
      //           'NeutrophilsAbsoluteCount',
      //           'LymphocytesAbsoluteCount',
      //           'MonocytesAbsoluteCount',
      //           'EosinophilsAbsoluteCount',
      //           'RBC',
      //           'Haemoglobin',
      //           'PackedCellVolume(PCV)',
      //           'MCV',
      //           'MCH',
      //           'MCHC',
      //           'RDW',
      //           'PlateletCount'
      //         ];
      //         unitsComponents = [
      //           '/Cumm',
      //           '0/0',
      //           '0/0',
      //           '0/0',
      //           '0/0',
      //           '0/0',
      //           '/Cumm',
      //           '/Cumm',
      //           '/Cumm',
      //           '/Cumm',
      //           'Million/pL',
      //           'g/dl',
      //           '0/0',
      //           'fL',
      //           'pg',
      //           'g/dL',
      //           '0/0',
      //           '/Cumm'
      //         ];
      //         break;
      //       case 'Lipid profile':
      //         bloodComponents = [
      //           'Cholesterol-Total',
      //           'Triglycerides',
      //           'HDL-C',
      //           'LDL-C',
      //           'VLDL-C',
      //           'CHO/HDL-CRatio'
      //         ];
      //         unitsComponents = [
      //           'mg/dL',
      //           'mg/dL',
      //           'mg/dL',
      //           'mg/dL',
      //           'mg/dL',
      //           ' '
      //         ];
      //         break;
      //       case 'Fasting blood Sugar':
      //         bloodComponents = [
      //           'FastingPlasmaGlucose',
      //           'FastingBloodSugar',
      //           'FaøngmasmaGlucose'
      //         ];
      //         unitsComponents = ['mg/dL', 'me/dl', 'mg/dL'];
      //         break;
      //       case 'Urine Full Report':
      //         bloodComponents = [
      //           'Colour',
      //           'Appearance',
      //           'SpecificGravity',
      //           'pH',
      //           'Glucose',
      //           'Protein',
      //           'KetoneBodies',
      //           'Bilirubin',
      //           'Urobilinogen',
      //           'PusCells',
      //           'RedBloodCells',
      //           'EpithelialCells',
      //           'Organisms',
      //           'Crystals',
      //           'Casts'
      //         ];
      //         unitsComponents = [];
      //         break;
      //     }
      //
      //     String selectedText = item["UploadedReport"];
      //     _rows =
      //         _buildRows(bloodComponents, unitsComponents, lines, selectedText);
      //     _reportDataRows.add(_rows);
      //     item["obtainedRows"] = _rows;
      //     setState(() {});
      //   }
      //   item["ExtractedText"] = extractedText;
      // }

      Navigator.of(context).push(MaterialPageRoute(
          builder: (BuildContext context) => ReportAnalysisScreen(
              // extractedText,
              _selectedReports,
              _reportDataRows,
              widget.user)));
    }
  }

//correct code
// void _pickImage() async {
//   for (var item in addMultipleReports) {
//     if (item["UploadedImage"] != null) {
//       final image = item["UploadedImage"];
//       if (image != null) {
//         // final pickedImage = File(image.path);
//         // final bytes = await pickedImage.readAsBytes();
//         // final img64 = base64Encode(bytes);
//         //
//         // final url = "https://api.ocr.space/parse/image";
//         // final data = {
//         //   "base64Image": "data:image/jpg;base64,$img64",
//         //   "isTable": "true",
//         // };
//         // final header = {"apikey": "K81742525988957"};
//         // final response =
//         // await http.post(Uri.parse(url), body: data, headers: header);
//
//         //final result = jsonDecode(response.body);
//         // final scannedText = result["ParsedResults"][0]["ParsedText"];
//         final scannedText = await apiService.sendImageToGPT4VisionReport(image: pickedImage!);
//
//         item["ScannedText"] = scannedText; // Add or update the ScannedText field
//         print(scannedText);
//         _removeSpaces(scannedText);
//         List<String> lines = noSpace.split('\n');
//         if(item["UploadedReport"]!='Select Report'){
//           if(item["UploadedReport"]=='Full Blood Count Report'){
//             List<String> bloodComponents = ['WBC', 'Neutrophils', 'Lymphocytes', 'Monocytes', 'Eosinophils', 'Basophills','NeutrophilsAbsoluteCount','LymphocytesAbsoluteCount','MonocytesAbsoluteCount','EosinophilsAbsoluteCount','RBC','Haemoglobin','PackedCellVolume(PCV)','MCV','MCH','MCHC','RDW','PlateletCount'];
//             List<String> unitsComponents = ['/Cumm', '0/0', '0/0', '0/0', '0/0', '0/0','/Cumm','/Cumm','/Cumm','/Cumm','Million/pL','g/dl','0/0','fL','pg','g/dL','0/0','/Cumm'];
//             String selectedText=item["UploadedReport"];
//             // Update rows here
//             rows = _buildRows(bloodComponents, unitsComponents, lines,selectedText);
//             setRows.add(rows);
//             item["obtainedRows"]=rows;
//             setState(() {});
//           }
//           else if(item["UploadedReport"] == 'Lipid profile'){
//             List<String> bloodComponents = ['Cholesterol-Total', 'Triglycerides', 'HDL-C', 'LDL-C', 'VLDL-C', 'CHO/HDL-CRatio'];
//             List<String> unitsComponents = ['mg/dL', 'mg/dL', 'mg/dL', 'mg/dL', 'mg/dL', ' '];
//             String selectedText=item["UploadedReport"];
//             // Update rows here
//             rows = _buildRows(bloodComponents, unitsComponents, lines,selectedText);
//             setRows.add(rows);
//             item["obtainedRows"]=rows;
//             setState(() {});
//           }
//           else if(item["UploadedReport"] == 'Fasting blood Sugar'){
//             List<String> bloodComponents = ['FastingPlasmaGlucose', 'FastingBloodSugar','FaøngmasmaGlucose'];
//             List<String> unitsComponents = ['mg/dL', 'me/dl','mg/dL'];
//             String selectedText=item["UploadedReport"];
//             // Update rows here
//             rows = _buildRows(bloodComponents, unitsComponents, lines,selectedText);
//             setRows.add(rows);
//             item["obtainedRows"]=rows;
//             setState(() {});
//           }
//           else if(item["UploadedReport"]=="Urine Full Report"){
//             List<String> bloodComponents = ['Colour', 'Appearance','SpecificGravity','pH','Glucose','Protein','KetoneBodies','Bilirubin','Urobilinogen','PusCells','RedBloodCells','EpithelialCells','Organisms','Crystals','Casts'];
//             List<String> unitsComponents = [];
//             String selectedText=item["UploadedReport"];
//             rows = _buildRows(bloodComponents, unitsComponents, lines,selectedText);
//             setRows.add(rows);
//             item["obtainedRows"]=rows;
//             setState(() {});
//           }
//         }
//         item["ExtractedText"] = extractedText;
//
//       }
//     }
//   }
//   Navigator.of(context).pushReplacement(MaterialPageRoute(
//       builder: (BuildContext context) =>
//           ReportAnalysisScreen(extractedText,addMultipleReports,setRows)));
// }

  String _removeSpaces(String text) {
    noSpace = text.replaceAll(RegExp(r'\s+'), '');

    return noSpace;
  }

//
// List<DataRow> _buildRows(List<String> bloodComponents, List<String> unitsComponents, List<String> lines) {
//   List<DataRow> rows = [];
//   int startIndex=0;
//   int endIndex=0;
//
//   // Filter out lines that contain any of the blood components
//   List<String> filteredLines = lines.where((line) => bloodComponents.any((component) => line.contains(component))).toList();
//
//   for (String line in filteredLines) {
//     // Iterate through each line of text
//     if(selectedReport=="Fasting blood Sugar"){
//       startIndex = line.indexOf("2022");
//       endIndex = line.indexOf("Referencerange:");
//     }
//     //int startIndex = line.indexOf("FullBloodcount(FBC)");
//     //int startIndex = line.indexOf("LipidProfile");
//
//     if (startIndex == -1) {
//       continue; // Skip lines that don't contain "FullBloodcount(FBC)"
//     }
//
//     //int endIndex = line.indexOf("LipidProfileReference:");
//     if (endIndex == -1) {
//       continue; // Skip lines that don't contain "References:"
//     }
//
//     String dataSection = line.substring(startIndex, endIndex);
//     print(dataSection);
//
//     // Keep track of which components have been found in this line
//     Set<String> foundComponents = {};
//
//     // Iterate through each blood component and unit component
//     for (int i = 0; i < bloodComponents.length; i++) {
//       String bloodComponent = bloodComponents[i];
//       String unitComponent = unitsComponents[i];
//
//       int bloodIndex = dataSection.indexOf(bloodComponent);
//       int unitIndex = dataSection.indexOf(unitComponent, bloodIndex + bloodComponent.length);
//
//       while (bloodIndex != -1 && unitIndex != -1) {
//         // Extract the value between the blood component and unit component
//         String value = dataSection.substring(bloodIndex + bloodComponent.length, unitIndex).trim();
//
//         rows.add(DataRow(cells: [
//           DataCell(Text(bloodComponent)),
//           DataCell(Text(value.trim())),
//           DataCell(Text(unitComponent)),
//         ]));
//
//         // Add the found component to the set
//         foundComponents.add(bloodComponent);
//         foundComponents.add(unitComponent);
//
//         // If all components have been found, break the loop
//         if (foundComponents.length == bloodComponents.length * 2) {
//           break;
//         }
//
//         // Update indices for the next occurrence
//         bloodIndex = dataSection.indexOf(bloodComponent, unitIndex);
//         unitIndex = dataSection.indexOf(unitComponent, bloodIndex + bloodComponent.length);
//       }
//
//       // If all components have been found, break the loop
//       if (foundComponents.length == bloodComponents.length * 2) {
//         break;
//       }
//     }
//
//     // If all components have been found, break the outer loop
//     if (foundComponents.length == bloodComponents.length * 2) {
//       break;
//     }
//   }
//
//   return rows;
// }

  List<DataRow> _buildRows(List<String> bloodComponents,
      List<String> unitsComponents, List<String> lines, String selectedText) {
    List<DataRow> rows = [];

    // Mapping of blood component names to display names
    Map<String, String> componentMap = {
      'FastingPlasmaGlucose': 'Fasting Plasma Glucose',
      'FastingBloodSugar': 'Fasting Blood Sugar',
      // Add more mappings as needed
    };

    // Filter out lines that contain any of the blood components
    List<String> filteredLines = lines
        .where((line) =>
            bloodComponents.any((component) => line.contains(component)))
        .toList();

    for (String line in filteredLines) {
      print("Processing line: $line"); // Debug print

      // Iterate through each blood component and unit component
      for (int i = 0; i < bloodComponents.length; i++) {
        String bloodComponent = bloodComponents[i];
        String unitComponent =
            unitsComponents.length > i ? unitsComponents[i] : '';

        int bloodIndex = line.indexOf(bloodComponent);
        int unitIndex =
            line.indexOf(unitComponent, bloodIndex + bloodComponent.length);

        // Ensure the indices are valid
        if (bloodIndex == -1 || unitIndex == -1) {
          continue;
        }

        while (bloodIndex != -1 && unitIndex != -1) {
          // Extract the value between the blood component and unit component
          String value = line
              .substring(bloodIndex + bloodComponent.length, unitIndex)
              .trim();

          // Debug print to verify extracted values
          print(
              "Component: $bloodComponent, Value: $value, Unit: $unitComponent");

          rows.add(DataRow(cells: [
            DataCell(Text(componentMap.containsKey(bloodComponent)
                ? componentMap[bloodComponent]!
                : bloodComponent)),
            DataCell(Text(value.trim())),
            DataCell(Text(unitComponent)),
          ]));

          // Update indices for the next occurrence
          bloodIndex = line.indexOf(bloodComponent, unitIndex);
          unitIndex =
              line.indexOf(unitComponent, bloodIndex + bloodComponent.length);

          // Ensure the indices are valid
          if (bloodIndex == -1 || unitIndex == -1) {
            break;
          }
        }
      }
    }

    return rows;
  }

  @override
  Widget build(BuildContext context) {
    halfScreenWidth = (MediaQuery.of(context).size.width - 10) - 50;
    return Scaffold(
      appBar: AppBar(
        // leading: IconButton(
        //   color: Colors.white,
        //   icon: const Icon(Icons.arrow_back),
        //   onPressed: () {
        //     Navigator.pop(context);
        //   },
        // ),
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
                              if(widget.user.newUser==true){
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
                                    false  // Update newUser field to false
                                );

                                Response response = await UserLoginService.updateNewUser(updateNewUserField);
                              }

                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => DashboardScreen(widget.user)),
                              );
                            },
                            child: Text(widget.user.newUser ? "Skip" : "Back")),
                        SizedBox(width: 30),
                        ElevatedButton(
                            onPressed: () {
                              _onTapAnalyseBtn();
                            },
                            child: Text("Analyse")),
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
