import 'package:cardiofitai/screens/diet_plan/login_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  late double _width;
  late double _height;

  //Email Field Validation
  String? _validateEmail(String text) {
    if (text == "") {
      return "Email / Username is required!";
    } else if (!text.contains("@")) {
      return "Invalid email / username";
    }
    return null;
  }

//Validate new and exisiting passwords
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
  

  Future<void> _onTapCreateAccount() async {
    Response response = await UserLoginService.addAccount(
        _emailController.text,
        _passwordController.text
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
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen(_width, _height)),
      );
    } else {
      Fluttertoast.showToast(
          msg: "Opps !! We have trouble in signin, Please try again.☹️",
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

    return  Scaffold(
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
                child: Icon(Icons.account_circle),
              ),
              Text("H E L L O   T H E R E ! ",style:TextStyle(fontSize: 20,fontWeight: FontWeight.bold)),
              Text("Register below with details"),
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
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          controller: _emailController,
                          validator: (text) {
                            return _validateEmail(text!);
                          },
                          onSaved: (text) {},
                          decoration: InputDecoration(
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
                          controller: _newPasswordController,
                          keyboardType: TextInputType.text,
                          obscureText: true,
                          decoration: const InputDecoration(
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
                        padding: EdgeInsets.only(
                            top: _height / 26.76363636363636),
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              _formKey.currentState?.save();
                              _onTapCreateAccount();
                            }
                          },
                          child: const Text("Sign up"),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => LoginScreen(_width, _height)),
                          );
                        },
                        child: Text(
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

