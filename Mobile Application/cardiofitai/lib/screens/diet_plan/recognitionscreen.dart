import 'dart:convert';
import 'dart:io';
import 'dart:io' as Io;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart'as http;

class RecognitionScreen extends StatefulWidget {
  const RecognitionScreen({super.key});

  @override
  State<RecognitionScreen> createState() => _RecognitionScreenState();
}

class WordIndex {
  final String phrase;
  //final String word;
  final int startIndex;
  final int endIndex;
  final String nextWord;
  final int nextWordIndex;

  WordIndex(this.phrase, this.startIndex, this.endIndex, this.nextWord, this.nextWordIndex);
}

class WordPair {
  final String word;
  final String nextWord;

  WordPair(this.word, this.nextWord);
}

class _RecognitionScreenState extends State<RecognitionScreen> {
  late File pickedimage;
  bool scanning =false;
  String scannedText='';
  //List<WordIndex> wordIndexes = [];
  List<WordPair> wordPairs = [];


  void optionsdialog(BuildContext context){
     showDialog(context: context, builder: (context){
      return SimpleDialog(
        children: [
          SimpleDialogOption(
            onPressed: ()=>pickimage(ImageSource.gallery),
            child: Text("Gallery"),
          ),
          SimpleDialogOption(
            onPressed: ()=>pickimage(ImageSource.camera),
            child: Text("Camera"),
          ),
          SimpleDialogOption(
            onPressed: ()=>Navigator.pop(context),
            child: Text("Back"),
          ),
        ],
      );
    });
  }

  pickimage(ImageSource source)async{
    final image = await ImagePicker().getImage(source: source);
    setState(() {
      scanning=true;
      pickedimage = File(image!.path);
    });
    Navigator.pop(context);

    //Prepare the image
    Uint8List bytes = Io.File(pickedimage.path).readAsBytesSync();
    String img64 =base64Encode(bytes);

    //Send to API
    String url = "https://api.ocr.space/parse/image";
    var data = {"base64Image":"data:image/jpg;base64,$img64","isTable": "true",};
    var header = {"apikey": "K81742525988957"};
    http.Response response = await http.post(Uri.parse("https://api.ocr.space/parse/image"), body: data, headers: header);

    // Get data back
    Map<String, dynamic> result = jsonDecode(response.body);
    // print(result);
    setState(() {
      scanning=false;
      scannedText = result["ParsedResults"][0]["ParsedText"];
      List<String> extractText = scannedText.split(" ");
      // wordIndexes = findWordIndexes(scannedText);
      wordPairs = findWordPairs(scannedText);
      // RegExp regExp = RegExp(r'Platelet\s+Count', caseSensitive: false);
      // Iterable<String> requiredDetails = extractText.where((extractedText) => extractedText.contains("WBC")||extractedText.contains("Neutrophils")||extractedText.contains("Lymphocytes")||extractedText.contains("Monocytes")||extractedText.contains("Eosinophils")||extractedText.contains("Basophills")||extractedText.contains("RBC")|| extractedText.contains("Haemoglobin")|| extractedText.contains("Packed Cell Volume")|| extractedText.contains("MCV")|| extractedText.contains("MCH")|| extractedText.contains("MCHC")|| extractedText.contains("RDW")&& regExp.hasMatch(extractedText));
      // // scannedText = requiredDetails.join(" ");
      // print(requiredDetails);
    });

  }

  // List<WordIndex> findWordIndexes(String text) {
  //   List<WordIndex> indexes = [];
  //   List<String> extractText = text.split(" ");
  //   Iterable<String> requiredDetails = extractText;
  //   // RegExp regExp = RegExp(r'Platelet\s+Count', caseSensitive: false);
  //   // Iterable<String> requiredDetails = extractText.where((extractedText) =>
  //   // extractedText.contains("WBC") ||
  //   //     extractedText.contains("Neutrophils") ||
  //   //     extractedText.contains("Lymphocytes") ||
  //   //     extractedText.contains("Monocytes") ||
  //   //     extractedText.contains("Eosinophils") ||
  //   //     extractedText.contains("Basophills") ||
  //   //     extractedText.contains("RBC") ||
  //   //     extractedText.contains("Haemoglobin") ||
  //   //     extractedText.contains("Packed Cell Volume") ||
  //   //     extractedText.contains("MCV") ||
  //   //     extractedText.contains("MCH") ||
  //   //     extractedText.contains("MCHC") ||
  //   //     extractedText.contains("RDW") && regExp.hasMatch(extractedText));
  //
  //   int currentIndex = 0;
  //   for (String word in requiredDetails) {
  //     int startIndex = text.indexOf(word, currentIndex);
  //     int endIndex = startIndex + word.length - 1;
  //     indexes.add(WordIndex(word, startIndex, endIndex));
  //     currentIndex = endIndex + 1;
  //   }
  //
  //   return indexes;
  // }

