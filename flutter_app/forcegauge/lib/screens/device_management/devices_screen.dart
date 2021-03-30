import 'package:flutter/material.dart';
import 'package:forcegauge/screens/device_management/discover_devices_screen.dart';
import 'package:forcegauge/screens/device_management/add_new_device_screen.dart';
import 'package:forcegauge/screens/device_management/device_list.dart';

class DevicesScreen extends StatefulWidget {
  @override
  createState() => new DevicesScreenState();
}

class DevicesScreenState extends State<DevicesScreen> {
  // Build the whole screen
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      // appBar: new AppBar(title: new Text('Devices')),
      appBar: AppBar(
        title: Text('Added Devices'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DiscoverDevicesScreen(),
                ),
              );
              //_scanDevices();
            },
          ),
        ],
      ),
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
