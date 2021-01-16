import 'package:flutter/material.dart';
import 'package:forcegauge/models/devices/device.dart';
import 'package:forcegauge/models/devices/device_manager.dart';
import 'package:forcegauge/screens/new_device_screen.dart';

class DevicesScreen extends StatefulWidget {
  @override
  createState() => new DevicesScreenState();
}

class DevicesScreenState extends State<DevicesScreen> {
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

  void _promptRemoveDevice(int index) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return new AlertDialog(
              title:
                  new Text('Remove "${deviceManager.getDevice(index).name}".'),
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

  // Build the whole list of todo items
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

  // Build a single todo item
  Widget _buildDeviceItem(Device device, int index) {
    // return new Container(
    //   child: Row(children: [
    //     new ListTile(
    //         title: new Text(device.name),
    //         onTap: () => _promptRemoveDevice(index)),
    //     new Text("asd"),
    //   ]),
    // );
    //return newnew Row(children: <Widget>[new Text(device.name)], on);
    return new ListTile(
      title: new Text(device.toString()),
      onTap: () => _promptRemoveDevice(index),
      trailing: Wrap(
        spacing: 12, // space between two icons
        children: <Widget>[
          Icon(Icons.signal_wifi_4_bar), // icon-1
          Icon(Icons.signal_wifi_off), // icon-1
        ],
      ),
    );
  }

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
