import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FileSelectingScreen extends StatefulWidget {
  const FileSelectingScreen({super.key});

  @override
  State<FileSelectingScreen> createState() => _FileSelectingScreenState();
}

class _FileSelectingScreenState extends State<FileSelectingScreen> {
  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
  }

  void _pickFile() async {
    // opens storage to pick files and the picked file or files
    // are assigned into result and if no file is chosen result is null.
    // you can also toggle "allowMultiple" true or false depending on your need
    final result = await FilePicker.platform.pickFiles(allowMultiple: false);

    // if no file is picked
    if (result == null) return;

    // we will log the name, size and path of the
    // first picked file (if multiple are selected)
    print(result.files.first.name);
    print(result.files.first.size);
    print(result.files.first.path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("File Selector"),
        backgroundColor: Colors.red,
      ),
      body: Center(
          child: ElevatedButton(
        child: const Text("Select file"),
        onPressed: () {
          _pickFile();
        },
      )),
    );
  }
}
