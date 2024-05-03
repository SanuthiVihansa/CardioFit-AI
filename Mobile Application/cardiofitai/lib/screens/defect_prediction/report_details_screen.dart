// //
// // import 'package:flutter/material.dart';
// // import 'package:flutter/services.dart';
// // import 'package:file_picker/file_picker.dart';
// //
// // class ReportDetailsScreen extends StatefulWidget {
// //   const ReportDetailsScreen({Key? key}) : super(key: key);
// //
// //   @override
// //   State<ReportDetailsScreen> createState() => _ReportDetailsScreenState();
// // }
// //
// // class _ReportDetailsScreenState extends State<ReportDetailsScreen> {
// //   void initState() {
// //     super.initState();
// //
// //     SystemChrome.setPreferredOrientations(
// //         [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
// //   }
// //
// //   void _pickFile() async {
// //     final result = await FilePicker.platform.pickFiles(allowMultiple: false);
// //     if (result == null) return;
// //
// //     print(result.files.first.name);
// //     print(result.files.first.size);
// //     print(result.files.first.path);
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: Text("File Selector"),
// //         backgroundColor: Colors.red,
// //       ),
// //       body: Stack(
// //         children: [
// //           // Background GIF
// //           Positioned.fill(
// //             child: Image.asset(
// //               'assets/defect_prediction/ECG Gif.gif', // Path to your GIF file
// //               fit: BoxFit.cover,
// //             ),
// //           ),
// //           // Content
// //           Center(
// //             child: ElevatedButton(
// //               onPressed: _pickFile,
// //               child: const Text("Select file"),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }
//
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:file_picker/file_picker.dart';
// import 'prediction_results_screen.dart';
//
// void main() {
//   runApp(MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Predict Disease',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: ReportDetailsScreen(),
//     );
//   }
// }
//
// class ReportDetailsScreen extends StatefulWidget {
//   const ReportDetailsScreen({Key? key}) : super(key: key);
//
//   @override
//   State<ReportDetailsScreen> createState() => _ReportDetailsScreenState();
// }
//
// class _ReportDetailsScreenState extends State<ReportDetailsScreen> {
//   void initState() {
//     super.initState();
//
//     SystemChrome.setPreferredOrientations([
//       DeviceOrientation.landscapeLeft,
//       DeviceOrientation.landscapeRight
//     ]);
//   }
//
//   void _pickFile() async {
//     final result = await FilePicker.platform.pickFiles(allowMultiple: false);
//     if (result == null) return;
//
//     print(result.files.first.name);
//     print(result.files.first.size);
//     print(result.files.first.path);
//   }
//
//   void _predictDisease(BuildContext context) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => PredictionResultsScreen(predictedDisease: 'PVC'),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("File Selector"),
//         backgroundColor: Colors.red,
//       ),
//       body: Stack(
//         children: [
//           // Background GIF
//           Positioned.fill(
//             child: Image.asset(
//               'assets/defect_prediction/ECG Gif.gif', // Path to your GIF file
//               fit: BoxFit.cover,
//             ),
//           ),
//           // Content
//           Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 ElevatedButton(
//                   onPressed: _pickFile,
//                   child: const Text("Select file"),
//                 ),
//                 SizedBox(height: 20),
//                 ElevatedButton(
//                   onPressed: () => _predictDisease(context),
//                   child: const Text("Predict Diseases"),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
//
//
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'prediction_results_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Predict Disease',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ReportDetailsScreen(),
    );
  }
}

class ReportDetailsScreen extends StatefulWidget {
  const ReportDetailsScreen({Key? key}) : super(key: key);

  @override
  State<ReportDetailsScreen> createState() => _ReportDetailsScreenState();
}

class _ReportDetailsScreenState extends State<ReportDetailsScreen> {
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
  }

  void _pickFile() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: false);
    if (result == null) return;

    print(result.files.first.name);
    print(result.files.first.size);
    print(result.files.first.path);
  }

  void _predictPVC(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PredictionResultsScreen(predictedDisease: 'PVC'),
      ),
    );
  }

  void _predictNormal(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            PredictionResultsScreen(predictedDisease: 'Normal'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: Text(
          "File Selector",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.red,
      ),
      body: Stack(
        children: [
          // Background GIF
          Positioned.fill(
            child: Image.asset(
              'assets/defect_prediction/ECG Gif.gif', // Path to your GIF file
              fit: BoxFit.cover,
            ),
          ),
          // Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // First Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: _pickFile,
                      child: const Text("Select file"),
                    ),
                    ElevatedButton(
                      onPressed: () => _predictPVC(context),
                      child: const Text("Predict Diseases"),
                    ),
                  ],
                ),
                // Second Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: _pickFile,
                      child: const Text("Select file"),
                    ),
                    ElevatedButton(
                      onPressed: () => _predictNormal(context),
                      child: const Text("Predict Diseases"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
