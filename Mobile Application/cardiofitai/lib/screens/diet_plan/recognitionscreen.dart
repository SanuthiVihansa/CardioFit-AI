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
  late File pickedimage = File('');
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
    final image = await ImagePicker().pickImage(source: source);
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
      wordPairs = findWordPairs(scannedText);

    });

  }

  List<WordPair> findWordPairs(String text) {
    List<WordPair> pairs = [];
    RegExp regExp = RegExp(
        r'(WBC|Neutrophils(?:\s+Absolute\s+Count)?|Lymphocytes(?:\s+Absolute\s+Count)?|Monocytes(?:\s+Absolute\s+Count)?|Eosinophils(?:\s+Absolute\s+Count)?|Basophills|RBC|Haemoglobin|Packed Cell Volume|MCV|MCH|MCHC|RDW|Platelet\s+Count)\s+(\w+)',
        caseSensitive: false);
    Iterable<Match> matches = regExp.allMatches(text);

    for (Match match in matches) {
      String word = match.group(1)!;
      String nextWord = match.group(2)!; // Capture the next word after the phrase
      pairs.add(WordPair(word, nextWord));
      print(wordPairs);
    }
    print(pairs);
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
              Text("Laboratory Report Diagnosis",style:TextStyle( fontSize: 30,
                  color: Colors.blueGrey,
                  fontWeight: FontWeight.w700)
              ),
              SizedBox(height: 30,),
              InkWell(
                onTap:()=>optionsdialog(context),
                child:pickedimage != null && pickedimage.path.isNotEmpty
                    ? Image.file(
                  pickedimage,
                  width: 256,
                  height: 256,
                  fit: BoxFit.fill,
                )
                    : Image.asset(
                  'assets/icon.png',
                  width: 256,
                  height: 256,
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