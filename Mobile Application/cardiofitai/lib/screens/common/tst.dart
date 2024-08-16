import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

//const
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  Future<void> _register() async {
    final String name = _nameController.text;
    final String phone = _phoneController.text;

    // Replace with your Notify.lk API key and sender ID
    final String apiKey = 'jDkkmVFn2VkdIdOWCLvw';
    final String senderId = '27374';

    final response = await http.post(
      Uri.parse('https://app.notify.lk/api/v1/send'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'user_id': apiKey,
        'api_key': apiKey,
        'sender_id': senderId,
        'to': phone,
        'message': 'Hey $name, you have registered successfully!',
      }),
    );

    final responseData = jsonDecode(response.body);
    if (responseData['status'] == 'success') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registered successfully!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to register: ${responseData['message']}')),
      );
    }
  }

  String? _validatePhoneNumber(String? value) {
    final pattern = RegExp(r'^\+94\d{9}$');
    if (value == null || value.isEmpty) {
      return 'Please enter your phone number';
    } else if (!pattern.hasMatch(value)) {
      return 'Please enter a valid Sri Lankan phone number (+94XXXXXXXXX)';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Register')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(labelText: 'Phone Number'),
                validator: _validatePhoneNumber,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _register();
                  }
                },
                child: Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

