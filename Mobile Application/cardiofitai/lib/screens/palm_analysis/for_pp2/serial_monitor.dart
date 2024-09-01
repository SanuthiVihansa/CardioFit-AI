import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:cardiofitai/models/user.dart';
import 'package:cardiofitai/screens/palm_analysis/for_pp2/widgets/device_disconnect.dart';
import 'package:cardiofitai/screens/palm_analysis/for_pp2/widgets/recording_plot.dart';
import 'package:flutter/material.dart';
import 'package:usb_serial/transaction.dart';
import 'package:usb_serial/usb_serial.dart';
import 'package:http/http.dart' as http;

class SerialMonitor extends StatefulWidget {
  const SerialMonitor(this._user, {super.key});

  final User _user;

  @override
  State<SerialMonitor> createState() => _SerialMonitorState();
}

class _SerialMonitorState extends State<SerialMonitor> {
  UsbPort? _port;
  StreamSubscription? _usbSubscription;
  String _status = "Idle";
  List<double> _ecgData = [];
  List<double> _filteredEcgData = [];
  bool _deviceIsDetected = false;
  int _countdown = 10;
  late Timer _timer;
  late double _width;
  late double _height;

  final String _filteringApiUrl =
      'http://poornasenadheera100.pythonanywhere.com/filtering';

  void initState() {
    super.initState();

    // Attempt to initialize USB once on startup
    _initUsb();

    //Listen for USB Attach/detach events
    _usbSubscription = UsbSerial.usbEventStream!.listen((UsbEvent event) {
      if (event.event == UsbEvent.ACTION_USB_ATTACHED) {
        _initUsb();
      }
    });

    // Periodically check for disconnection
    Timer.periodic(Duration(seconds: 1), (timer) {
      if (_deviceIsDetected) {
        _checkingForDisconnecting();
      }
    });
  }

  Future<void> _initUsb() async {
    try {
      List<UsbDevice> devices = await UsbSerial.listDevices();

      if (devices.isEmpty) {
        _updateStatus("No device found");
        return;
      }

      _port = await devices[0].create();
      if (!(await _openPort())) {
        _updateStatus("Failed to open port");
        return;
      }

      _updateStatus("Connected", true);

      _configurePort();

      _listenToUsbData();
    } catch (e) {
      _updateStatus("Error initializing USB: $e");
    }
  }

  void _updateStatus(String status, [bool deviceDetected = false]) {
    setState(() {
      _status = status;
      _deviceIsDetected = deviceDetected;
    });
  }

  Future<bool> _openPort() async {
    if (_port != null) {
      return await _port!.open();
    }
    return false;
  }

  void _configurePort() async {
    if (_port != null) {
      await _port!.setDTR(true);
      await _port!.setRTS(true);
      _port!.setPortParameters(
          9600, UsbPort.DATABITS_8, UsbPort.STOPBITS_1, UsbPort.PARITY_NONE);
    }
  }

  void _listenToUsbData() {
    if (_port != null) {
      Transaction<String> transaction = Transaction.stringTerminated(
          _port!.inputStream!, Uint8List.fromList([13, 10]));
      transaction.stream.listen(_handleIncomingData);
    }
  }

  void _handleIncomingData(String data) async {
    if (_ecgData.isEmpty) {
      _startCountdown();
    }

    if (_ecgData.length < 2000) {
      setState(() {
        _ecgData.add(double.parse(data.trim()));
      });

      if (_ecgData.length == 2000) {
        await _sendDataToServer();
      }
    }
  }

  Future<void> _sendDataToServer() async {
    try {
      Map<String, dynamic> data = {'l1': _ecgData};
      String jsonString = jsonEncode(data);
      var response = await http
          .post(Uri.parse(_filteringApiUrl),
              headers: <String, String>{
                'Content-Type': 'application/json; charset=UTF-8',
              },
              body: jsonString)
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);
        setState(() {
          _filteredEcgData = List<double>.from(
              decodedData["l1"].map((element) => element.toDouble()));
        });
      }
    } catch (e) {
      _updateStatus("Failed to send data to server: $e");
    }
  }

  Future<void> _checkingForDisconnecting() async {
    List<UsbDevice> devices = await UsbSerial.listDevices();
    if (devices.isEmpty) {
      setState(() {
        _status = "No device found";
        _deviceIsDetected = false;
        _countdown = 10;
      });
    }
  }

  void _startCountdown() {
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
      (Timer timer) {
        setState(() {
          if (_countdown < 1) {
            timer.cancel();
          } else {
            _countdown = _countdown - 1;
          }
        });
      },
    );
  }

  void dispose() {
    _port?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _width = MediaQuery.of(context).size.width;
    _height = MediaQuery.of(context).size.height;
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text("ECG Monitor"),
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
        ),
        body: _deviceIsDetected == false
            ? const DeviceDisconnect()
            // : _ecgData.isEmpty
            : _filteredEcgData.length < 5000
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Device is connected! Please hold still...",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(left: 15.0),
                            child: Text(
                              _countdown < 1
                                  ? "Processing signal..."
                                  : "Capturing ECG...",
                              style: const TextStyle(
                                  fontSize: 16, color: Colors.red),
                            ),
                          ),
                          if (!(_countdown < 1))
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10.0),
                              child: Image.asset(
                                "assets/palm_analysis/recording.gif",
                                scale: 15,
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Text(
                        _countdown < 1
                            ? ""
                            : "Time remaining: $_countdown seconds",
                        style: const TextStyle(fontSize: 16, color: Colors.red),
                      ),
                    ],
                  )
                : RecordingPlot(_countdown, _filteredEcgData, widget._user));
  }
}
