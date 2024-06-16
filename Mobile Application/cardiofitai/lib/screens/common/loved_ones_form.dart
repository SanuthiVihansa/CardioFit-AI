import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class EmergencyContactsPage extends StatefulWidget {
  const EmergencyContactsPage({super.key});

  @override
  State<EmergencyContactsPage> createState() => _EmergencyContactsPageState();
}

class _EmergencyContactsPageState extends State<EmergencyContactsPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _relationshipController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  late double _width;
  late double _height;

  // Name Field Validation
  String? _validateName(String? text) {
    if (text == null || text.isEmpty) {
      return "Name is required!";
    }
    return null;
  }

  // Relationship Field Validation
  String? _validateRelationship(String? text) {
    if (text == null || text.isEmpty) {
      return "Relationship is required!";
    }
    return null;
  }

  // Phone Field Validation
  String? _validatePhone(String? text) {
    if (text == null || text.isEmpty) {
      return "Phone number is required!";
    } else if (!RegExp(r'^\+?[0-9]{7,15}$').hasMatch(text)) {
      return "Invalid phone number!";
    }
    return null;
  }

  // Email Field Validation
  String? _validateEmail(String? text) {
    if (text == null || text.isEmpty) {
      return "Email is required!";
    } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(text)) {
      return "Invalid email address!";
    }
    return null;
  }

  Future<void> _onSaveContact() async {
    // Here you would typically send the contact data to your backend or save it locally
    Fluttertoast.showToast(
        msg: "Contact Saved Successfully!🎉",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  @override
  Widget build(BuildContext context) {
    _width = MediaQuery.of(context).size.width;
    _height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Emergency Contacts"),
      ),
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.contacts,
                size: 50,
              ),
              const Text("Emergency Contacts",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const Text("Enter details of your loved ones"),
              Form(
                key: _formKey,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: _width / 7.85),
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(_width / 49.09),
                        child: TextFormField(
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.next,
                          controller: _nameController,
                          validator: _validateName,
                          onSaved: (text) {},
                          decoration: InputDecoration(
                            hintText: 'John Doe',
                            prefixIcon: const Icon(Icons.person),
                            suffixIcon: _nameController.text.isEmpty
                                ? null
                                : IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () {
                                setState(() {
                                  _nameController.clear();
                                });
                              },
                            ),
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(_width / 49.09),
                        child: TextFormField(
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.next,
                          controller: _relationshipController,
                          validator: _validateRelationship,
                          onSaved: (text) {},
                          decoration: InputDecoration(
                            hintText: 'Relationship',
                            prefixIcon: const Icon(Icons.group),
                            suffixIcon: _relationshipController.text.isEmpty
                                ? null
                                : IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () {
                                setState(() {
                                  _relationshipController.clear();
                                });
                              },
                            ),
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(_width / 49.09),
                        child: TextFormField(
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.next,
                          controller: _phoneController,
                          validator: _validatePhone,
                          onSaved: (text) {},
                          decoration: InputDecoration(
                            hintText: '+1234567890',
                            prefixIcon: const Icon(Icons.phone),
                            suffixIcon: _phoneController.text.isEmpty
                                ? null
                                : IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () {
                                setState(() {
                                  _phoneController.clear();
                                });
                              },
                            ),
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(_width / 49.09),
                        child: TextFormField(
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.done,
                          controller: _emailController,
                          validator: _validateEmail,
                          onSaved: (text) {},
                          decoration: InputDecoration(
                            hintText: 'name@example.com',
                            prefixIcon: const Icon(Icons.mail),
                            suffixIcon: _emailController.text.isEmpty
                                ? null
                                : IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () {
                                setState(() {
                                  _emailController.clear();
                                });
                              },
                            ),
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: _height / 26.76),
                        child: ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor:
                            MaterialStateProperty.all<Color>(Colors.white),
                            shape: MaterialStateProperty.all<OutlinedBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(0),
                                side: const BorderSide(color: Colors.black, width: 2.0),
                              ),
                            ),
                          ),
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              _formKey.currentState?.save();
                              _onSaveContact();
                            }
                          },
                          child: const Text(
                            "SAVE CONTACT",
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
