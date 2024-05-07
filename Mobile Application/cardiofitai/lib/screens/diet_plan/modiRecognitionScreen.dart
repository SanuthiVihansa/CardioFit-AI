// import 'dart:convert';
// import 'dart:io';
// import 'dart:io' as Io;
// import 'dart:typed_data';
//
// import 'package:cardiofitai/models/user.dart';
// import 'package:cardiofitai/screens/diet_plan/diet_plan_home_page.screen.dart';
// import 'package:cardiofitai/screens/diet_plan/reportAnalysisScreen.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:http/http.dart' as http;
//
// class RecognitionScreen extends StatefulWidget {
//   const RecognitionScreen({super.key});
//
//   @override
//   State<RecognitionScreen> createState() => _RecognitionScreenState();
// }
//
// class WordIndex {
//   final String phrase;
//   final int startIndex;
//   final int endIndex;
//   final String nextWord;
//   final int nextWordIndex;
//
//   WordIndex(this.phrase, this.startIndex, this.endIndex, this.nextWord,
//       this.nextWordIndex);
// }
//
// class WordPair {
//   final String word;
//   final String nextWord;
//
//
//   WordPair(this.word, this.nextWord);
// }
//
// class _RecognitionScreenState extends State<RecognitionScreen> {
//   late File pickedimage = File('');
//   late double halfScreenWidth;
//   late double height;
//   bool scanning = false;
//   String scannedText = '';
//
//   //List<WordIndex> wordIndexes = [];
//   List<WordPair> wordPairs = [];
//   List<List<WordPair>> extractedText = [];
//   String? selectedReport = 'Select Report';
//   String diagnosis = "";
//   late List<Map<String, dynamic>> addMultipleReports = [];
//
//   //Drop down control values
//   List<String> reports = [
//     'Select Report',
//     'Full Blood Count Report',
//     'Urine Full Report',
//     'Random blood Sugar',
//     'Fasting blood Sugar',
//     'Post prandial blood sugar ',
//     'Hba1c',
//     '75g ogtt',
//     'Thyroid function test',
//     'Liver function test (alt, ast, bilirubin)',
//     'Blood urea',
//     'Serum creatinine',
//     'Serum electrolytes',
//     'Lipid profile',
//     'Serum cholesterol',
//     'Esr',
//     'Urine hcg',
//     'HIV',
//     'Troponin i',
//   ];
//
//   User? get user => null;
//
//   //Pick Image from galley or Camera
//   // void optionsdialog(BuildContext context) {
//   //   showDialog(
//   //       context: context,
//   //       builder: (context) {
//   //         return SimpleDialog(
//   //           children: [
//   //             SimpleDialogOption(
//   //               onPressed: () => pickimage(ImageSource.gallery),
//   //               child: Text("Gallery"),
//   //             ),
//   //             SimpleDialogOption(
//   //               onPressed: () => pickimage(ImageSource.camera),
//   //               child: Text("Camera"),
//   //             ),
//   //             SimpleDialogOption(
//   //               onPressed: () => Navigator.pop(context),
//   //               child: Text("Back"),
//   //             ),
//   //           ],
//   //         );
//   //       });
//   // }
//   //Multiple Attachment control Screen
//   Widget _multipleAttachmentControl() {
//     return Container(
//       height: 300,
//       width: 500,
//       margin: const EdgeInsets.only(right: 20, bottom: 10),
//       child: Material(
//         borderRadius: BorderRadius.all(Radius.circular(20)),
//         color: Colors.white54,
//         elevation: 4,
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: <Widget>[
//             SizedBox(
//               height: 80,
//             ),
//             Center(
//                 child: Icon(
//               Icons.attach_file,
//               size: 50,
//               color: Colors.grey,
//             )),
//             Center(
//                 child: Text("\nPlease upload the medical reports\n",
//                     style: TextStyle(color: Colors.grey, fontSize: 20))),
//             Row(
//               mainAxisSize: MainAxisSize.min,
//               children: <Widget>[
//                 SizedBox(
//                   width: 30,
//                 ),
//                 Container(
//                   width: 250,
//                   decoration: BoxDecoration(
//                     border:
//                         Border.all(color: Colors.deepOrangeAccent, width: 2.0),
//                     borderRadius: BorderRadius.circular(8.0),
//                   ),
//                   child: DropdownButton<String>(
//                     value: selectedReport,
//                     elevation: 16,
//                     style: const TextStyle(color: Colors.blueGrey),
//                     alignment: Alignment.topLeft,
//                     underline: SizedBox(),
//                     // Remove the underline
//                     onChanged: (String? newValue) {
//                       if (newValue != null) {
//                         setState(() {
//                           selectedReport = newValue!;
//                         });
//                       }
//                     },
//                     items:
//                         reports.map<DropdownMenuItem<String>>((String value) {
//                       return DropdownMenuItem<String>(
//                         value: value,
//                         child: Center(
//                           child: Text(value, textAlign: TextAlign.start),
//                         ),
//                       );
//                     }).toList(),
//                   ),
//                 ),
//                 SizedBox(
//                   width: 30,
//                 ),
//                 Flexible(
//                   child: ElevatedButton(
//                     onPressed: () async {
//                       final image = await ImagePicker()
//                           .pickImage(source: ImageSource.gallery);
//                       if (image != null) {
//                         pickedimage = File(image.path);
//                         if (pickedimage.path.isNotEmpty &&
//                             selectedReport != 'Select Report') {
//                           addMultipleReports.add(
//                             {
//                               "UploadedReport": selectedReport,
//                               "UploadedImage": pickedimage,
//                               "ScannedItems": "",
//                               "ExtractedText":""
//                             },
//                           );
//                           // _showAttachedItems();
//                           setState(() {});
//                           print(addMultipleReports);
//                         }
//                       }
//                     },
//                     child: Text("Attach Report"),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _showAttachedItems() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 108.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Center(
//             child: Text(
//               'Uploaded Report Files', // Your header text here
//               style: TextStyle(
//                 fontWeight: FontWeight.bold,
//                 fontSize: 20,
//               ),
//             ),
//           ),
//           SizedBox(height: 10), // Add space between header and table
//           DataTable(
//             columnSpacing: 50,
//             dataRowHeight: 70,
//             columns: [
//               DataColumn(label: Text('Report')),
//               DataColumn(label: Text('Report Type')),
//               DataColumn(label: Text('Action')),
//             ],
//             rows: addMultipleReports.map((e) {
//               return DataRow(cells: [
//                 DataCell(
//                   Image.file(e["UploadedImage"], width: 50, height: 50),
//                 ),
//                 DataCell(
//                   Text(e["UploadedReport"]),
//                 ),
//                 DataCell(
//                   GestureDetector(
//                     child: Icon(Icons.restore_from_trash_outlined),
//                     onTap: () {
//                       _removeItem(e);
//                     },
//                   ),
//                 ),
//               ]);
//             }).toList(),
//           ),
//         ],
//       ),
//     );
//   }
//
//   //Remove confirmation widget
//   void _removeItem(Map<String, dynamic> item) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text('Confirm'),
//           content: Text('Are you sure you want to remove this item?'),
//           actions: <Widget>[
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: Text('Cancel'),
//             ),
//             TextButton(
//               onPressed: () {
//                 setState(() {
//                   addMultipleReports.remove(item);
//                 });
//                 Navigator.of(context).pop();
//               },
//               child: Text('Remove'),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   // pickimage(ImageSource source) async {
//   //   final image = await ImagePicker().pickImage(source: source);
//   //   setState(() {
//   //     scanning = true;
//   //     pickedimage = File(image!.path);
//   //   });
//   //
//   //   //Prepare the image
//   //   Uint8List bytes = Io.File(pickedimage.path).readAsBytesSync();
//   //   String img64 = base64Encode(bytes);
//   //
//   //   //Send to API
//   //   String url = "https://api.ocr.space/parse/image";
//   //   var data = {
//   //     "base64Image": "data:image/jpg;base64,$img64",
//   //     "isTable": "true",
//   //   };
//   //   var header = {"apikey": "K81742525988957"};
//   //   http.Response response = await http.post(
//   //       Uri.parse("https://api.ocr.space/parse/image"),
//   //       body: data,
//   //       headers: header);
//   //
//   //   // Get data back
//   //   Map<String, dynamic> result = jsonDecode(response.body);
//   //   // print(result);
//   //   setState(() {
//   //     scanning = false;
//   //     scannedText = result["ParsedResults"][0]["ParsedText"];
//   //     wordPairs = findWordPairs(scannedText);
//   //   });
//   //
//   // }
//
//   //Function to read values based on the report selected
//   void _pickImage() async {
//     for (var item in addMultipleReports) {
//       if (item["UploadedImage"] != null) {
//         final image = item["UploadedImage"];
//         // final image =
//         //     await ImagePicker().pickImage(source: ImageSource.gallery);
//         if (image != null) {
//           Text("we are here");
//           final pickedImage = File(image.path);
//           final bytes = await pickedImage.readAsBytes();
//           final img64 = base64Encode(bytes);
//
//           final url = "https://api.ocr.space/parse/image";
//           final data = {
//             "base64Image": "data:image/jpg;base64,$img64",
//             "isTable": "true",
//           };
//           final header = {"apikey": "K81742525988957"};
//           final response =
//               await http.post(Uri.parse(url), body: data, headers: header);
//
//           final result = jsonDecode(response.body);
//           final scannedText = result["ParsedResults"][0]["ParsedText"];
//
//           item["ScannedText"] = scannedText; // Add or update the ScannedText field
//           wordPairs = findWordPairs(item);
//           extractedText.add(wordPairs);
//           item["ExtractedText"] = extractedText;
//         }
//       }
//     }
//     Navigator.of(context).pushReplacement(MaterialPageRoute(
//         builder: (BuildContext context) =>
//             ReportAnalysisScreen(extractedText,addMultipleReports)));
//   }
//
//
//
//   // List<WordPair> findWordPairs(Map<String, dynamic> item) {
//   //   List<WordPair> pairs = [];
//   //   RegExp regExp = RegExp(" ");
//   //   String selectedReport = item["UploadedReport"];
//   //
//   //   if (selectedReport == "Full Blood Count Report") {
//   //     Text("added blood text");
//   //     regExp = RegExp(
//   //         r'(WBC|Neutrophils(?:\s+Absolute\s+Count)?|Lymphocytes(?:\s+Absolute\s+Count)?|Monocytes(?:\s+Absolute\s+Count)?|Eosinophils(?:\s+Absolute\s+Count)?|Basophills|RBC|Haemoglobin|Packed\s+Cell\s+Volume|MCV|MCH|MCHC|RDW|Platelet\s+Count)\s+(\w+)',
//   //         caseSensitive: false);
//   //   } else if (selectedReport == "Urine Full Report") {
//   //     regExp = RegExp(
//   //         r'(Colour|Crystals|Casts|Organisms|Red(?:\s+Blood\s+Cells)?|Epthelial\s+Cells|Pus\s+Cells|Appearance|Urobilinogen|Bilirubin|Ketone\s+Bodies|Protein|Glucose|pH|Specific\s+Gravity)\s+(\w+)',
//   //         caseSensitive: false);
//   //   }
//   //
//   //   Iterable<Match> matches = regExp.allMatches(item["ScannedText"]);
//   //   for (Match match in matches) {
//   //     String word = match.group(1)!;
//   //     String nextWord = match.group(2)!; // Capture the next word after the phrase
//   //     String thirdWord = match.group(3)!; // Capture the next word after the phrase
//   //     String fourthWord = match.group(4)!; // Capture the next word after the phrase
//   //     String fifthWord = match.group(5)!; // Capture the next word after the phrase
//   //     String sixthWord = match.group(6)!; // Capture the next word after the phrase
//   //     String seventhWord = match.group(7)!; // Capture the next word after the phrase
//   //     String eightWord = match.group(8)!; // Capture the next word after the phrase
//   //     String nineWord = match.group(9)!; // Capture the next word after the phrase
//   //
//   //     pairs.add(WordPair(word, nextWord,thirdWord,fourthWord,fifthWord,sixthWord,seventhWord,eightWord,nineWord));
//   //   }
//   //
//   //   return pairs;
//   // }
//   List<WordPair> findWordPairs(Map<String, dynamic> item) {
//     List<WordPair> pairs = [];
//     RegExp regExp = RegExp(" ");
//     String selectedReport = item["UploadedReport"];
//
//     if (selectedReport == "Full Blood Count Report") {
//       regExp = RegExp(
//           r'(WBC|Neutrophils(?:\s+Absolute\s+Count)?|Lymphocytes(?:\s+Absolute\s+Count)?|Monocytes(?:\s+Absolute\s+Count)?|Eosinophils(?:\s+Absolute\s+Count)?|Basophills|RBC|Haemoglobin|Packed\s+Cell\s+Volume|MCV|MCH|MCHC|RDW|Platelet\s+Count)\s+(\w+)\s+(\w+)\s+(\w+)\s+(\w+)\s+(\w+)\s+(\w+)\s+(\w+)\s+(\w+)',
//           caseSensitive: false);
//     } else if (selectedReport == "Urine Full Report") {
//       regExp = RegExp(
//           r'(Colour|Crystals|Casts|Organisms|Red(?:\s+Blood\s+Cells)?|Epthelial\s+Cells|Pus\s+Cells|Appearance|Urobilinogen|Bilirubin|Ketone\s+Bodies|Protein|Glucose|pH|Specific\s+Gravity)\s+(\w+)\s+(\w+)\s+(\w+)\s+(\w+)\s+(\w+)\s+(\w+)\s+(\w+)\s+(\w+)',
//           caseSensitive: false);
//     }
//
//     Iterable<Match> matches = regExp.allMatches(item["ScannedText"]);
//     for (Match match in matches) {
//       String word = match.group(1)!;
//       String nextWord = match.group(2)!;
//       pairs.add(WordPair(word, nextWord));
//     }
//
//     return pairs;
//   }
//
//
//
//
//   @override
//   Widget build(BuildContext context) {
//     halfScreenWidth = (MediaQuery.of(context).size.width - 10) - 50;
//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//           color: Colors.white,
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () {
//             Navigator.pop(context);
//           },
//         ),
//         title: const Text(
//           "CardioFit AI",
//           style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
//         ),
//         backgroundColor: Colors.red,
//       ),
//       body: SingleChildScrollView(
//         child: Container(
//           alignment: Alignment.center,
//           child: Column(
//             children: [
//               SizedBox(
//                 height: 55 + MediaQuery.of(context).viewInsets.top,
//               ),
//               Text("Laboratory Report Diagnosis",
//                   style: TextStyle(
//                       fontSize: 30,
//                       color: Colors.blueGrey,
//                       fontWeight: FontWeight.w700)),
//               SizedBox(
//                 height: 30,
//               ),
//               _multipleAttachmentControl(),
//               SizedBox(
//                 height: 30,
//               ),
//               addMultipleReports.length != 0
//                   ? _showAttachedItems()
//                   : SizedBox(),
//
//               // InkWell(
//               //   onTap: () {},
//               //   child: pickedimage != null && pickedimage.path.isNotEmpty
//               //       ? Image.file(
//               //           pickedimage,
//               //           width: 256,
//               //           height: 256,
//               //           fit: BoxFit.fill,
//               //         )
//               //       : Image.asset(
//               //           'assets/icon.png',
//               //           width: 256,
//               //           height: 256,
//               //           fit: BoxFit.fill,
//               //         ),
//               // ),
//               SizedBox(
//                 height: 30,
//               ),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: <Widget>[
//                   ElevatedButton(
//                       onPressed: () {
//                         Navigator.of(context).pushReplacement(MaterialPageRoute(
//                             builder: (BuildContext context) =>
//                                 DietHomePage(user!)));
//                       },
//                       child: Text("Back")),
//                   SizedBox(width: 30),
//                   ElevatedButton(
//                       onPressed: () {
//                         _pickImage();
//                       },
//                       child: Text("Analyse")),
//                 ],
//               ),
//               SizedBox(height: 30),
//               // wordPairs.length != 0 ? _displayOutputTable() : SizedBox()
//             ],
//           ),
//         ),
//       ),
//     );
//   }
import 'dart:convert';
import 'dart:io';
import 'dart:io' as Io;
import 'dart:typed_data';

import 'package:cardiofitai/models/user.dart';
import 'package:cardiofitai/screens/diet_plan/diet_plan_home_page.screen.dart';
import 'package:cardiofitai/screens/diet_plan/reportAnalysisScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

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

  //Drop down control values
  List<String> reports = [
    'Select Report',
    'Full Blood Count Report',
    'Urine Full Report',
    // 'Random blood Sugar',
    'Fasting blood Sugar',
    // 'Post prandial blood sugar ',
    // 'Hba1c',
    // '75g ogtt',
    // 'Thyroid function test',
    // 'Liver function test (alt, ast, bilirubin)',
    // 'Blood urea',
    // 'Serum creatinine',
    // 'Serum electrolytes',
     'Lipid profile',
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
                child: Icon(
                  Icons.attach_file,
                  size: 50,
                  color: Colors.grey,
                )),
            Center(
                child: Text("\nPlease upload the medical reports\n",
                    style: TextStyle(color: Colors.grey, fontSize: 20))),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                SizedBox(
                  width: 30,
                ),
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
                  width: 30,
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
                              "ExtractedText":""
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

  void _pickImage() async {
    for (var item in addMultipleReports) {
      if (item["UploadedImage"] != null) {
        final image = item["UploadedImage"];
        // final image =
        //     await ImagePicker().pickImage(source: ImageSource.gallery);
        if (image != null) {
          Text("we are here");
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
          // wordPairs = findWordPairs(item);
          //extractedText.add(wordPairs);
          // Split the scannedText into lines
          List<String> lines = scannedText.split('\n');

          // Split each line into words and add to extractedText
          List<List<String>> extractedText = lines.map((line) => line.split(' ')).toList();
          item["ExtractedText"] = extractedText;
        }
      }
    }
    Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (BuildContext context) =>
            ReportAnalysisScreen(extractedText,addMultipleReports)));
  }

  // List<WordPair> findWordPairs(Map<String, dynamic> item) {
  //   List<WordPair> pairs = [];
  //   RegExp regExp = RegExp(" ");
  //   String selectedReport = item["UploadedReport"];
  //
  //   if (selectedReport == "Full Blood Count Report") {
  //     Text("added blood text");
  //     regExp = RegExp(
  //         r'(WBC|Neutrophils(?:\s+Absolute\s+Count)?|Lymphocytes(?:\s+Absolute\s+Count)?|Monocytes(?:\s+Absolute\s+Count)?|Eosinophils(?:\s+Absolute\s+Count)?|Basophills|RBC|Haemoglobin|Packed\s+Cell\s+Volume|MCV|MCH|MCHC|RDW|Platelet\s+Count)\s+(\w+)',
  //         caseSensitive: false);
  //   } else if (selectedReport == "Urine Full Report") {
  //     regExp = RegExp(
  //         r'(Colour|Crystals|Casts|Organisms|Red(?:\s+Blood\s+Cells)?|Epthelial\s+Cells|Pus\s+Cells|Appearance|Urobilinogen|Bilirubin|Ketone\s+Bodies|Protein|Glucose|pH|Specific\s+Gravity)\s+(\w+)',
  //         caseSensitive: false);
  //   }
  //
  //   Iterable<Match> matches = regExp.allMatches(item["ScannedText"]);
  //   for (Match match in matches) {
  //     String word = match.group(1)!;
  //     String nextWord =
  //     match.group(2)!; // Capture the next word after the phrase
  //     pairs.add(WordPair(word, nextWord));
  //   }
  //
  //   return pairs;
  // }


  // Extracted All values
  // List<WordPair> findWordPairs(Map<String, dynamic> item) {
  //   List<WordPair> pairs = [];
  //   late RegExp regExp = RegExp(" ");
  //
  //   String selectedReport = item["UploadedReport"];
  //
  //   // Define regular expressions based on the type of report
  //   if (selectedReport == "Full Blood Count Report") {
  //     // Define regular expression for Full Blood Count Report
  //     regExp = RegExp(
  //         r'(WBC|Neutrophils(?:\s+Absolute\s+Count)?|Lymphocytes(?:\s+Absolute\s+Count)?|Monocytes(?:\s+Absolute\s+Count)?|Eosinophils(?:\s+Absolute\s+Count)?|Basophils|RBC|Haemoglobin|Packed\s+Cell\s+Volume|MCV|MCH|MCHC|RDW|Platelet\s+Count)\s+(.*?)(?=\s+(?:WBC|Neutrophils(?:\s+Absolute\s+Count)?|Lymphocytes(?:\s+Absolute\s+Count)?|Monocytes(?:\s+Absolute\s+Count)?|Eosinophils(?:\s+Absolute\s+Count)?|Basophils|RBC|Haemoglobin|Packed\s+Cell\s+Volume|MCV|MCH|MCHC|RDW|Platelet\s+Count|$))',
  //         caseSensitive: false);
  //   } else if (selectedReport == "Urine Full Report") {
  //     // Define regular expression for Urine Full Report
  //     regExp = RegExp(
  //         r'(Colour|Crystals|Casts|Organisms|Red(?:\s+Blood\s+Cells)?|Epithelial\s+Cells|Pus\s+Cells|Appearance|Urobilinogen|Bilirubin|Ketone\s+Bodies|Protein|Glucose|pH|Specific\s+Gravity)\s+(.*?)(?=\s+(?:Colour|Crystals|Casts|Organisms|Red(?:\s+Blood\s+Cells)?|Epithelial\s+Cells|Pus\s+Cells|Appearance|Urobilinogen|Bilirubin|Ketone\s+Bodies|Protein|Glucose|pH|Specific\s+Gravity|$))',
  //         caseSensitive: false);
  //   } else if (selectedReport == "Fasting blood Sugar") {
  //     // Define regular expression for Fasting blood Sugar
  //     regExp = RegExp(
  //         r'(Fasting(?:\s+Blood\s+Sugar)?|Fasting(?:\s+Plasma\s+Glucose)?)\s+(.*?)(?=\s+(?:Fasting(?:\s+Blood\s+Sugar)?|Fasting(?:\s+Plasma\s+Glucose)?|$))',
  //         caseSensitive: false);
  //   }else if (selectedReport == "Lipid profile") {
  //     regExp = RegExp(
  //         r'(Cholesterol - Total|Triglycerides|HDL-C|LDL-C|VLDL-C|CHO/HDL-c Ratio)\s+(\d+(\.\d+)?)\s*(mg/dL|\u20AC\d+)?',
  //         caseSensitive: false);
  //   }
  //   // Extract matches from the scanned text using the regular expression
  //   Iterable<Match> matches = regExp.allMatches(item["ScannedText"]);
  //   // Iterate through the matches
  //   for (Match match in matches) {
  //     String word = match.group(1)!;
  //     String nextWord = match.group(2)!;
  //
  //     // Add word pair to the list
  //     pairs.add(WordPair(word, nextWord));
  //   }
  //   return pairs;
  //
  //
  // }

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
                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                            builder: (BuildContext context) =>
                                DietHomePage(user!)));
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
