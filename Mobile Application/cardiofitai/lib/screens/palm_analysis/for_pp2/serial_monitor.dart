import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:usb_serial/transaction.dart';
import 'package:usb_serial/usb_serial.dart';

class SerialMonitor extends StatefulWidget {
  const SerialMonitor({super.key});

  @override
  State<SerialMonitor> createState() => _SerialMonitorState();
}

class _SerialMonitorState extends State<SerialMonitor> {
  UsbPort? _port;
  String _status = "Idle";
  List<int> _ecgData = [];

  @override
  void initState() {
    super.initState();
    _initUsb();
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
          setState(() {
            _ecgData.add(int.parse(data.trim()));
          });
        });
        setState(() {
          _status = "Connected";
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_status),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _ecgData.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text("ECG Value: ${_ecgData[index]}"),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
