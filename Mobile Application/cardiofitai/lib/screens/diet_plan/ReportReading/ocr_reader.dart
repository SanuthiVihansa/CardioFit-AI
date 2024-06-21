// import 'dart:io';
// import 'package:cardiofitai/services/ocr_temp_service.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
//
// import '../../../models/response.dart';
//
// class OcrReader extends StatefulWidget {
//   const OcrReader({Key? key}) : super(key: key);
//
//   @override
//   State<OcrReader> createState() => _OcrReaderState();
// }
//
// class _OcrReaderState extends State<OcrReader> {
//   bool textScanning = false;
//   XFile? imageFile;
//   String scannedText = "";
//   String dropdownValue = 'Full Blood Count (FBC)';
//   late Future<QuerySnapshot<Object?>> _allReportsUploaded;
//   Set<String> processedCombinations = Set<String>();
//   List<List<String>> tableData = []; // Define tableData here
//
//   //Function to generate a Report number
//   Future<void> _generateReportNumber() async {
//     _allReportsUploaded = OCRServiceTemp.getUserReportsNo();
//   }
//
//   void getImage(ImageSource source) async {
//     try {
//       final pickedImage =
//       await ImagePicker().pickImage(source: ImageSource.gallery);
//       if (pickedImage != null) {
//         textScanning = true;
//         imageFile = pickedImage;
//         setState(() {});
//         getRecognisedText(pickedImage);
//       }
//     } catch (e) {
//       textScanning = false;
//       imageFile = null;
//       scannedText = "Error occured while scanning";
//       setState(() {});
//     }
//   }
//
//   // void getRecognisedText(XFile image) async {
//   //   final inputImage = InputImage.fromFilePath(image.path);
//   //   // final rotatedImage = inputImage
//   //
//   //   final textRecognizer = TextRecognizer();
//   //
//   //   // final textDetector = GoogleMlKit.vision.textDetector();
//   //
//   //   final RecognizedText recognisedText =
//   //   await textRecognizer.processImage(inputImage);
//   //   String extractedText = recognisedText.text.trim();
//   //   print(extractedText);
//   //
//   //   await textRecognizer.close();
//   //   scannedText = "";
//   //   textScanning = false;
//   //   // if (scannedText != "") {
//   //   //   print("Has a value");
//   //   //   //check if username and number duplicate
//   //   //   String combinationKey = '';
//   //   // }
//   //   setState(() {});
//   // }
//   void getRecognisedText(XFile image) async {
//     final inputImage = InputImage.fromFilePath(image.path);
//
//     final textRecognizer = TextRecognizer();
//
//     final RecognizedText recognisedText =
//     await textRecognizer.processImage(inputImage);
//     String extractedText = recognisedText.text;
//
//     // Split the text into lines
//     List<String> lines = extractedText.split('\n');
//
//     // Remove leading and trailing spaces from each line
//     for (int i = 0; i < lines.length; i++) {
//       lines[i] = lines[i].trim();
//     }
//
//     // Join the lines together to form a single sentence
//     String cleanedText = lines.join(' ');
//
//     print(cleanedText);
//
//     await textRecognizer.close();
//     scannedText = "";
//
//     textScanning = false;
//     if (scannedText != "") {
//       print("Has a value");
//       //check if username and number duplicate
//       String combinationKey = '';
//     }
//     setState(() {});
//   }
//
//
//   @override
//   void initState() {
//     super.initState();
//   }
//
//   Widget scannedReports() => DropdownButton<String>(
//     // Ensure dropdownValue is initialized with a value from the items list
//     value: dropdownValue ?? 'Less Active', // Default to 'Less Active'
//     icon: const Icon(Icons.arrow_drop_down_circle_rounded),
//     onChanged: (String? newValue) {
//       setState(() {
//         dropdownValue = newValue!;
//       });
//     },
//     items: const [
//       DropdownMenuItem<String>(
//           value: 'Full Blood Count (FBC)',
//           child: Text('Full Blood Count (FBC)')),
//       // DropdownMenuItem<String>(
//       //     value: 'Intermediate', child: Text('Intermediate')),
//       // DropdownMenuItem<String>(
//       //     value: 'Very Active', child: Text('Very Active')),
//     ],
//   );
//
//   @override
//   // Widget build(BuildContext context) {
//   //   return Scaffold(
//   //     appBar: AppBar(
//   //       centerTitle: true,
//   //       title: const Text("Text Recognition example"),
//   //     ),
//   //     body: Center(
//   //         child: SingleChildScrollView(
//   //           child: Container(
//   //               margin: const EdgeInsets.all(20),
//   //               child: Column(
//   //                 crossAxisAlignment: CrossAxisAlignment.center,
//   //                 children: [
//   //                   // scannedReports(),
//   //                   if (textScanning) const CircularProgressIndicator(),
//   //                   if (!textScanning && imageFile == null)
//   //                     Container(
//   //                       width: 300,
//   //                       height: 300,
//   //                       color: Colors.grey[300]!,
//   //                     ),
//   //                   if (imageFile != null) Image.file(File(imageFile!.path)),
//   //                   Row(
//   //                     mainAxisAlignment: MainAxisAlignment.center,
//   //                     children: [
//   //                       Container(
//   //                           margin: const EdgeInsets.symmetric(horizontal: 5),
//   //                           padding: const EdgeInsets.only(top: 10),
//   //                           child: ElevatedButton(
//   //                             style: ElevatedButton.styleFrom(
//   //                               foregroundColor: Colors.grey,
//   //                               backgroundColor: Colors.white,
//   //                               shadowColor: Colors.grey[400],
//   //                               elevation: 10,
//   //                               shape: RoundedRectangleBorder(
//   //                                   borderRadius: BorderRadius.circular(8.0)),
//   //                             ),
//   //                             onPressed: () {
//   //                               getImage(ImageSource.gallery);
//   //                             },
//   //                             child: Container(
//   //                               margin: const EdgeInsets.symmetric(
//   //                                   vertical: 5, horizontal: 5),
//   //                               child: Column(
//   //                                 mainAxisSize: MainAxisSize.min,
//   //                                 children: [
//   //                                   Icon(
//   //                                     Icons.image,
//   //                                     size: 30,
//   //                                   ),
//   //                                   Text(
//   //                                     "Gallery",
//   //                                     style: TextStyle(
//   //                                         fontSize: 13, color: Colors.grey[600]),
//   //                                   )
//   //                                 ],
//   //                               ),
//   //                             ),
//   //                           )),
//   //                       Container(
//   //                           margin: const EdgeInsets.symmetric(horizontal: 5),
//   //                           padding: const EdgeInsets.only(top: 10),
//   //                           child: ElevatedButton(
//   //                             style: ElevatedButton.styleFrom(
//   //                               foregroundColor: Colors.grey,
//   //                               backgroundColor: Colors.white,
//   //                               shadowColor: Colors.grey[400],
//   //                               elevation: 10,
//   //                               shape: RoundedRectangleBorder(
//   //                                   borderRadius: BorderRadius.circular(8.0)),
//   //                             ),
//   //                             onPressed: () {
//   //                               getImage(ImageSource.camera);
//   //                             },
//   //                             child: Container(
//   //                               margin: const EdgeInsets.symmetric(
//   //                                   vertical: 5, horizontal: 5),
//   //                               child: Column(
//   //                                 mainAxisSize: MainAxisSize.min,
//   //                                 children: [
//   //                                   Icon(
//   //                                     Icons.camera_alt,
//   //                                     size: 30,
//   //                                   ),
//   //                                   Text(
//   //                                     "Camera",
//   //                                     style: TextStyle(
//   //                                         fontSize: 13, color: Colors.grey[600]),
//   //                                   )
//   //                                 ],
//   //                               ),
//   //                             ),
//   //                           )),
//   //                     ],
//   //                   ),
//   //                   const SizedBox(
//   //                     height: 20,
//   //                   ),
//   //                   Container(
//   //                     child: Text(
//   //                       scannedText,
//   //                       style: TextStyle(fontSize: 20),
//   //                     ),
//   //                   )
//   //                 ],
//   //               )),
//   //         )),
//   //   );
//   // }
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         centerTitle: true,
//         title: const Text("Text Recognition example"),
//       ),
//       body: Center(
//         child: SingleChildScrollView(
//           child: Container(
//             margin: const EdgeInsets.all(20),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 if (textScanning) const CircularProgressIndicator(),
//                 if (!textScanning && imageFile == null)
//                   Container(
//                     width: 300,
//                     height: 300,
//                     color: Colors.grey[300]!,
//                   ),
//                 if (imageFile != null) Image.file(File(imageFile!.path)),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Container(
//                       margin: const EdgeInsets.symmetric(horizontal: 5),
//                       padding: const EdgeInsets.only(top: 10),
//                       child: ElevatedButton(
//                         style: ElevatedButton.styleFrom(
//                           foregroundColor: Colors.grey,
//                           backgroundColor: Colors.white,
//                           shadowColor: Colors.grey[400],
//                           elevation: 10,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(8.0),
//                           ),
//                         ),
//                         onPressed: () {
//                           getImage(ImageSource.gallery);
//                         },
//                         child: Container(
//                           margin: const EdgeInsets.symmetric(
//                             vertical: 5,
//                             horizontal: 5,
//                           ),
//                           child: Column(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               Icon(
//                                 Icons.image,
//                                 size: 30,
//                               ),
//                               Text(
//                                 "Gallery",
//                                 style: TextStyle(
//                                   fontSize: 13,
//                                   color: Colors.grey[600],
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                     Container(
//                       margin: const EdgeInsets.symmetric(horizontal: 5),
//                       padding: const EdgeInsets.only(top: 10),
//                       child: ElevatedButton(
//                         style: ElevatedButton.styleFrom(
//                           foregroundColor: Colors.grey,
//                           backgroundColor: Colors.white,
//                           shadowColor: Colors.grey[400],
//                           elevation: 10,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(8.0),
//                           ),
//                         ),
//                         onPressed: () {
//                           getImage(ImageSource.camera);
//                         },
//                         child: Container(
//                           margin: const EdgeInsets.symmetric(
//                             vertical: 5,
//                             horizontal: 5,
//                           ),
//                           child: Column(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               Icon(
//                                 Icons.camera_alt,
//                                 size: 30,
//                               ),
//                               Text(
//                                 "Camera",
//                                 style: TextStyle(
//                                   fontSize: 13,
//                                   color: Colors.grey[600],
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(
//                   height: 20,
//                 ),
//                 if (scannedText.isNotEmpty)
//                   Table(
//                     border: TableBorder.all(),
//                     children: tableData.map((row) {
//                       return TableRow(
//                         children: row.map((cell) {
//                           return Padding(
//                             padding: const EdgeInsets.all(8.0),
//                             child: Text(cell),
//                           );
//                         }).toList(),
//                       );
//                     }).toList(),
//                   ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
