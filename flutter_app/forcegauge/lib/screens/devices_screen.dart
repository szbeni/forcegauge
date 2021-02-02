import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forcegauge/bloc/cubit/devicemanager_cubit.dart';
import 'package:forcegauge/models/devices/device.dart';
import 'package:forcegauge/screens/new_device_screen.dart';

import 'device_list.dart';

class DevicesScreen extends StatefulWidget {
  @override
  createState() => new DevicesScreenState();
}

class DevicesScreenState extends State<DevicesScreen> {
  // Device remove popup
  void _promptRemoveDevice(int index) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return new AlertDialog(
              title: new Text(
                  //TODO:
                  'Remove Device: "${BlocProvider.of<DevicemanagerCubit>(context).state.devices[index].name}".'),
              actions: <Widget>[
                new FlatButton(
                    child: new Text('Cancel'),
                    // The alert is actually part of the navigation stack, so to close it, we
                    // need to pop it.
                    onPressed: () => Navigator.of(context).pop()),
                new FlatButton(
                    child: new Text('Remove'),
                    onPressed: () {
                      BlocProvider.of<DevicemanagerCubit>(context)
                          .removeDeviceAt(index);
                      Navigator.of(context).pop();
                    })
              ]);
        });
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
      body: DeviceList(),
      floatingActionButton: new FloatingActionButton(
          onPressed: () {
            //Navigator.of(context).pop();
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
