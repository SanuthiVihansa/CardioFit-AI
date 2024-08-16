import 'package:cardiofitai/models/user.dart';
import 'package:flutter/material.dart';

class EcgHistoryScreen extends StatefulWidget {
  const EcgHistoryScreen(this._user, {super.key});

  final User _user;

  @override
  State<EcgHistoryScreen> createState() => _EcgHistoryScreenState();
}

class _EcgHistoryScreenState extends State<EcgHistoryScreen> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
