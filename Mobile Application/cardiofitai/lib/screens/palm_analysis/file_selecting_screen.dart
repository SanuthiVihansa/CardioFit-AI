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
        onPressed: () {},
      )),
    );
  }
}
