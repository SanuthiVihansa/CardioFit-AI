import 'package:cardiofitai/models/response.dart';
import 'package:cardiofitai/services/test_service.dart';
import 'package:flutter/material.dart';

class TestingFirebaseScreen extends StatefulWidget {
  const TestingFirebaseScreen({super.key});

  @override
  State<TestingFirebaseScreen> createState() => _TestingFirebaseScreenState();
}

class _TestingFirebaseScreenState extends State<TestingFirebaseScreen> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    triggerFunction();

  }

  Future<void> triggerFunction()async{
    Response response = await TestService.addAccount("test@gmail.com", "testpw");
    print(response.code);
    print(response.message);
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
