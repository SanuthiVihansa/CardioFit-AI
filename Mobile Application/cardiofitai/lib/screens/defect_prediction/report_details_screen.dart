import 'package:flutter/material.dart';

class ReportDetailsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Report'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // First Field to upload text file
            const FileUploadField(label: 'Upload ECG Text File'),

            // Second Field to upload text file
            const FileUploadField(label: 'Upload Additional Details Text File'),

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Handle submission here
                // This is where you would plot the ECG
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}

class FileUploadField extends StatelessWidget {
  final String label;

  const FileUploadField({
    Key? key,
    required this.label,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            decoration: InputDecoration(
              labelText: label,
              border: const OutlineInputBorder(),
            ),
            readOnly: true,
          ),
        ),
        const SizedBox(width: 10),
        ElevatedButton(
          onPressed: () {
            // Handle file upload here
          },
          child: const Text('Upload'),
        ),
      ],
    );
  }
}
