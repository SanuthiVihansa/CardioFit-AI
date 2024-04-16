import 'dart:io';

import 'package:cardiofitai/screens/facial_analysis/video_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CameraPage extends StatefulWidget {
  CameraPage(this._width, this._height, {Key? key})
      : super(
            key:
                key); // Key? key means that the constructor accepts an optional parameter named key of type Key

  // Height and width of current device
  final double _width;
  final double _height;

  late double _vWidth;
  late double _vHeight;
  late double _hWidth;
  late double _hHeight;

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  // VARIABLES

  // current device width and height
  // vertical
  final double _vWidth = 800.0;
  final double _vHeight = 1220.0;

  // horizontal
  final double _hWidth = 1280.0;
  final double _hHeight = 740.0;

  bool _isLoading = true;
  bool _isRecording = false;
  late CameraController _cameraController;

  // paddings and sizes
  double recordBtnBottomPadding = 50;
  double recordingBtnIconSize = 25;

  //
  String message = "Please make sure your face is visible in the camera";

  // METHODS
  @override
  void initState() {
    // orientation
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // paddings and sizes
    recordBtnBottomPadding =
        _vHeight / (widget._height / recordBtnBottomPadding);

    // initialize camera
    _initCamera();
    super.initState();
  }

  @override
  void dispose() {
    // orientation
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    // dispose camera
    _cameraController.dispose();
    super.dispose();
  }

  // camera methods
  void _initCamera() async {
    final cameras = await availableCameras();
    final front = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front);
    _cameraController =
        CameraController(front, ResolutionPreset.max, enableAudio: false);
    await _cameraController.initialize();
    setState(() => _isLoading = false);
  }

  void _recordVideo() async {
    if (_isRecording) {
      await _cameraController.stopVideoRecording().then((XFile? file) {
        //saves the file temporarily
        if (file != null) {
          // show snackbar
          callToast('Recording completed');

          message = "Please make sure your face is visible in the camera";
          setState(() => _isRecording = false);

          // previews the video
          // final route = MaterialPageRoute(
          //   fullscreenDialog: true,
          //   builder: (_) => VideoPage(filePath: file.path),
          // );
          //
          // Navigator.push(context, route);

          if (kDebugMode) {
            print('Video saved to path: ${file.path}');
          }
        }
      });
    } else {
      await _cameraController.prepareForVideoRecording();
      await _cameraController.startVideoRecording();
      message = "";
      callToast('Recording started...');
      setState(() => _isRecording = true);

      // Stop recording after 10 seconds
      Future.delayed(const Duration(seconds: 10), () {
        if (_isRecording) {
          _recordVideo();
        }
      });
    }
  }

  // delete all files in a directory
  void deleteAllFiles(String path) {
    try {
      Directory directory = Directory(path);
      if (directory.existsSync()) {
        List<FileSystemEntity> files = directory.listSync(recursive: false);
        int i = 0;
        for (FileSystemEntity file in files) {
          if (file is File && file.path.endsWith('.mp4')) {
            if (kDebugMode) {
              i++;
              print('Deleting file: $i');
            }
            // await file.delete();
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting files: $e');
      }
    }
  }

  // String path = '/data/user/0/com.spsh.cardiofitai/cache/';
  // deleteAllFiles(path);

  void callToast(String msg) {
    Toast duration = Toast.LENGTH_LONG;
    if (msg == 'Processing image...') {
      duration = Toast.LENGTH_SHORT;
    }

    Fluttertoast.showToast(
        msg: msg,
        toastLength: duration,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: 3,
        backgroundColor: Colors.redAccent,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        color: Colors.white,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else {
      return Center(
        child: Stack(alignment: Alignment.bottomCenter, children: [
          CameraPreview(_cameraController),
          Padding(
              padding: EdgeInsets.only(bottom: recordBtnBottomPadding),
              child: FloatingActionButton(
                backgroundColor: Colors.white,
                shape: const CircleBorder(),
                child: Icon(
                  _isRecording ? Icons.stop : Icons.circle,
                  color: Colors.red,
                  size: recordingBtnIconSize,
                ),
                onPressed: () {
                  // String path = '/data/user/0/com.spsh.cardiofitai/cache/';
                  // deleteAllFiles(path);
                  _recordVideo();
                },
              )),
          Align(
            alignment: AlignmentDirectional.topCenter,
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ]),
      );
    }
  }
}
