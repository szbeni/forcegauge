import 'package:flutter/material.dart';
import 'package:forcegauge/models/devices/device.dart';
import 'package:forcegauge/models/devices/device_manager.dart';
import 'package:forcegauge/screens/new_device_screen.dart';

class DevicesScreen extends StatefulWidget {
  @override
  createState() => new DevicesScreenState();
}

class DevicesScreenState extends State<DevicesScreen> {
  @override
  void initState() {
    for (var d in deviceManager.getDevices()) {
      d.getSocket().addOnStatusChangedListener(onDeviceChanges);
    }
    super.initState();
  }

  @override
  dispose() {
    for (var d in deviceManager.getDevices()) {
      d.getSocket().removeOnStatusChangedListener(onDeviceChanges);
    }
    super.dispose();
  }

  // When the status of a device has changed
  onDeviceChanges(status) {
    setState(() {});
  }

  void _addDevice(String name, String url) {
    setState(() {
      deviceManager.addDevice(name, url);
      deviceManager.saveSettings();
    });
  }

  void _removeDevice(int index) {
    setState(() {
      deviceManager.removeDevice(index);
      deviceManager.saveSettings();
    });
  }

  // Device remove popup
  void _promptRemoveDevice(int index) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return new AlertDialog(
              title: new Text(
                  'Remove Device: "${deviceManager.getDevice(index).name}".'),
              actions: <Widget>[
                new FlatButton(
                    child: new Text('Cancel'),
                    // The alert is actually part of the navigation stack, so to close it, we
                    // need to pop it.
                    onPressed: () => Navigator.of(context).pop()),
                new FlatButton(
                    child: new Text('Remove'),
                    onPressed: () {
                      _removeDevice(index);
                      Navigator.of(context).pop();
                    })
              ]);
        });
  }

  // Build the whole list of Devices
  Widget _buildDevicesScreen() {
    return new ListView.builder(
      itemBuilder: (context, index) {
        if (index < deviceManager.getDeviceNum()) {
          return _buildDeviceItem(deviceManager.getDevice(index), index);
        } else {
          return new ListTile();
        }
      },
    );
  }

  // Build a single Device Item
  Widget _buildDeviceItem(Device device, int index) {
    var connectedIcon = Icon(Icons.radio_button_checked, color: Colors.red);
    if (device.isConnected()) {
      connectedIcon = Icon(Icons.radio_button_checked, color: Colors.green);
    }

    return new ListTile(
      title: new Tooltip(
        message: device.connectionStatusMsg(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            new Text("Name: " + device.name.toString()),
            new Text("Address: " + device.getUrl().toString()),
            connectedIcon
          ],
        ),
      ),
      onTap: () => _promptRemoveDevice(index),
      // trailing: Wrap(
      //   spacing: 12, // space between two icons
      //   children: <Widget>[
      //     Icon(Icons.signal_wifi_4_bar), // icon-1
      //     Icon(Icons.signal_wifi_off), // icon-1
      //   ],
      // ),
    );
  }

  // Build the whole screen
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(title: new Text('Devices')),
      body: _buildDevicesScreen(),
      floatingActionButton: new FloatingActionButton(
          onPressed: () {
            //Navigator.of(context).pop();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddNewDeviceScreen(_addDevice),
              ),
            );
          },
          tooltip: 'Add Device',
          child: new Icon(Icons.add)),
    );
  }
}
