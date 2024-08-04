import 'package:flutter/material.dart';

class EmergencyDialog extends StatelessWidget {
  final String contactNumber;

  const EmergencyDialog({Key? key, required this.contactNumber}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Emergency! Contact Immediately!'),
      content: Text('Incomplete Right Bundle Branch Block detected. Contact the following number: $contactNumber'),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('OK'),
        ),
      ],
    );
  }
}
