import 'dart:async';
import 'dart:typed_data';

import 'package:cardiofitai/screens/palm_analysis/for_pp2/widgets/device_disconnect.dart';
import 'package:cardiofitai/screens/palm_analysis/for_pp2/widgets/recording_plot.dart';
import 'package:flutter/material.dart';
import 'package:usb_serial/transaction.dart';
import 'package:usb_serial/usb_serial.dart';

class SerialMonitor2 extends StatefulWidget {
  const SerialMonitor2({super.key});

  @override
  State<SerialMonitor2> createState() => _SerialMonitor2State();
}

class _SerialMonitor2State extends State<SerialMonitor2> {
  UsbPort? _port;
  String _status = "Idle";
  List<double> _ecgData = [];
  bool _deviceIsDetected = false;
  int _countdown = 10;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    Timer.periodic(Duration(seconds: 1), (timer) {
      if (_deviceIsDetected == false) {
        _initUsb();
      } else {
        _checkingForDisconnecting();
      }
    });
  }

  void _initUsb() async {
    List<UsbDevice> devices = await UsbSerial.listDevices();
    if (devices.isNotEmpty) {
      _port = await devices[0].create();
      bool openResult = await _port!.open();
      if (openResult) {
        await _port!.setDTR(true);
        await _port!.setRTS(true);
        _port!.setPortParameters(
            9600, UsbPort.DATABITS_8, UsbPort.STOPBITS_1, UsbPort.PARITY_NONE);
        Transaction<String> transaction = Transaction.stringTerminated(
            _port!.inputStream!, Uint8List.fromList([13, 10]));
        transaction.stream.listen((String data) {
          if (_ecgData.length == 1) {
            _startCountdown();
          }
          if (_ecgData.length <= 4000) {
            setState(() {
              _ecgData.add(double.parse(data.trim()));
            });
          } else {
            print("More than 5000");
          }
        });
        setState(() {
          _status = "Connected";
          _deviceIsDetected = true;
        });
      } else {
        setState(() {
          _status = "Failed to open port";
        });
      }
    } else {
      setState(() {
        _status = "No device found";
      });
    }
  }

  Future<void> _checkingForDisconnecting() async {
    List<UsbDevice> devices = await UsbSerial.listDevices();
    if (devices.isEmpty) {
      setState(() {
        _status = "No device found";
        _deviceIsDetected = false;
      });
    }
  }

  // TODO - Delete this
  // Widget _displayRecordingPlot() {
  //   // _startCountdown();
  //   return RecordingPlot(_countdown);
  // }

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

  @override
  void dispose() {
    _port?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("ECG Monitor"),
        ),
        body: _deviceIsDetected == false
            ? DeviceDisconnect()
            : _ecgData.isEmpty
                ? Center(
                    child: Text(
                        "Device is connected! Recording will start shortly."))
                : RecordingPlot(_countdown, _ecgData)
        // body: RecordingPlot(_countdown, [
        //   100,
        //   100,
        //   100,
        //   100,
        //   100,
        //   100,
        //   100,
        //   100,
        //   100,
        //   100,
        //   100,
        //   100,
        //   100,
        //   100,
        //   100,
        //   100,
        //   100,
        //   100,
        //   100,
        //   100,
        //   100,
        //   100,
        //   100,
        //   100,
        //   100,
        //   100,
        //   100,
        //   100,
        //   100,
        //   100,
        //   100,
        //   100,
        //   100,
        //   100
        // ])
        );
  }
}
