import 'package:flutter/material.dart';
import 'package:forcegauge/screens/new_device_screen.dart';

import 'device_list.dart';

class DevicesScreen extends StatefulWidget {
  @override
  createState() => new DevicesScreenState();
}

class DevicesScreenState extends State<DevicesScreen> {
  // Build the whole screen
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(title: new Text('Devices')),
      body: DeviceList(),
      floatingActionButton: new FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddNewDeviceScreen(),
              ),
            );
          },
          tooltip: 'Add Device',
          child: new Icon(Icons.add)),
    );
  }
}
