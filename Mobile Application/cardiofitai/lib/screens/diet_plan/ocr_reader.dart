import 'dart:io';
import 'package:cardiofitai/services/ocr_temp_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/response.dart';

class OcrReader extends StatefulWidget {
  const OcrReader({Key? key}) : super(key: key);

  @override
  State<OcrReader> createState() => _OcrReaderState();
}

class _OcrReaderState extends State<OcrReader> {
  bool textScanning = false;

  XFile? imageFile;

  String scannedText = "";
  String dropdownValue = 'Full Blood Count (FBC)';

  late Future<QuerySnapshot<Object?>> _allReportsUploaded;

  Set<String> processedCombinations = Set<String>();

  //Function to generate a Report number
  Future<void> _generateReportNumber() async {
    _allReportsUploaded = OCRServiceTemp.getUserReportsNo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Text Recognition example"),
      ),
      body: Center(
          child: SingleChildScrollView(
        child: Container(
            margin: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // scannedReports(),
                if (textScanning) const CircularProgressIndicator(),
                if (!textScanning && imageFile == null)
                  Container(
                    width: 300,
                    height: 300,
                    color: Colors.grey[300]!,
                  ),
                if (imageFile != null) Image.file(File(imageFile!.path)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        padding: const EdgeInsets.only(top: 10),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.grey,
                            backgroundColor: Colors.white,
                            shadowColor: Colors.grey[400],
                            elevation: 10,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0)),
                          ),
                          onPressed: () {
                            getImage(ImageSource.gallery);
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                                vertical: 5, horizontal: 5),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.image,
                                  size: 30,
                                ),
                                Text(
                                  "Gallery",
                                  style: TextStyle(
                                      fontSize: 13, color: Colors.grey[600]),
                                )
                              ],
                            ),
                          ),
                        )),
                    Container(
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        padding: const EdgeInsets.only(top: 10),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.grey,
                            backgroundColor: Colors.white,
                            shadowColor: Colors.grey[400],
                            elevation: 10,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0)),
                          ),
                          onPressed: () {
                            getImage(ImageSource.camera);
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                                vertical: 5, horizontal: 5),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.camera_alt,
                                  size: 30,
                                ),
                                Text(
                                  "Camera",
                                  style: TextStyle(
                                      fontSize: 13, color: Colors.grey[600]),
                                )
                              ],
                            ),
                          ),
                        )),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                Container(
                  child: Text(
                    scannedText,
                    style: TextStyle(fontSize: 20),
                  ),
                )
              ],
            )),
      )),
    );
  }

  void getImage(ImageSource source) async {
    try {
      final pickedImage =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedImage != null) {
        textScanning = true;
        imageFile = pickedImage;
        setState(() {});
        getRecognisedText(pickedImage);
      }
    } catch (e) {
      textScanning = false;
      imageFile = null;
      scannedText = "Error occured while scanning";
      setState(() {});
    }
  }

  void getRecognisedText(XFile image) async {
    final inputImage = InputImage.fromFilePath(image.path);
    // final rotatedImage = inputImage

    final textRecognizer = TextRecognizer();

    // final textDetector = GoogleMlKit.vision.textDetector();

    final RecognizedText recognisedText =
        await textRecognizer.processImage(inputImage);
    String extractedText = recognisedText.text;
    print(extractedText);

    await textRecognizer.close();
    scannedText = "";
    // for (TextBlock block in recognisedText.blocks) {
    //   for (TextLine line in block.lines) {
    //     for (TextElement element in line.elements) {
    //       scannedText = scannedText + element.text + "\n";
    //     }
    //   }
    // }

    List<List<String>> tableData =[];
    for(TextBlock block in recognisedText.blocks){
      for(TextLine line in block.lines){
        List<String> row =[];
        for(TextElement element in line.elements){
          row.add(element.text);
        }
        tableData.add(row);
      }
    }

    for(int i=0; i<4; i++){
      tableData.add(['A$i','B$i','C$i','D$i']);
    }



    textScanning = false;
    if (scannedText != "") {
      print("Has a value");
      //check if username and number duplicate
      String combinationKey = '';
      // if (!processedCombinations.contains(combinationKey)) {
      //   processedCombinations.add(combinationKey);
      //   Response response = await OCRServiceTemp.addReportContent(
      //       "username", _generateReportNumber() as int, scannedText);
      //   print(response.message);
      // } else {
      //   print("Duplicate combination detected");
      // }
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
  }

  Widget scannedReports() => DropdownButton<String>(
        // Ensure dropdownValue is initialized with a value from the items list
        value: dropdownValue ?? 'Less Active', // Default to 'Less Active'
        icon: const Icon(Icons.arrow_drop_down_circle_rounded),
        onChanged: (String? newValue) {
          setState(() {
            dropdownValue = newValue!;
          });
        },
        items: const [
          DropdownMenuItem<String>(
              value: 'Full Blood Count (FBC)',
              child: Text('Full Blood Count (FBC)')),
          // DropdownMenuItem<String>(
          //     value: 'Intermediate', child: Text('Intermediate')),
          // DropdownMenuItem<String>(
          //     value: 'Very Active', child: Text('Very Active')),
        ],
      );
}
