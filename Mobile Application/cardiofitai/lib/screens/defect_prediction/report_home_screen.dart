
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart'; // Import FilePicker package
import 'dart:io'; // Import dart:io to use File class
import 'ecg_plot.dart'; // Import the ECGPlotScreen

class ReportHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image on the left
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: MediaQuery.of(context).size.width * 0.65, // Cover 65% of the screen width
            child: Image.asset(
              'assets/defect_prediction/ECGHome.png', // Replace with your image path
              fit: BoxFit.cover, // Cover the entire available space
            ),
          ),
          // Logo on the right with padding
          Positioned(
            right: MediaQuery.of(context).size.width * 0.02, // Position it with 5% space from the right edge
            top: MediaQuery.of(context).size.height * 0.2, // Adjust vertical position as needed
            child: ClipOval(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.30, // Cover 30% of the screen width
                height: MediaQuery.of(context).size.width * 0.30, // Make it a square
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/defect_prediction/Logo CarioFit Ai.jpg'), // Replace with your logo image path
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
          // Curved wave shape
          ClipPath(
            clipper: MyCustomClipper(), // Custom clipper for the wave shape
            child: Container(
              color: Colors.white.withOpacity(0.7), // Add some transparency
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
            ),
          ),
          // Upload ECG File picker on the right bottom
          Positioned(
            right: MediaQuery.of(context).size.width * 0.05, // Position it on the right 5% of the screen width
            bottom: 16,
            child: ElevatedButton.icon(
              onPressed: () async {
                // Open file picker to upload ECG file
                FilePickerResult? result = await FilePicker.platform.pickFiles(
                  type: FileType.custom,
                  allowedExtensions: ['txt'],
                );
                if (result != null) {
                  // Navigate to ECGPlotScreen when file is uploaded
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ECGDiagnosisScreen(file: File(result.files.single.path!))),
                  );
                }
              },
              icon: Icon(
                Icons.upload_file, // Use the upload file icon
                size: 24, // Adjust icon size as needed
              ),
              label: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12), // Adjust button padding
                child: Text(
                  'Upload ECG File',
                  style: TextStyle(color: Colors.white), // Set text color to white
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black, // Red button color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0), // Make button more round
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom clipper class for the wave shape
class MyCustomClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0.0, size.height * 0.5); // Start point at bottom left

    // Define the curve for the wave shape
    path.quadraticBezierTo(size.width / 3, size.height * 0.3, size.width * 2 / 3, size.height * 0.6);
    path.lineTo(size.width, size.height); // Connect to bottom right
    path.lineTo(0.0, size.height); // Connect to bottom left
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

