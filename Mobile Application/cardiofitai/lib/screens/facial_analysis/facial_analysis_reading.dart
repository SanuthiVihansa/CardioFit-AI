import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class FacialAnalysisReading extends StatefulWidget {
  const FacialAnalysisReading({super.key});

  @override
  State<FacialAnalysisReading> createState() => _FacialAnalysisReadingState();
}

class _FacialAnalysisReadingState extends State<FacialAnalysisReading> {
  late List<CameraDescription> cameras;
  late CameraController cameraController;

  int direction = 0;

  //camera window padding values
  double leftBottomPadding = 20;
  double heightWidthPadding = 50;

  @override
  void initState() {
    startCamera(0);
    super.initState();
  }

  void startCamera(int direction) async {
    // WidgetsFlutterBinding.ensureInitialized();

    cameras = await availableCameras();

    cameraController = CameraController(
        cameras[direction],
        ResolutionPreset.high,
        enableAudio: false);

    await cameraController.initialize().then((value) {
      if(!mounted){
        return;
      }
      setState(() {});
    }).catchError((e) {
      if (kDebugMode) {
        print(e);
      }
    });
  }

  @override
  void dispose(){
    cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if(cameraController.value.isInitialized){
      return Scaffold(
        body: Stack(
          children: [
            CameraPreview(cameraController),
            GestureDetector(
              onTap: (){
                cameraController.takePicture().then((XFile? file) {
                  if(mounted) {
                    if(file != null){
                      if (kDebugMode) {
                        print("Picture saved to ${file.path}");
                      }
                    }
                  }
                });
              },
              child: button(Icons.camera_alt_outlined, Alignment.bottomLeft),
            ),
            GestureDetector(
              onTap: (){
                direction = direction == 0 ? 1 : 0;
                startCamera(direction);
              },
              child: button(Icons.camera, Alignment.bottomCenter),
            ),
            Align(
              alignment: AlignmentDirectional.topCenter,
              child: Text(
                "Please make sure your face is visible in the camera",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
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

  Widget button(IconData icon, Alignment alignment){
    return Align(
      alignment: alignment,
      child: Container(
        margin: EdgeInsets.only(
            left: leftBottomPadding,
            bottom: leftBottomPadding
        ),
        height: heightWidthPadding,
        width: heightWidthPadding,
        decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                  color: Colors.black,
                  offset: Offset(2, 2),
                  blurRadius: 5
              )
            ]
        ),
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
