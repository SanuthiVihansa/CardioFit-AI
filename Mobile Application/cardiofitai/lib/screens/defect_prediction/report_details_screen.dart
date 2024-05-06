
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;


class ReportDetailsScreen extends StatefulWidget {
  @override
  _FilePickerScreenState createState() => _FilePickerScreenState();
}

class _FilePickerScreenState extends State<ReportDetailsScreen> {
  File? _selectedFile;

  void _selectFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['txt'], // Adjust as needed
    );

    if (result != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
      });

      // Make POST request to Flask API
      String apiUrl = 'http://hilarinac.pythonanywhere.com/predict';
      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
      request.files.add(
        http.MultipartFile(
          'file',
          _selectedFile!.readAsBytes().asStream(),
          _selectedFile!.lengthSync(),
          filename: _selectedFile!.path.split('/').last,
        ),
      );

      try {
        var response = await request.send();
        var responseBody = await response.stream.bytesToString();
        var jsonResponse = json.decode(responseBody);

        // Navigate to another screen and pass the response
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResultScreen(response: jsonResponse),
          ),
        );
      } catch (e) {
        print('Error: $e');
        // Handle error
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('File Picker'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: _selectFile,
              child: Text('Select File'),
            ),
            if (_selectedFile != null)
              Text('Selected File: ${_selectedFile!.path}'),
          ],
        ),
      ),
    );
  }
}

class ResultScreen extends StatelessWidget {
  final Map<String, dynamic> response;

  const ResultScreen({required this.response});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Prediction Result'),
      ),
      body: Center(
        child: Text(
          'Predicted Class: ${response["Predicted class"]}',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}