  // List<WordIndex> findWordIndexes(String text) {
  //   List<WordIndex> indexes = [];
  //   RegExp regExp = RegExp(r'Platelet\s+Count', caseSensitive: false);
  //   Iterable<Match> matches = regExp.allMatches(text);
  //
  //   for (Match match in matches) {
  //     int startIndex = match.start;
  //     int endIndex = match.end - 1;
  //     indexes.add(WordIndex(text.substring(startIndex, endIndex + 1), startIndex, endIndex));
  //   }
  //
  //   return indexes;
  // }

  // List<WordIndex> findWordIndexes(String text) {
  //   List<WordIndex> indexes = [];
  //   RegExp regExp = RegExp(r'(WBC|Neutrophils|Lymphocytes|Monocytes|Eosinophils|Basophills|RBC|Haemoglobin|Packed Cell Volume|MCV|MCH|MCHC|RDW|Neutrophils\s+Absolute\s+Count|Lymphocytes\s+Absolute\s+Count|Monocytes\s+Absolute\s+Count|Esoniophils\s+Absolute\s+Count|Platelet\s+Count)\s+(\w+)', caseSensitive: false);
  //   Iterable<Match> matches = regExp.allMatches(text);
  //
  //   for (Match match in matches) {
  //     int startIndex = match.start;
  //     int endIndex = match.end - 1;
  //     String phrase = text.substring(startIndex, endIndex + 1);
  //     String nextWord = match.group(2)!; // Capture the next word after the phrase
  //     indexes.add(WordIndex(phrase, startIndex, endIndex, nextWord, match.end));
  //   }
  //
  //   return indexes;
  // }
  List<WordPair> findWordPairs(String text) {
    List<WordPair> pairs = [];
    RegExp regExp = RegExp(
        r'(WBC|Neutrophils|Lymphocytes|Monocytes|Eosinophils|Basophills|RBC|Haemoglobin|Packed Cell Volume|MCV|MCH|MCHC|RDW|Neutrophils\s+Absolute\s+Count|Lymphocytes\s+Absolute\s+Count|Monocytes\s+Absolute\s+Count|Esoniophils\s+Absolute\s+Count|Platelet\s+Count)\s+(\w+)',
        caseSensitive: false);
    Iterable<Match> matches = regExp.allMatches(text);

    for (Match match in matches) {
      String word = match.group(1)!;
      String nextWord = match.group(2)!; // Capture the next word after the phrase
      pairs.add(WordPair(word, nextWord));
    }

    return pairs;
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          alignment: Alignment.center,
          child: Column(
            children: [
              SizedBox(height: 55+ MediaQuery.of(context).viewInsets.top,),
              Text("Text Recognition",style:TextStyle( fontSize: 30,
                  color: Colors.blueGrey,
                  fontWeight: FontWeight.w700)
              ),
              SizedBox(height: 30,),
              InkWell(
                onTap:()=>optionsdialog(context)
                ,
                child: Image(
                  width: 256,
                  height: 256,
                  image: AssetImage('assets/icon.png'),
                  fit: BoxFit.fill,
                ),
              ),
              SizedBox(
                height: 30,
              ),
              scanning ? Text("Scanning....",style:TextStyle( fontSize: 25,
                  color: Colors.blueGrey,
                  fontWeight: FontWeight.w700)
               ):
              DataTable(
                columns: [
                  DataColumn(label: Text('Word')),
                  DataColumn(label: Text('Next Word')),
                ],
                rows: wordPairs
                    .map(
                      (pair) => DataRow(
                    cells: [
                      DataCell(Text(pair.word)),
                      DataCell(Text(pair.nextWord)),
                    ],
                  ),
                )
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
                    // Text(
                    //   "Phrase: ${index.phrase}, Start Index: ${index.startIndex}, End Index: ${index.endIndex}",
                    //   style: TextStyle(
                    //       fontSize: 25,
                    //       color: Colors.blueGrey,
                    //       fontWeight: FontWeight.w600),
                    // ),
                    // Text(
                    //   "Next Word: ${index.nextWord}, Next Word Index: ${index.nextWordIndex}",
                    //   style: TextStyle(
                    //       fontSize: 20,
                    //       color: Colors.blueGrey,
                    //       fontWeight: FontWeight.w500),
                    // ),
                    // SizedBox(height: 10),

              //   ))
              //       .toList(),
              // ),

              //Text(scannedText,
              // style:TextStyle( fontSize: 25,
              //     color: Colors.blueGrey,
              //     fontWeight: FontWeight.w600),textAlign: TextAlign.start,
              // ),
//               );
//           ),
//         ),
//       ),
//     );
//   }
//  }
