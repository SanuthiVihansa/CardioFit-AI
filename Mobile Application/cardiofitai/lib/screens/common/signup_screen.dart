import 'package:cardiofitai/screens/common/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../models/response.dart';
import '../../services/user_information_service.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _memberNameController = TextEditingController();
  final TextEditingController _memberRelationshipController = TextEditingController();
  final TextEditingController _memberPhoneNoController = TextEditingController();
  late double _width;
  late double _height;

  //Name Field Validation
  String? _validateName(String text) {
    if (text == "") {
      return "Name is required!";
    }
    return null;
  }

  //Email Field Validation
  String? _validateEmail(String text) {
    if (text == "") {
      return "Email / Username is required!";
    } else if (!text.contains("@")) {
      return "Invalid email / username";
    }
    return null;
  }

//Validate new and existing passwords
  String? _validatePassword(String value) {
    if (value == '') {
      return "This field is required!";
    } else if (value.length < 8) {
      return "Password should have minimum 8 characters!";
    }
    return null;
  }

  String? _validateRetypePassword(String value) {
    if (value == '') {
      return "This field is required!";
    } else if (value != _newPasswordController.text) {
      return "Passwords do not match!";
    }
    return null;
  }

  //Member Name Field Validation
  String? _validateMemberName(String text) {
    if (text == "") {
      return " Member Name is required!";
    }
    return null;
  }
  //Member Relationship Field Validation
  String? _validateMemberRelationship(String text) {
    if (text == "") {
      return "Relationship is required!";
    }
    return null;
  }

  //Member Phone No Field Validation
  String? _validateMemberPhoneNo(String text) {
    if (text.isEmpty) {
      return "Member Phone No is required!";
    } else if (text.length != 11) {
      return "Phone Number must be 11 digits!";
    } else if (!text.startsWith("947")) {
      return "Phone Number must start with '947'!";
    } else if (!RegExp(r'^\d+$').hasMatch(text)) {
      return "Phone Number must contain only digits!";
    }
    return null;
  }




  Future<void> _onTapCreateAccount() async {
    Response response = await UserLoginService.addAccount(
        _nameController.text,
        _emailController.text,
        _passwordController.text,
        "",
        "",
        "",
        "",
        "",
        "",
        "user",
        "",
        "",
        "",
        "",
        _memberNameController.text,
        _memberRelationshipController.text,
        _memberPhoneNoController.text,
      true,""
    );
    if (response.code == 200) {
      Fluttertoast.showToast(
          msg: "Account Created Successfully!🎉",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0);
    } else {
      Fluttertoast.showToast(
          msg: "Opps !! We have trouble in signing, Please try again.☹️",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    _width = MediaQuery.of(context).size.width;
    _height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.only(
                    bottom: _height / 26.76363636363636,
                    left: _width / 6.545454545454545,
                    right: _width / 6.545454545454545),
                child: const Icon(
                  Icons.account_circle,
                  size: 50,
                ),
              ),
              const Text("H E L L O   T H E R E ! ",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const Text("Register below with details"),
              Form(
                key: _formKey,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: _width / 7.854545454545454),
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(_width / 49.09090909090909),
                        child: TextFormField(
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.next,
                          controller: _nameController,
                          validator: (text) {
                            return _validateName(text!);
                          },
                          onSaved: (text) {},
                          decoration: InputDecoration(
                            labelText: "User Name",
                            hintText: 'Sara Lauranco',
                            prefixIcon: const Icon(Icons.person),
                            suffixIcon: _nameController.text.isEmpty
                                ? Container(width: 0)
                                : IconButton(
                                    icon: const Icon(Icons.close),
                                    onPressed: () => _nameController.clear(),
                                  ),
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(_width / 49.09090909090909),
                        child: TextFormField(
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          controller: _emailController,
                          validator: (text) {
                            return _validateEmail(text!);
                          },
                          onSaved: (text) {},
                          decoration: InputDecoration(
                            labelText: "User Email",
                            hintText: 'name@gmail.com',
                            prefixIcon: const Icon(Icons.mail),
                            suffixIcon: _emailController.text.isEmpty
                                ? Container(width: 0)
                                : IconButton(
                                    icon: const Icon(Icons.close),
                                    onPressed: () => _emailController.clear(),
                                  ),
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(_width / 49.09090909090909),
                        child: TextFormField(
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.next,
                          controller: _memberNameController,
                          validator: (text) {
                            return _validateMemberName(text!);
                          },
                          onSaved: (text) {},
                          decoration: InputDecoration(
                            labelText: "Guardian Name",
                            hintText: 'Sara James',
                            prefixIcon: const Icon(Icons.person),
                            suffixIcon: _memberNameController.text.isEmpty
                                ? Container(width: 0)
                                : IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () => _memberNameController.clear(),
                            ),
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(_width / 49.09090909090909),
                        child: TextFormField(
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.next,
                          controller: _memberRelationshipController,
                          validator: (text) {
                            return _validateMemberRelationship(text!);
                          },
                          onSaved: (text) {},
                          decoration: InputDecoration(
                            labelText: "Guardian Relationship",
                            hintText: 'Mother',
                            prefixIcon: const Icon(Icons.person),
                            suffixIcon: _memberRelationshipController.text.isEmpty
                                ? Container(width: 0)
                                : IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () => _memberRelationshipController.clear(),
                            ),
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(_width / 49.09090909090909),
                        child: TextFormField(
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.next,
                          controller: _memberPhoneNoController,
                          validator: (text) {
                            return _validateMemberPhoneNo(text!);
                          },
                          onSaved: (text) {},
                          decoration: InputDecoration(
                            labelText: "Mobile Number",
                            hintText: '94711111111',
                            prefixIcon: const Icon(Icons.person),
                            suffixIcon: _memberPhoneNoController.text.isEmpty
                                ? Container(width: 0)
                                : IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () => _memberPhoneNoController.clear(),
                            ),
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(_width / 49.09090909090909),
                        child: TextFormField(
                          controller: _newPasswordController,
                          keyboardType: TextInputType.text,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: "Password",
                            hintText: "Password",
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.password),
                          ),
                          validator: (text) {
                            return _validatePassword(text!);
                          },
                          onSaved: (text) {},
                          textInputAction: TextInputAction.done,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(_width / 49.09090909090909),
                        child: TextFormField(
                          controller: _passwordController,
                          keyboardType: TextInputType.text,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: "Confirm Password",
                            hintText: "Confirm Password",
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.password),
                          ),
                          validator: (text) {
                            return _validateRetypePassword(text!);
                          },
                          onSaved: (text) {},
                          textInputAction: TextInputAction.done,
                        ),
                      ),
                      Padding(
                        padding:
                            EdgeInsets.only(top: _height / 26.76363636363636),
                        child: ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all<Color>(Colors.white),
                            shape: MaterialStateProperty.all<OutlinedBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(0),
                                side: const BorderSide(
                                    color: Colors.black, width: 2.0),
                              ),
                            ),
                          ),
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              _formKey.currentState?.save();
                              _onTapCreateAccount();
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const SignUpPage()),
                              );
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          LoginScreen(_width, _height)));
                            }
                          },
                          child: const Text(
                            "SIGN UP",
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    LoginScreen(_width, _height)),
                          );
                        },
                        child: const Text(
                          "Already have an Account! Login",
                          textDirection: TextDirection.ltr,
                          style: TextStyle(
                            color: Colors.blue,
                          ),
                        ),
                      )
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
