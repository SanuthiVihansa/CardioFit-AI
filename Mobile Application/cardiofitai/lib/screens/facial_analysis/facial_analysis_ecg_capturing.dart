import 'dart:convert';
import 'dart:io';
import 'package:cardiofitai/screens/facial_analysis/temp_all_lead_prediction_screen.dart';
import 'package:cardiofitai/screens/facial_analysis/temp_file_selection_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

import 'facial_analysis_prediction_display_screen.dart';

class CameraPage extends StatefulWidget {
  const CameraPage(this._width, this._height, {Key? key})
      : super(
            key:
                key); // Key? key means that the constructor accepts an optional parameter named key of type Key

  // Height and width of current device
  final double _width, _height;

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  // VARIABLES

  // dev device width and height
  // vertical
  final double _vDevWidth = 800.0;
  final double _vDevHeight = 1220.0;

  // horizontal
  // final double _hDevWidth = 1280.0;
  // final double _hDevHeight = 740.0;

  bool _isLoading = true;
  bool _isRecording = false;
  bool _isCancelled = false;
  bool _isVideoCaptured = false;
  late CameraController _cameraController;

  // paddings and sizes
  final double recordBtnBottomPadding = 200;
  final double recordingBtnLeftRightPadding = 150;
  final double recordingBtnIconSize = 30;
  final double messageFontSize = 15;
  final double toastFontSize = 10;
  final double messageTopPadding = 200;
  final double helpIconSize = 70;

  late double responsiveRecordBtnBottomPadding =
      widget._height / (_vDevHeight / recordBtnBottomPadding);
  late double responsiveRecordingBtnIconSize =
      widget._height / (_vDevHeight / recordingBtnIconSize);
  late double responsiveMessageFontSize =
      widget._width / (_vDevWidth / messageFontSize);
  late double responsiveToastFontSize =
      widget._width / (_vDevWidth / toastFontSize);
  late double responsiveRecordingBtnLeftRightPadding =
      widget._width / (_vDevWidth / recordingBtnLeftRightPadding);
  late double responsiveMessageTopPadding =
      widget._height / (_vDevHeight / messageTopPadding);
  late double responsiveHelpIconSize =
      widget._height / (_vDevHeight / helpIconSize);

  //
  String message = "Please make sure your face\n is visible in the camera";

  // ECG plot variables and methods
  late List<double> _tenSecData = [];
  double _maxValue = 0;
  double _minValue = 0;
  final String _upServerUrl =
      'http://poornasenadheera100.pythonanywhere.com/upforunet';

  late List<double> _l1Data = [];
  late List<double> _l2Data = [];
  late List<double> _v1Data = [];
  late List<double> _v2Data = [];
  late List<double> _v3Data = [];
  late List<double> _v4Data = [];
  late List<double> _v5Data = [];
  late List<double> _v6Data = [];

  late List<dynamic> _l1StringData = [];
  late List<dynamic> _l2StringData = [];
  late List<dynamic> _v1StringData = [];
  late List<dynamic> _v2StringData = [];
  late List<dynamic> _v3StringData = [];
  late List<dynamic> _v4StringData = [];
  late List<dynamic> _v5StringData = [];
  late List<dynamic> _v6StringData = [];

