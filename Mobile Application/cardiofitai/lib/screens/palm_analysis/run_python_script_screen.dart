import 'package:flutter/material.dart';

class RunPythonScriptScreen extends StatefulWidget {
  const RunPythonScriptScreen({super.key});

  @override
  State<RunPythonScriptScreen> createState() => _RunPythonScriptScreenState();
}

class _RunPythonScriptScreenState extends State<RunPythonScriptScreen> {

  @override
  void initState() {
    super.initState();
    _runScript();
  }

  Future<void> _runScript() async{

  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
