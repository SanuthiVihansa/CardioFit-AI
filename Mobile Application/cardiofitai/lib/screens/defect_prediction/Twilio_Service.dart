import 'package:twilio_flutter/twilio_flutter.dart';

class TwilioService {
  final TwilioFlutter _twilioFlutter;

  TwilioService()
      : _twilioFlutter = TwilioFlutter(
    accountSid: 'your_account_sid', // Replace with your Account SID
    authToken: 'your_auth_token',   // Replace with your Auth Token
    twilioNumber: 'your_twilio_number', // Replace with your Twilio Number
  );

  Future<void> sendSms(String contactNumber, String message) async {
    try {
      await _twilioFlutter.sendSMS(
        toNumber: contactNumber,
        messageBody: message,
      );
    } catch (e) {
      print('Failed to send SMS: $e');
    }
  }
}