  // METHODS
  @override
  void initState() {
    // starting flask server
    _upServer();

    // setting device orientation for current screen
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // initialize camera
    _initCamera();

    // showing dialog box with instructions
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      showInfoDialog(context);
    });

    super.initState();
  }

  @override
  void dispose() {
    // setting device orientation
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    // dispose camera
    _cameraController.dispose();
    super.dispose();
  }

  // displayInformationDialog method
  void showInfoDialog(BuildContext context){
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: const Text("Instructions"),
              content: const Text(
                  "1. Make sure to be in a bright environment\n"
                  "2. Make sure your face is clearly visible in the camera\n"
                  "3. Try to stay as still as possible while recording\n"
                  "4. Recording will stop automatically after 10 seconds"),
              actions: [
                TextButton(
                  child: const Text("OK"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ]);
        });
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
          callToast('Recording cancelled');

          message = "Please make sure your face\n is visible in the camera";
          setState(() {
            _isRecording = false;
            _isVideoCaptured = false;
            _isCancelled = true;
          });

          deleteSpecificFile(file.path);

          if (kDebugMode) {
            print('File deleted with path: ${file.path}');
          }
        }
      });
    } else {
      await _cameraController.prepareForVideoRecording();
      await _cameraController.startVideoRecording();
      message = "Try not to move your face\n while recording...";
      callToast('Recording started...');
      setState(() {
        _isVideoCaptured = false;
        _isRecording = true;
      });

      // Stop recording after 10 seconds
      Future.delayed(const Duration(seconds: 10), () async {
        if (_isRecording) {
          setState(() {
            _isCancelled = false;
          });
          await _cameraController.stopVideoRecording().then((XFile? file) {
            //saves the file temporarily
            if (file != null) {
              // show snackbar
              callToast('Recording completed');
              _pickFile();

              message = "Please make sure your face\n is visible in the camera";
              setState(() {
                _isVideoCaptured = true;
                _isRecording = false;
              });
              if (kDebugMode) {
                print('Video saved to path: ${file.path}');
              }
            }
          });
        }
      });
    }
  }

  // delete all files in a directory
  Future<void> deleteAllFiles(String path) async {
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
            await file.delete();
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

  Future<void> deleteSpecificFile(String path) async {
    try {
      File file = File(path);
      if (file.existsSync()) {
        await file.delete();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting file: $e');
      }
    }
  }

  void callToast(String msg) {
    Toast duration = Toast.LENGTH_LONG;
    if (msg == 'Processing image...') {
      duration = Toast.LENGTH_SHORT;
    }

    Fluttertoast.showToast(
        msg: msg,
        toastLength: duration,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 3,
        backgroundColor: Colors.redAccent,
        textColor: Colors.white,
        fontSize: responsiveToastFontSize);
  }

  void _onTapViewECGBtn(BuildContext context) {
    // Navigator.push(
    //     context,
    //     MaterialPageRoute(
    //         builder: (BuildContext context) =>
    //             AllLeadPredictionScreen(_tenSecData)));
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) => TempAllLeadPredictionScreen(
                _l1Data,
                _l2Data,
                _v1Data,
                _v2Data,
                _v3Data,
                _v4Data,
                _v5Data,
                _v6Data)));

    // Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => TempFileSelectionScreen()));
  }

  void _pickFile() async {
    //emulator path
    // final file = File(
    //     '/data/user/0/com.spsh.cardiofitai/cache/file_picker/1714665116141/record1.txt');
    // actual device path
    final file = File(
        '/data/user/0/com.spsh.cardiofitai/cache/file_picker/1714673853720/record1.txt');

    String contents = await file.readAsString();

    Map<String, dynamic> jsonData = jsonDecode(contents);

    _l1StringData = jsonData["l1"];
    _l2StringData = jsonData["l2"];
    _v1StringData = jsonData["v1"];
    _v2StringData = jsonData["v2"];
    _v3StringData = jsonData["v3"];
    _v4StringData = jsonData["v4"];
    _v5StringData = jsonData["v5"];
    _v6StringData = jsonData["v6"];

    _l1Data =
        _l1StringData.map((item) => double.parse(item.toString())).toList();
    _l2Data =
        _l2StringData.map((item) => double.parse(item.toString())).toList();
    _v1Data =
        _v1StringData.map((item) => double.parse(item.toString())).toList();
    _v2Data =
        _v2StringData.map((item) => double.parse(item.toString())).toList();
    _v3Data =
        _v3StringData.map((item) => double.parse(item.toString())).toList();
    _v4Data =
        _v4StringData.map((item) => double.parse(item.toString())).toList();
    _v5Data =
        _v5StringData.map((item) => double.parse(item.toString())).toList();
    _v6Data =
        _v6StringData.map((item) => double.parse(item.toString())).toList();

    _calcMinMax(_l2Data);
    setState(() {});

    await DefaultCacheManager().emptyCache();
  }

  Future<void> _upServer() async {
    await http.get(Uri.parse(_upServerUrl), headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    });
  }

  void _calcMinMax(List<double> data) {
    _minValue =
        data.reduce((value, element) => value < element ? value : element) -
            0.1;
    _maxValue =
        data.reduce((value, element) => value > element ? value : element) +
            0.1;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
        onPopInvoked: (didPop) async {
          await SystemChrome.setPreferredOrientations([
            DeviceOrientation.landscapeLeft,
            DeviceOrientation.landscapeRight,
          ]);
        },
        child: _isLoading
            ? Container(
                color: Colors.white,
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              )
            : Scaffold(
                appBar: AppBar(
                  foregroundColor: Colors.white,
                  title: const Text(
                    "Capturing ECG through Facial Analysis",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  backgroundColor: Colors.red,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      // Navigator.pop(context);
                      SystemChrome.setPreferredOrientations([
                        DeviceOrientation.landscapeLeft,
                        DeviceOrientation.landscapeRight,
                      ]);

                      Navigator.pop(context);
                    },
                  ),
                ),
                backgroundColor: Colors.black,
                body: Center(
                  child: Stack(alignment: Alignment.center, children: [
                    Positioned.fill(child: CameraPreview(_cameraController)),
                    Padding(
                      padding: EdgeInsets.only(
                          right: _isVideoCaptured
                              ? responsiveRecordingBtnLeftRightPadding
                              : 0,
                          bottom: responsiveRecordBtnBottomPadding),
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: FloatingActionButton(
                          backgroundColor: Colors.white,
                          shape: const CircleBorder(),
                          child: Icon(
                            _isRecording ? Icons.stop : Icons.circle,
                            color: Colors.red,
                            size: _isRecording
                                ? responsiveRecordingBtnIconSize
                                : responsiveRecordingBtnIconSize + 10,
                          ),
                          onPressed: () {
                            // String path = '/data/user/0/com.spsh.cardiofitai/cache/';
                            // deleteAllFiles(path);
                            _recordVideo();
                          },
                        ),
                      ),
                    ),
                    _isVideoCaptured
                        ? Padding(
                            padding: EdgeInsets.only(
                                left: responsiveRecordingBtnLeftRightPadding,
                                bottom: responsiveRecordBtnBottomPadding),
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: FloatingActionButton.extended(
                                onPressed: () {
                                  _onTapViewECGBtn(context);
                                },
                                label: const Text('View ECG reading'),
                                icon: const Icon(Icons.file_present_rounded),
                              ),
                            ),
                          )
                        : Container(),
                    Container(
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: IconButton(
                          onPressed: () {
                            showInfoDialog(context);
                          },
                          icon: Icon(Icons.help_outline_sharp,
                              color: Colors.white,
                              size: responsiveHelpIconSize),
                        ),
                      ),
                    )
                    // Padding(
                    //   padding: EdgeInsets.only(top: responsiveMessageTopPadding),
                    //   child: Align(
                    //     alignment: AlignmentDirectional.topCenter,
                    //     child: Stack(
                    //       children: [
                    //         Text(
                    //           message,
                    //           style: TextStyle(
                    //             // color: Colors.black,
                    //             fontSize: responsiveMessageFontSize,
                    //             fontStyle: FontStyle.italic,
                    //             foreground: Paint()
                    //               ..style = PaintingStyle.stroke
                    //               ..strokeWidth = 6
                    //               ..color = Colors.white,
                    //           ),
                    //         ),
                    //         Text(
                    //           message,
                    //           style: TextStyle(
                    //             fontSize: responsiveMessageFontSize,
                    //             color: Colors.black,
                    //           ),
                    //         ),
                    //       ],
                    //     ),
                    //   ),
                    // ),
                  ]),
                ),
              ));
  }
}
