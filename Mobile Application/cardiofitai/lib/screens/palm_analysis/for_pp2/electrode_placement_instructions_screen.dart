import 'dart:async';

import 'package:cardiofitai/screens/palm_analysis/for_pp2/serial_monitor.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import '../../../models/user.dart';

class ElectrodePlacementInstructionsScreen extends StatefulWidget {
  const ElectrodePlacementInstructionsScreen(this._user, {super.key});

  final User _user;

  @override
  State<ElectrodePlacementInstructionsScreen> createState() =>
      _ElectrodePlacementInstructionsScreenState();
}

class _ElectrodePlacementInstructionsScreenState
    extends State<ElectrodePlacementInstructionsScreen> {
  late double _width;
  late double _height;
  final double _devWidth = 753.4545454545455;
  final double _devHeight = 392.72727272727275;

  bool _hasConnection = false;

  final String _upServerUrl =
      'http://poornasenadheera100.pythonanywhere.com/upforunet';
  final String _upBaseLineServerUrl = 'http://swije.pythonanywhere.com/load/model';

  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  final Connectivity _connectivity = Connectivity();

  // ignore: unused_field
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);

    initConnectivity();

    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  Future<void> initConnectivity() async {
    late List<ConnectivityResult> result;
    try {
      result = await _connectivity.checkConnectivity();
      // ignore: unused_catch_clause
    } on PlatformException catch (e) {
      // print('Could not check connectivity status $e');
      return;
    }
    if (!mounted) {
      return Future.value(null);
    }

    return _updateConnectionStatus(result);
  }

  Future<void> _updateConnectionStatus(List<ConnectivityResult> result) async {
    setState(() {
      _connectionStatus = result;
    });
    // print('Connectivity changed: $_connectionStatus');
    _checkNetwork(_connectionStatus[0]);
  }

  void _checkNetwork(ConnectivityResult result) {
    if (result != ConnectivityResult.none) {
      _hasConnection = true;
      _upServer();
      upBaseLineServer();
    } else {
      _hasConnection = false;
    }
    setState(() {});

    if (!_hasConnection) {
      _showNetworkErrorMsg();
    }
  }

  Future<void> _upServer() async {
    await http.get(Uri.parse(_upServerUrl), headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    });
  }

  Future<void> upBaseLineServer() async {
    await http.get(Uri.parse(_upBaseLineServerUrl), headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    });
  }

  Future<void> _showNetworkErrorMsg() async {
    await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text("No Internet"),
              actionsAlignment: MainAxisAlignment.center,
              content: const Text('Please connect to the network!'),
              actions: <Widget>[
                TextButton(
                  onPressed: () async {
                    return Navigator.pop(context, true);
                  },
                  child: const Text('OK'),
                ),
              ],
            ));
  }

  void _onTapContinueBtn(BuildContext context) {
    Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (BuildContext) => SerialMonitor(widget._user)));
  }

  @override
  Widget build(BuildContext context) {
    _width = MediaQuery.of(context).size.width;
    _height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        title: Text("Palm Analysis"),
      ),
      backgroundColor: Colors.white,
      body: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                "Instructions",
                style: TextStyle(fontSize: _width / (_devWidth / 30)),
              ),
              Text(
                "Place the electrodes along with the correct color",
                style: TextStyle(fontSize: _width / (_devWidth / 15)),
              ),
              Column(
                children: [
                  !_hasConnection
                      ? Padding(
                          padding: EdgeInsets.only(
                              bottom: _height / (_devHeight / 10)),
                          child: Text(
                            "No Network Connection!",
                            style: TextStyle(
                                color: Colors.red,
                                fontSize: _width / (_devWidth / 10)),
                          ),
                        )
                      : const SizedBox(),
                  ElevatedButton(
                      onPressed: _hasConnection
                          ? () {
                              _onTapContinueBtn(context);
                            }
                          : null,
                      style: ButtonStyle(
                        fixedSize: MaterialStateProperty.all<Size>(
                          Size(
                              _width / (_devWidth / 160.0),
                              _height /
                                  (_devHeight / 40)), // Button width and height
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Continue",
                            style:
                                TextStyle(fontSize: _width / (_devWidth / 10)),
                          ),
                          Icon(
                            Icons.arrow_right_outlined,
                            size: _height / (_devHeight / 20),
                          )
                        ],
                      )),
                ],
              )
            ],
          ),
          Image.asset(
            "assets/palm_analysis/3_electrode_placement_palms.png",
            scale: 1.5,
          )
        ],
      ),
    );
  }
}
