import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

// App linking imports
import 'BleAdapterState.dart';

/* Note:- if you receive unauthorized msg on ble off screen means you have to
* give permission to use NearByShare or bluetooth to your app */

Uuid serviceUUID = Uuid.parse("6E400001-B5A3-F393-E0A9-E50E24DCCA9E");
// Uuid RXUUID = Uuid.parse("6E400002-B5A3-F393-E0A9-E50E24DCCA9E");
// Uuid TXUUID = Uuid.parse("6E400003-B5A3-F393-E0A9-E50E24DCCA9E");

final flutterReactiveBle = FlutterReactiveBle();

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(BleHomeScreen());
}

