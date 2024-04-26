import 'dart:convert';
import 'dart:io';

import 'package:cardiofitai/models/user.dart';
import 'package:cardiofitai/screens/diet_plan/diet_plan_home_page.screen.dart';
import 'package:cardiofitai/screens/diet_plan/signup_screen.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class LoginExchangeScreen extends StatefulWidget {
  const LoginExchangeScreen({super.key});

  @override
  State<LoginExchangeScreen> createState() => _LoginExchangeScreenState();
}

class _LoginExchangeScreenState extends State<LoginExchangeScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;
    File file = File('$path/userdata.txt');
    try {
      final userData = await file.readAsString();
      if (userData != '') {
        Map decodedUser = jsonDecode(userData);
        User user = User(
            decodedUser["name"],
            decodedUser["email"],
            decodedUser["password"],
            decodedUser["age"],
            decodedUser["height"],
            decodedUser["weight"],
            decodedUser["phone"],
            decodedUser["type"]);

        _navigate(user);
      } else {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (BuildContext context) => SignUpPage()));
      }
    } catch (e) {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (BuildContext context) => SignUpPage()));
    }
  }

  void _navigate(User user) {
    if (user.type == "user") {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (BuildContext context) => DietHomePage(user)));
    } else {
      // For Doctor Login
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold();
  }
}
