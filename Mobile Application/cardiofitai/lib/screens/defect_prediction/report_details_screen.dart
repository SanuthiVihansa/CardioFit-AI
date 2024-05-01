// import 'package:flutter/material.dart';
//
// class ReportDetailsScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Upload Report'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(20.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             // First Field to upload text file
//             const FileUploadField(label: 'Upload ECG Text File'),
//
//             // Second Field to upload text file
//             const FileUploadField(label: 'Upload Additional Details Text File'),
//
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () {
//                 // Handle submission here
//                 // This is where you would plot the ECG
//               },
//               child: const Text('Submit'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class FileUploadField extends StatelessWidget {
//   final String label;
//
//   const FileUploadField({
//     Key? key,
//     required this.label,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         Expanded(
//           child: TextFormField(
//             decoration: InputDecoration(
//               labelText: label,
//               border: const OutlineInputBorder(),
//             ),
//             readOnly: true,
//           ),
//         ),
//         const SizedBox(width: 10),
//         ElevatedButton(
//           onPressed: () {
//             // Handle file upload here
//           },
//           child: const Text('Upload'),
//         ),
//       ],
//     );
//   }
// }


import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ReportDetailsScreen extends StatefulWidget {
  const ReportDetailsScreen({super.key});

  @override
  State<ReportDetailsScreen> createState() => _FileSelectingScreenState();
}

class _FileSelectingScreenState extends State<ReportDetailsScreen> {
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
