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

class _RecognitionScreenState extends State<RecognitionScreen> {
  late File pickedimage;
  bool scanning =false;
  String scannedText='';

  optionsdialog(BuildContext context){
    return showDialog(context: context, builder: (context){
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
    });


  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // floatingActionButton: Row(
      //   mainAxisAlignment: MainAxisAlignment.center,
      //   children: [
      //     FloatingActionButton(
      //       onPressed: (){},
      //       heroTag: "",
      //       child: Text("Gallery"),
      //     ),
      //     SizedBox(width: 10,),
      //     FloatingActionButton(
      //       onPressed: (){},
      //       heroTag: "",
      //       child: Text("Camera"),
      //     )
      //   ],
      // ),
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
              ):Text(scannedText,
              style:TextStyle( fontSize: 25,
                  color: Colors.blueGrey,
                  fontWeight: FontWeight.w600),textAlign: TextAlign.start,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
