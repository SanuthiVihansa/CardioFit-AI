import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

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
    final result = await FilePicker.platform.pickFiles(allowMultiple: false);

    if (result == null) return;

    final file = File(result.files.single.path.toString());
    String contents = await file.readAsString();
    contents = contents.substring(1);
    // print(contents);

    List<double> dataList = contents.split(',').map((String value) {
      return double.tryParse(value) ?? 0.0;
    }).toList();

    List<double> tenSecData = dataList.sublist(0, 2560);

    print(tenSecData);

    await DefaultCacheManager().emptyCache();
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
