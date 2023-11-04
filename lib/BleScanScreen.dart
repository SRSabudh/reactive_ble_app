import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'main.dart'; // to get flutterReactiveBle object
import 'dart:async';

// App linking imports
import 'BleDeviceScreen.dart';

class FindDevicesScreen extends StatefulWidget {

  FindDevicesScreen({super.key});

  @override
  State<FindDevicesScreen> createState() => _FindDevicesScreenState();
}

class _FindDevicesScreenState extends State<FindDevicesScreen> {
  List<DiscoveredDevice> devices = [];
  Set<String> seen = {};
  late StreamSubscription<DiscoveredDevice> scan;
  var isScanning = StreamController<bool>();

  @override
  void dispose() {
    isScanning.close();
    scan.cancel();
    super.dispose();
  }

  @override
  void initState() {
    findDevice();
    Future.delayed(const Duration(seconds: 5)).then((value){
      isScanning.sink.add(false);
      scan.cancel();
    });
    super.initState();
  }

  void findDevice() async {
    devices = [];
    seen = {};

    print("Connecting to device list stream!");
    isScanning.sink.add(true);

    scan = flutterReactiveBle.scanForDevices(withServices: [], scanMode: ScanMode.lowLatency).listen((device) {
      if(seen.contains(device.id) == false){
        setState(() {
          seen.add(device.id);
          devices.add(device);
          print(device.toString());
        });
      }
      //code for handling results
    }, onError: (e) {
      print("Error Found While Scanning for the devices: $e");
      //code for handling error
    });
    // to demonstrate no device found.
    setState(() { });

  }

  void showDevice(){
    print("Available Devices: \n $devices");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

        appBar: AppBar(
            title: const Text("Scan Device")
        ),

        body: devices.isEmpty ? Text("No Device") : ListView.builder(
          itemCount: devices.length,
          prototypeItem: const ListTile(
              title: Center(child: Text("No Device Found!"))
          ),
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.all(1.5),
              child: ListTile(
                tileColor: Colors.black26,
                contentPadding: const EdgeInsets.all(1.0),
                isThreeLine: false,
                title: Text(devices[index].name),
                subtitle: Text("Status: ${devices[index].connectable} \n Device id: ${devices[index].id}"),
                trailing: Text("RSSI: ${devices[index].rssi.toString()}"),

                onTap: () {
                  scan.cancel();
                  // got to device screen
                  Navigator.push(context, MaterialPageRoute(
                      builder: (context) => SendData(device: devices[index])));
                },
              ),
            );
          },
        ),

        floatingActionButton: StreamBuilder<bool>(
          stream: isScanning.stream,
          initialData: false,
          builder: (c, snapshot){
            if(snapshot.data == false){
              return FloatingActionButton(
                onPressed: findDevice,
                child: const Icon(Icons.search),
              );}
            else {
              return FloatingActionButton(
                  onPressed: () {
                    isScanning.sink.add(false);
                    scan.cancel();
                  },
                  backgroundColor: Colors.red,
                  child: const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  )
              );}
          },
        )
    );
  }
}