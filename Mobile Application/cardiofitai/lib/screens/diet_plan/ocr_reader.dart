import 'dart:io';
import 'package:flutter/material.dart';
// import 'package:flutter_scalable_ocr/flutter_scalable_ocr.dart';
//import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';


class OcrReader extends StatefulWidget {
  const OcrReader({Key? key}) : super(key: key);

  @override
  State<OcrReader> createState() => _OcrReaderState();
}

class _OcrReaderState extends State<OcrReader> {
  bool textScanning = false;

  XFile? imageFile;

  String scannedText = "";

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
                                foregroundColor: Colors.grey, backgroundColor: Colors.white,
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
                                foregroundColor: Colors.grey, backgroundColor: Colors.white,
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
      final pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedImage != null) {
        textScanning = true;
        imageFile = pickedImage;
        setState(() {});
        getRecognisedText(pickedImage);
        print(scannedText);
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
    final textRecognizer = TextRecognizer();
    // final textDetector = GoogleMlKit.vision.textDetector();

    final RecognizedText recognisedText = await textRecognizer.processImage(inputImage);
    String extractedText = recognisedText.text;
    print(extractedText);
    await textRecognizer.close();
    scannedText = "";
    for (TextBlock block in recognisedText.blocks) {
      for (TextLine line in block.lines) {
        scannedText = scannedText + line.text + "\n";
      }
    }
    textScanning = false;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
  }
}