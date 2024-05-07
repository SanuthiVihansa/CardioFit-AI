import 'dart:convert';
import 'dart:io';
import 'dart:io' as Io;
import 'dart:typed_data';

import 'package:cardiofitai/models/user.dart';
import 'package:cardiofitai/screens/diet_plan/diet_plan_home_page.screen.dart';
import 'package:cardiofitai/screens/diet_plan/reportAnalysisScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

import '../../models/user.dart';

class RecognitionScreen extends StatefulWidget {
  const RecognitionScreen({super.key});

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
  late File pickedimage = File('');
  late double halfScreenWidth;
  late double height;
  bool scanning = false;
  String scannedText = '';

  //List<WordIndex> wordIndexes = [];
  List<WordPair> wordPairs = [];
  List<List<WordPair>> extractedText = [];
  String? selectedReport = 'Select Report';
  String diagnosis = "";
  late List<Map<String, dynamic>> addMultipleReports = [];
  String noSpace="";
  List<DataRow> rows = [];
  List<List<DataRow>> setRows = [];


  //Drop down control values
  List<String> reports = [
    'Select Report',
    'Fasting blood Sugar',
    'Lipid profile',
    //'Urine Full Report',
    //'Full Blood Count Report',
    // 'Random blood Sugar',
    // 'Post prandial blood sugar ',
    // 'Hba1c',
    // '75g ogtt',
    // 'Thyroid function test',
    // 'Liver function test (alt, ast, bilirubin)',
    // 'Blood urea',
    // 'Serum creatinine',
    // 'Serum electrolytes',
    // 'Serum cholesterol',
    // 'Esr',
    // 'Urine hcg',
    // 'HIV',
    // 'Troponin i',
  ];

  User? get user => null;

