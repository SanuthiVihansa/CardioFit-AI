import 'dart:async';

import 'package:cardiofitai/screens/palm_analysis/bluetooth_testing/bt_off_screen.dart';
import 'package:cardiofitai/screens/palm_analysis/bluetooth_testing/scan_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

// Used Blue Plus documentation on Pub.dev

class SampleBluetoothScreen extends StatefulWidget {
  const SampleBluetoothScreen({super.key});

  @override
  State<SampleBluetoothScreen> createState() => _SampleBluetoothScreenState();
}

class _SampleBluetoothScreenState extends State<SampleBluetoothScreen> {
  BluetoothAdapterState _adapterState = BluetoothAdapterState.unknown;
  late StreamSubscription<BluetoothAdapterState> _adapterStateStateSubscription;

  @override
  void initState() {
    super.initState();
    _adapterStateStateSubscription =
        FlutterBluePlus.adapterState.listen((state) {
      _adapterState = state;
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget screen = _adapterState == BluetoothAdapterState.on
        ? ScanScreen()
        : BTOffScreen();

    return screen;
  }
}

class BluetoothAdapterStateObserver extends NavigatorObserver {
  StreamSubscription<BluetoothAdapterState>? _adapterStateSubscription;

  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    if (route.settings.name == '/DeviceScreen') {
      _adapterStateSubscription ??=
          FlutterBluePlus.adapterState.listen((state) {
        if (state != BluetoothAdapterState.on) {
          navigator?.pop();
        }
      });
    }
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    _adapterStateSubscription?.cancel();
    _adapterStateSubscription = null;
  }
}
