import 'package:flutter/material.dart';

class BTOffScreen extends StatefulWidget {
  const BTOffScreen({super.key});

  @override
  State<BTOffScreen> createState() => _BTOffScreenState();
}

class _BTOffScreenState extends State<BTOffScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text("BT OFF"),
      ),
    );
  }
}
