import 'package:cardiofitai/components/navbar_component.dart';
import 'package:flutter/material.dart';

class DietHomePage extends StatefulWidget {
  const DietHomePage({super.key});

  @override
  State<DietHomePage> createState() => _DietHomePageState();
}

class _DietHomePageState extends State<DietHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: LeftNavBar(
            name: 'widget.user.name',
            email: 'widget.user.email',
            width: 150,
            height: 300
        ),
      body: Text("Welcome to Diet Home Page "),
    );
  }
}
