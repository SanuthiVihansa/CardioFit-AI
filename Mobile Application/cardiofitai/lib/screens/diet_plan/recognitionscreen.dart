// import 'dart:convert';
// import 'dart:io';
// import 'dart:io' as Io;
// import 'dart:typed_data';
//
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:http/http.dart'as http;
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
//   WordIndex(this.phrase, this.startIndex, this.endIndex, this.nextWord, this.nextWordIndex);
// }
//
// class WordPair {
//   final String word;
//   final String nextWord;
//
//   WordPair(this.word, this.nextWord);
// }
//
// class _RecognitionScreenState extends State<RecognitionScreen> {
//   late File pickedimage = File('');
//   bool scanning =false;
//   String scannedText='';
//   //List<WordIndex> wordIndexes = [];
//   List<WordPair> wordPairs = [];
//   String? selectedReport = 'Select Report';
//   String diagnosis ="";
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
//
//   ];
//   //Pick Image from galley or Camera
//   void optionsdialog(BuildContext context){
//     showDialog(context: context, builder: (context){
//       return SimpleDialog(
//         children: [
//           SimpleDialogOption(
//             onPressed: ()=>pickimage(ImageSource.gallery),
//             child: Text("Gallery"),
//           ),
//           SimpleDialogOption(
//             onPressed: ()=>pickimage(ImageSource.camera),
//             child: Text("Camera"),
//           ),
//           SimpleDialogOption(
//             onPressed: ()=>Navigator.pop(context),
//             child: Text("Back"),
//           ),
//         ],
//       );
//     });
//   }
//
//   pickimage(ImageSource source)async{
//     final image = await ImagePicker().pickImage(source: source);
//     setState(() {
//       scanning=true;
//       pickedimage = File(image!.path);
//     });
//     Navigator.pop(context);
//
//     //Prepare the image
//     Uint8List bytes = Io.File(pickedimage.path).readAsBytesSync();
//     String img64 =base64Encode(bytes);
//
//     //Send to API
//     String url = "https://api.ocr.space/parse/image";
//     var data = {"base64Image":"data:image/jpg;base64,$img64","isTable": "true",};
//     var header = {"apikey": "K81742525988957"};
//     http.Response response = await http.post(Uri.parse("https://api.ocr.space/parse/image"), body: data, headers: header);
//
//     // Get data back
//     Map<String, dynamic> result = jsonDecode(response.body);
//     // print(result);
//     setState(() {
//       scanning=false;
//       scannedText = result["ParsedResults"][0]["ParsedText"];
//       wordPairs = findWordPairs(scannedText);
//
//     });
//
//   }
//   //Function to read values based on the report selected
//   List<WordPair> findWordPairs(String text) {
//     List<WordPair> pairs = [];
//     RegExp regExp = RegExp(" ");
//     if (selectedReport=="Full Blood Count Report") {
//       regExp = RegExp(
//           r'(WBC|Neutrophils(?:\s+Absolute\s+Count)?|Lymphocytes(?:\s+Absolute\s+Count)?|Monocytes(?:\s+Absolute\s+Count)?|Eosinophils(?:\s+Absolute\s+Count)?|Basophills|RBC|Haemoglobin|Packed\s+Cell\s+Volume|MCV|MCH|MCHC|RDW|Platelet\s+Count)\s+(\w+)',
//           caseSensitive: false);
//     }else if(selectedReport=="Urine Full Report"){
//       regExp = RegExp(
//           r'(Colour|Crystals|Casts|Organisms|Red(?:\s+Blood\s+Cells)?|Epthelial\s+Cells|Pus\s+Cells|Appearance|Urobilinogen|Bilirubin|Ketone\s+Bodies|Protein|Glucose|pH|Specific\s+Gravity)\s+(\w+)',
//           caseSensitive: false);
//     }
//     Iterable<Match> matches = regExp.allMatches(text);
//     for (Match match in matches) {
//       String word = match.group(1)!;
//       String nextWord = match.group(2)!; // Capture the next word after the phrase
//       pairs.add(WordPair(word, nextWord));
//       //print(wordPairs);
//     }
//     reportDiagnosis();
//     return pairs;
//
//   }
//
//   String reportDiagnosis(){
//     if (selectedReport == "Full Blood Count Report") {
//       if (wordPairs.any((pair) =>
//           pair.word == "WBC" &&
//               (int.tryParse(pair.nextWord) ?? 0) > 10000)) {
//         diagnosis="You are facing an infection";
//       } else if (wordPairs.any((pair) =>
//           pair.word == "Neutrophils" &&
//               (int.tryParse(pair.nextWord) ?? 0) > 80)) {
//         diagnosis="You are facing an Bacterial infection";
//       } else if (wordPairs.any((pair) =>
//           pair.word == "Lymphocytes" &&
//               (int.tryParse(pair.nextWord) ?? 0) > 40)) {
//         diagnosis = "You are facing a Viral Fever";
//       } else if (wordPairs.any((pair) =>
//           pair.word == "Eosinophils" &&
//               (int.tryParse(pair.nextWord) ?? 0) > 6)) {
//         diagnosis= "You are facing an Allergic reaction";
//       } else if (wordPairs.any((pair) =>
//           pair.word == "Platelet Count" &&
//               (int.tryParse(pair.nextWord) ?? 0) < 150000)) {
//         diagnosis= "Your platelet Count is very low, you could be suffering from\n▪️Viral Fever\n▪️Dengue\n▪️ITP\nIf the fever last for >3 days immediately go for doctor";
//       }else{
//         diagnosis="No defect identified";
//       }
//     }else if(selectedReport == "Urine Full Report"){
//       if (wordPairs.any((pair) =>
//       pair.word == "Pus Cells" &&
//           (int.tryParse(pair.nextWord) ?? 0) < 10)) {
//         diagnosis="You are facing an Urine infection";
//       }
//       else if (wordPairs.any((pair) =>
//       pair.word == "Protein" && pair.nextWord.toLowerCase() != "nil")){
//         diagnosis = "You are facing a Renal disease";
//       }
//       // else if (wordPairs.any((pair) =>
//       // pair.word == "Albumin" &&
//       //     (int.tryParse(pair.nextWord) ?? 0) > 40)) {
//       //   diagnosis = "You are facing a Renal disease";
//       // }
//       else if (wordPairs.any((pair) =>
//       pair.word == "Glucose" &&
//           pair.nextWord.toLowerCase() != "nil")) {
//         diagnosis= "You have Diabetics";
//       } else if (wordPairs.any((pair) =>
//       pair.word == "Red Blood Cells" &&
//           pair.nextWord.toLowerCase() != "occasional")) {
//         diagnosis= "Your Red Blood Count is very high, you could be suffering from\n▪️Renal disease\n▪️Urine infection\n▪️Renal Culculy\n▪️Cancer\nIf the fever last for >3 days immediately go for doctor";
//       }else{
//         diagnosis="No defect identified";
//       }
//
//
//
//     }
//     return diagnosis;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//       return Scaffold(
//         appBar: AppBar(
//           leading: IconButton(
//             color: Colors.white,
//             icon: const Icon(Icons.arrow_back),
//             onPressed: () {
//               Navigator.pop(context);
//             },
//           ),
//           title: const Text(
//             "CardioFit AI",
//             style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
//           ),
//           backgroundColor: Colors.red,
//         ),
//       body: SingleChildScrollView(
//         child: Container(
//           alignment: Alignment.center,
//           child: Column(
//             children: [
//               SizedBox(height: 55+ MediaQuery.of(context).viewInsets.top,),
//               Text("Laboratory Report Diagnosis",style:TextStyle( fontSize: 30,
//                   color: Colors.blueGrey,
//                   fontWeight: FontWeight.w700)
//               ),
//               SizedBox(height: 30,),
//               Container(
//                 width:500 ,
//                 decoration: BoxDecoration(
//                   border: Border.all(color: Colors.deepOrangeAccent, width: 2.0),
//                   borderRadius: BorderRadius.circular(8.0),
//                 ),
//                 child: DropdownButton<String>(
//                   value: selectedReport,
//                   icon: const Icon(Icons.arrow_downward),
//                   elevation: 16,
//                   style: const TextStyle(color: Colors.blueGrey),
//                   alignment: Alignment.center,
//                   underline: SizedBox(), // Remove the underline
//                   onChanged: (String? newValue) {
//                     if(newValue != null){
//                       setState(() {
//                         selectedReport = newValue!;
//                       });
//                     }
//                   },
//                   items: reports.map<DropdownMenuItem<String>>((String value) {
//                     return DropdownMenuItem<String>(
//                       value: value,
//                       child: Center( // Center the text
//                         child: Text(value, textAlign: TextAlign.center), // Set text alignment
//                       ),
//                     );
//                   }).toList(),
//                 ),
//               ),
//               SizedBox(height: 30,),
//               InkWell(
//                 onTap:()=>optionsdialog(context),
//                 child:pickedimage != null && pickedimage.path.isNotEmpty
//                     ? Image.file(
//                   pickedimage,
//                   width: 256,
//                   height: 256,
//                   fit: BoxFit.fill,
//                 )
//                     : Image.asset(
//                   'assets/icon.png',
//                   width: 256,
//                   height: 256,
//                   fit: BoxFit.fill,
//                 ),
//               ),
//
//
//               SizedBox(
//                 height: 30,
//               ),
//               scanning ? Text("Scanning....",style:TextStyle( fontSize: 25,
//                   color: Colors.blueGrey,
//                   fontWeight: FontWeight.w700)
//               ):
//               DataTable(
//                 columns: [
//                   DataColumn(label: Text('Component')),
//                   DataColumn(label: Text('Result')),
//                 ],
//                 rows: wordPairs
//                     .map(
//                       (pair) => DataRow(
//                     cells: [
//                       DataCell(Text(pair.word)),
//                       DataCell(Text(pair.nextWord)),
//                     ],
//                   ),
//                 )
//                     .toList(),
//               ),
//               SizedBox(height: 30),
//               diagnosis !=null?Text(diagnosis,style: TextStyle(
//                   color: Colors.blueGrey,
//                   fontSize: 20,
//                   fontWeight: FontWeight.w700),
//               ):Text(""),
//               SizedBox(height: 30)
//
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
