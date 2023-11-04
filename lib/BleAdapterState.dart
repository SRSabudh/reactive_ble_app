import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'main.dart'; // to get flutterReactiveBle object

// App linking imports
import 'BleOffScreen.dart';
import 'BleScanScreen.dart';


class BleHomeScreen extends StatelessWidget{

  BleHomeScreen({super.key});

  @override
  Widget build(BuildContext context){
    return MaterialApp(
      title: "bleApp",
      home: StreamBuilder<BleStatus>(
          stream: flutterReactiveBle.statusStream,
          initialData: BleStatus.unknown,
          builder: (c, snapshot){
            print(snapshot.data);
            final state = snapshot.data;
            if(state == BleStatus.ready){
              return  FindDevicesScreen();// FindDevicesScreen();
            }
            return BleOffScreen(state: state);
            /* if state shows unauthorized,
            means you have to manually give permission
            to your app to use ble/bluetooth or NearByShare.
            */
          }
      ),
    );
  }
}