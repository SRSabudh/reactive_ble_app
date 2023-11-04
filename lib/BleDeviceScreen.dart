import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'main.dart'; // to get flutterReactiveBle object
import 'dart:convert';
import 'dart:async';

class SendData extends StatefulWidget{

  final DiscoveredDevice device;
  SendData({Key? key, required this.device}) : super(key: key);

  SendDataState createState() => SendDataState();

}

class SendDataState extends State<SendData>{

  late QualifiedCharacteristic txcharacteristic;
  String deviceValue = "";
  TextEditingController NameController = TextEditingController();

  late StreamSubscription<ConnectionStateUpdate> connectionState;

  @override
  void dispose(){
    connectionState.cancel();
    super.dispose();
  }

  @override
  void initState(){
    connectionState = flutterReactiveBle.connectToDevice(id: widget.device.id,
      // servicesWithCharacteristicsToDiscover: {serviceUUID: [TXUUID, RXUUID]},
      connectionTimeout: const Duration(seconds: 5),
    ).listen((event) {
      print("Connection Status: $event");

      flutterReactiveBle.discoverAllServices(widget.device.id).then((value) {

        flutterReactiveBle.getDiscoveredServices(widget.device.id).then((discoveredServices) => discoverServices(discoveredServices));
      });
    });

    super.initState();
  }

  void discoverServices(List<Service> discoveredServices) async {

    for (Service d in discoveredServices) {

      if (d.toString().contains(serviceUUID.toString().toLowerCase())) {
        Uuid service = Uuid.parse(d.id.toString());
        print("Service****>: ${d.id}");
        for (Characteristic discoveredCharacteristic in d.characteristics) {
          if (discoveredCharacteristic.isNotifiable) {
            Uuid tx = Uuid.parse(discoveredCharacteristic.id.toString());
            print("rx****> $discoveredCharacteristic");
            final rxcharacteristic = QualifiedCharacteristic(
                serviceId: service,
                characteristicId: tx,
                deviceId: widget.device.id);

            flutterReactiveBle.subscribeToCharacteristic(rxcharacteristic)
                .listen((data) {
              // code to handle incoming data
              // ***Bug***: listen receives data twice.
              setState(() {
                deviceValue = utf8.decode(data);
                print(deviceValue);
              });
            });
          }
          if (discoveredCharacteristic.isWritableWithoutResponse || discoveredCharacteristic.isWritableWithResponse) {
            print("tx set****> $discoveredCharacteristic");
            Uuid rx = Uuid.parse(discoveredCharacteristic.id.toString());
            txcharacteristic = QualifiedCharacteristic(
                serviceId: service,
                characteristicId: rx,
                deviceId: widget.device.id);
          }
        }
      }
    }
  }

  Future sendToNode(String payload) async {
    await flutterReactiveBle.writeCharacteristicWithoutResponse(txcharacteristic, value: utf8.encode(payload));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.device.name),
      ),
      body: Container(
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(deviceValue),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller:NameController,
                  decoration: InputDecoration(labelText: 'data'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: () async{
                    await sendToNode(NameController.text);
                  },
                  child: Text('send msg'),
                ),
              )
            ],
          )
      ),
    );
  }
}