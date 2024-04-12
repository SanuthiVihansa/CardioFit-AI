import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:io';

class FacialAnalysisReading extends StatefulWidget {
  const FacialAnalysisReading({super.key});

  @override
  State<FacialAnalysisReading> createState() => _FacialAnalysisReadingState();
}

class _FacialAnalysisReadingState extends State<FacialAnalysisReading> {
  // VARIABLES
  // list of all available cameras in the device
  late List<CameraDescription> cameras;

  // controller to manipulate the camera
  late CameraController cameraController;

  // camera direction, indicate front and back camera
  int direction = 1;

  //camera window padding values
  double leftBottomPadding = 20;
  double heightWidthPadding = 50;

  // METHODS
  @override
  void initState() {
    startCamera(direction);
    super.initState();
  }

  // method to start the camera
  void startCamera(int direction) async {
    // WidgetsFlutterBinding.ensureInitialized();

    // get all available cameras
    cameras = await availableCameras();

    cameraController = CameraController(
        cameras[direction], ResolutionPreset.high,
        enableAudio: false);

    await cameraController.initialize().then((value) {
      if (!mounted) {
        return;
      }
      setState(() {});
    }).catchError((e) {
      if (kDebugMode) {
        print(e);
      }
    });
  }

  //method to delete all .jpg files in a given path
  void deleteAllJpgFiles(String path) async {
    try {
      Directory directory = Directory(path);
      if (directory.existsSync()) {
        List<FileSystemEntity> files = directory.listSync(recursive: false);
        int i = 0;
        for (FileSystemEntity file in files) {
          if (file is File && file.path.endsWith('.jpg')) {
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
  // deleteAllJpgFiles(path);

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (cameraController.value.isInitialized) {
      return Scaffold(
        body: Stack(
          children: [
            CameraPreview(cameraController),
            GestureDetector(
              onTap: () {
                cameraController.takePicture().then((XFile? file) {
                  if (mounted) {
                    if (file != null) {
                      if (kDebugMode) {
                        print("Picture saved to ${file.path}");
                      }
                    }
                  }
                });
              },
              child: button(Icons.camera_alt_outlined, Alignment.bottomCenter),
            ),
            const Align(
              alignment: AlignmentDirectional.topCenter,
              child: Text(
                "Please make sure your face is visible in the camera",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      return const SizedBox();
    }
  }

  Widget button(IconData icon, Alignment alignment) {
    return Align(
      alignment: alignment,
      child: Container(
        margin:
        EdgeInsets.only(left: leftBottomPadding, bottom: leftBottomPadding),
        height: heightWidthPadding,
        width: heightWidthPadding,
        decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                  color: Colors.black, offset: Offset(2, 2), blurRadius: 5)
            ]),
        child: Center(
          child: Icon(
            icon,
            color: Colors.black54,
          ),
        ),
      ),
    );
  }
}