  //Pick Image from galley or Camera
  // void optionsdialog(BuildContext context) {
  //   showDialog(
  //       context: context,
  //       builder: (context) {
  //         return SimpleDialog(
  //           children: [
  //             SimpleDialogOption(
  //               onPressed: () => pickimage(ImageSource.gallery),
  //               child: Text("Gallery"),
  //             ),
  //             SimpleDialogOption(
  //               onPressed: () => pickimage(ImageSource.camera),
  //               child: Text("Camera"),
  //             ),
  //             SimpleDialogOption(
  //               onPressed: () => Navigator.pop(context),
  //               child: Text("Back"),
  //             ),
  //           ],
  //         );
  //       });
  // }
  //Multiple Attachment control Screen
  Widget _multipleAttachmentControl() {
    return Container(
      height: 300,
      width: 500,
      margin: const EdgeInsets.only(right: 20, bottom: 10),
      child: Material(
        borderRadius: BorderRadius.all(Radius.circular(20)),
        color: Colors.white54,
        elevation: 4,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              height: 80,
            ),
            Center(
                child: Text("\nPlease upload the medical reports\n",
                    style: TextStyle(color: Colors.grey, fontSize: 20))),
            Column(
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
                    value: selectedReport,
                    elevation: 16,
                    style: const TextStyle(color: Colors.blueGrey),
                    alignment: Alignment.topLeft,
                    underline: SizedBox(),
                    // Remove the underline
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          selectedReport = newValue!;
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
                  height: 10,
                ),
                Flexible(
                  child: ElevatedButton(
                    onPressed: () async {
                      final image = await ImagePicker()
                          .pickImage(source: ImageSource.gallery);
                      if (image != null) {
                        pickedimage = File(image.path);
                        if (pickedimage.path.isNotEmpty &&
                            selectedReport != 'Select Report') {
                          addMultipleReports.add(
                            {
                              "UploadedReport": selectedReport,
                              "UploadedImage": pickedimage,
                              "ScannedItems": "",
                              "ExtractedText":"",
                              "obtainedRows":rows,
                            },
                          );
                          // _showAttachedItems();
                          setState(() {});
                          print(addMultipleReports);
                        }
                      }
                    },
                    child: Text("Attach Report"),
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
            rows: addMultipleReports.map((e) {
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
                  addMultipleReports.remove(item);
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

  // void _pickImage() async {
  //   for (var item in addMultipleReports) {
  //     if (item["UploadedImage"] != null) {
  //       final image = item["UploadedImage"];
  //       // final image =
  //       //     await ImagePicker().pickImage(source: ImageSource.gallery);
  //       if (image != null) {
  //         Text("we are here");
  //         final pickedImage = File(image.path);
  //         final bytes = await pickedImage.readAsBytes();
  //         final img64 = base64Encode(bytes);
  //
  //         final url = "https://api.ocr.space/parse/image";
  //         final data = {
  //           "base64Image": "data:image/jpg;base64,$img64",
  //           "isTable": "true",
  //         };
  //         final header = {"apikey": "K81742525988957"};
  //         final response =
  //         await http.post(Uri.parse(url), body: data, headers: header);
  //
  //         final result = jsonDecode(response.body);
  //         final scannedText = result["ParsedResults"][0]["ParsedText"];
  //
  //         item["ScannedText"] = scannedText; // Add or update the ScannedText field
  //         // wordPairs = findWordPairs(item);
  //         //extractedText.add(wordPairs);
  //         _removeSpaces(scannedText);
  //         print("we are here");
  //         List<String> lines = noSpace.split('\n');
  //         List<String> bloodComponents = ['WBC', 'Neutrophils', 'Lymphocytes', 'Monocytes', 'Eosinophils', 'Basophills','NeutrophilsAbsoluteCount','LymphocytesAbsoluteCount','MonocytesAbsoluteCount','EosinophilsAbsoluteCount','Haemoglobin','PackedCellVolume(PCV)','MCV','MCH','MCHC','RDW','PlateletCount'];
  //         List<String> unitsComponents = ['/cumm', '%', '%', '%', '%', '%','/cumm','/cumm','/cumm','/cumm','g/dl','%','fL','pg','g/dL','%','/Cumm'];
  //         print("we entered rows");
  //         rows = _buildRows(bloodComponents, unitsComponents, lines);
  //         item["ExtractedText"] = extractedText;
  //       }
  //     }
  //   }
  //   // Navigator.of(context).pushReplacement(MaterialPageRoute(
  //   //     builder: (BuildContext context) =>
  //   //         ReportAnalysisScreen(extractedText,addMultipleReports)));
  // }

  void _pickImage() async {
    for (var item in addMultipleReports) {
      if (item["UploadedImage"] != null) {
        final image = item["UploadedImage"];
        if (image != null) {
          final pickedImage = File(image.path);
          final bytes = await pickedImage.readAsBytes();
          final img64 = base64Encode(bytes);

          final url = "https://api.ocr.space/parse/image";
          final data = {
            "base64Image": "data:image/jpg;base64,$img64",
            "isTable": "true",
          };
          final header = {"apikey": "K81742525988957"};
          final response =
          await http.post(Uri.parse(url), body: data, headers: header);

          final result = jsonDecode(response.body);
          final scannedText = result["ParsedResults"][0]["ParsedText"];

          item["ScannedText"] = scannedText; // Add or update the ScannedText field
          print(scannedText);
          _removeSpaces(scannedText);
          List<String> lines = noSpace.split('\n');
          if(item["UploadedReport"]!='Select Report'){
            if(item["UploadedReport"]=='Full Blood Count Report'){
              List<String> bloodComponents = ['WBC', 'Neutrophils', 'Lymphocytes', 'Monocytes', 'Eosinophils', 'Basophills','NeutrophilsAbsoluteCount','LymphocytesAbsoluteCount','MonocytesAbsoluteCount','EosinophilsAbsoluteCount','RBC','Haemoglobin','PackedCellVolume(PCV)','MCV','MCH','MCHC','RDW','PlateletCount'];
              List<String> unitsComponents = ['/Cumm', '0/0', '0/0', '0/0', '0/0', '0/0','/Cumm','/Cumm','/Cumm','/Cumm','Million/pL','g/dl','0/0','fL','pg','g/dL','0/0','/Cumm'];
              String selectedText=item["UploadedReport"];
              // Update rows here
              rows = _buildRows(bloodComponents, unitsComponents, lines,selectedText);
              setRows.add(rows);
              item["obtainedRows"]=rows;
              setState(() {});
            }
            else if(item["UploadedReport"] == 'Lipid profile'){
              List<String> bloodComponents = ['Cholesterol-Total', 'Triglycerides', 'HDL-C', 'LDL-C', 'VLDL-C', 'CHO/HDL-CRatio'];
              List<String> unitsComponents = ['mg/dL', 'mg/dL', 'mg/dL', 'mg/dL', 'mg/dL', ' '];
              String selectedText=item["UploadedReport"];
              // Update rows here
              rows = _buildRows(bloodComponents, unitsComponents, lines,selectedText);
              setRows.add(rows);
              item["obtainedRows"]=rows;
              setState(() {});
            }
            else if(item["UploadedReport"] == 'Fasting blood Sugar'){
              List<String> bloodComponents = ['FastingPlasmaGlucose', 'FastingBloodSugar','FaøngmasmaGlucose'];
              List<String> unitsComponents = ['mg/dL', 'mg/dL','mg/dL'];
              String selectedText=item["UploadedReport"];
              // Update rows here
              rows = _buildRows(bloodComponents, unitsComponents, lines,selectedText);
              setRows.add(rows);
              item["obtainedRows"]=rows;
              setState(() {});
            }
            else if(item["UploadedReport"]=="Urine Full Report"){
              List<String> bloodComponents = ['Colour', 'Appearance','SpecificGravity','pH','Glucose','Protein','KetoneBodies','Bilirubin','Urobilinogen','PusCells','RedBloodCells','EpithelialCells','Organisms','Crystals','Casts'];
              List<String> unitsComponents = [];
              String selectedText=item["UploadedReport"];
              rows = _buildRows(bloodComponents, unitsComponents, lines,selectedText);
              setRows.add(rows);
              item["obtainedRows"]=rows;
              setState(() {});
            }
          }
          item["ExtractedText"] = extractedText;

        }
      }
    }
    Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (BuildContext context) =>
            ReportAnalysisScreen(extractedText,addMultipleReports,setRows)));
  }



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

  List<DataRow> _buildRows(List<String> bloodComponents, List<String> unitsComponents, List<String> lines,String selectedText) {
    List<DataRow> rows = [];
    int startIndex = 0;
    int endIndex = 0;

    // Mapping of blood component names to display names
    Map<String, String> componentMap = {
      'FastingPlasmaGlucose': 'Fasting Plasma Glucose',
      'FastingBloodSugar': 'Fasting Blood Sugar',
      //'FaøngmasmaGlucose': 'Fasting Plasma Glucose', // Map 'FaøngmasmaGlucose' to 'Fasting Plasma Glucose'
    };

    // Filter out lines that contain any of the blood components
    List<String> filteredLines = lines.where((line) => bloodComponents.any((component) => line.contains(component))).toList();

    for (String line in filteredLines) {
      // Iterate through each line of text
      if (selectedText == "Fasting blood Sugar") {
        startIndex = line.indexOf("2022");
        endIndex = line.indexOf("Referencerange:");
      }
      else if(selectedText=="Full Blood Count Report"){
        startIndex = line.indexOf("FullBloodcount(FBC)");
        endIndex = line.indexOf("Referencerange:");
      }
      else if(selectedText=="Lipid profile"){
        startIndex = line.indexOf("LipidProfile");
        endIndex = line.indexOf("LipidProfileReferenceRangesforAdults");
      }
      else if(selectedText=="Urine Full Report"){
        startIndex = line.indexOf("UrineFullReport");
        //endIndex = line.indexOf("MedicalLaboratoryTechnologist");
      }


      if (startIndex == -1) {
        continue; // Skip lines that don't contain "startIndex"
      }

      //int endIndex = line.indexOf("LipidProfileReference:");
      if (endIndex == -1) {
        continue; // Skip lines that don't contain "endIndex"
      }

      String dataSection = line.substring(startIndex, endIndex);
      print(dataSection);

      // Keep track of which components have been found in this line
      Set<String> foundComponents = {};

      // Iterate through each blood component and unit component
      for (int i = 0; i < bloodComponents.length; i++) {
        String bloodComponent = bloodComponents[i];
        String unitComponent = unitsComponents[i];

        int bloodIndex = dataSection.indexOf(bloodComponent);
        int unitIndex = dataSection.indexOf(unitComponent, bloodIndex + bloodComponent.length);

        while (bloodIndex != -1 && unitIndex != -1) {
          // Extract the value between the blood component and unit component
          String value = dataSection.substring(bloodIndex + bloodComponent.length, unitIndex).trim();

          rows.add(DataRow(cells: [
            DataCell(Text(componentMap.containsKey(bloodComponent) ? componentMap[bloodComponent]! : bloodComponent)),
            DataCell(Text(value.trim())),
            DataCell(Text(unitComponent)),
          ]));


          // Add the found component to the set
          foundComponents.add(bloodComponent);
          foundComponents.add(unitComponent);

          // If all components have been found, break the loop
          if (foundComponents.length == bloodComponents.length * 2) {
            break;
          }

          // Update indices for the next occurrence
          bloodIndex = dataSection.indexOf(bloodComponent, unitIndex);
          unitIndex = dataSection.indexOf(unitComponent, bloodIndex + bloodComponent.length);
        }

        // If all components have been found, break the loop
        if (foundComponents.length == bloodComponents.length * 2) {
          break;
        }
      }

      // If all components have been found, break the outer loop
      if (foundComponents.length == bloodComponents.length * 2) {
        break;
      }
    }

    return rows;
  }



  @override
  Widget build(BuildContext context) {
    halfScreenWidth = (MediaQuery.of(context).size.width - 10) - 50;
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
        child: Container(
          alignment: Alignment.center,
          child: Column(
            children: [
              SizedBox(
                height: 55 + MediaQuery.of(context).viewInsets.top,
              ),
              Text("Laboratory Report Diagnosis",
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
              addMultipleReports.length != 0
                  ? _showAttachedItems()
                  : SizedBox(),

              // InkWell(
              //   onTap: () {},
              //   child: pickedimage != null && pickedimage.path.isNotEmpty
              //       ? Image.file(
              //           pickedimage,
              //           width: 256,
              //           height: 256,
              //           fit: BoxFit.fill,
              //         )
              //       : Image.asset(
              //           'assets/icon.png',
              //           width: 256,
              //           height: 256,
              //           fit: BoxFit.fill,
              //         ),
              // ),
              SizedBox(
                height: 30,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text("Back")),
                  SizedBox(width: 30),
                  ElevatedButton(
                      onPressed: () {
                        _pickImage();
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
    );
  }
}