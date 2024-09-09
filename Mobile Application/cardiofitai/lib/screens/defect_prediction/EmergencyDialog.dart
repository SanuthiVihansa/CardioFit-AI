import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import '../../services/Location_Service.dart';

class EmergencyDialog extends StatelessWidget {
  final String contactNumber;

  const EmergencyDialog({Key? key, required this.contactNumber}) : super(key: key);

  Future<void> _sendSms(String contactNumber, String message) async {
    final String apiKey = 'AUS4ssj4nA8vBGpJgyZX'; // Replace with your notify.lk API key
    final String senderId = 'NotifyDEMO'; // Replace with your sender ID (if any)

    try {
      final response = await http.post(
        Uri.parse('https://app.notify.lk/api/v1/send'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'user_id': '27903', // Replace with your user ID
          'api_key': apiKey,
          'sender_id': senderId,
          'to': contactNumber,
          'message': message,
        }),
      );

      if (response.statusCode == 200) {
        print('SMS sent successfully');
      } else {
        print('Failed to send SMS: ${response.body}');
      }
    } catch (e) {
      print('Failed to send SMS: $e');
    }
  }

  void _handleOkPressed(BuildContext context) async {
    try {
      Position position = await LocationService.getCurrentLocation();
      String message = 'Greetings,\n\n'
          'This is an urgent notification from CardioFitAI. Your loved one has been diagnosed with a critical condition and requires immediate attention. '
          'The current location of the user is provided below:\n\n'
          'Location: https://www.google.com/maps/search/?api=1&query=${position.latitude},${position.longitude}\n\n'
          'Please act promptly to ensure their safety.\n\n'
          'Regards,\n'
          'CardioFitAI Team';
      await _sendSms(contactNumber, message); // Use notify.lk to send SMS
      Navigator.of(context).pop();
    } catch (e) {
      print('Failed to get location or send SMS: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Container(
        padding: EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.warning,
              color: Colors.red,
              size: 60,
            ),
            SizedBox(height: 20),
            Text(
              'Emergency! Contact Immediately!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Text(
              'Incomplete Right Bundle Branch Block detected. Contact the following number:',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            Text(
              contactNumber,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              onPressed: () {
                _handleOkPressed(context);
              },
              child: Text('OK'),
            ),
          ],
        ),
      ),
    );
  }
}
