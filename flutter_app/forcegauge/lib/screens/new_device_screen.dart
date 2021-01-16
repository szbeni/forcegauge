import 'package:flutter/material.dart';

class AddNewDeviceScreen extends StatefulWidget {
  final callback;
  AddNewDeviceScreen(this.callback);
  @override
  _AddNewDeviceScreenState createState() => _AddNewDeviceScreenState();
}

class _AddNewDeviceScreenState extends State<AddNewDeviceScreen> {
  String deviceName = "";
  String deviceUrl = "";
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(title: new Text('Add a new device')),
        floatingActionButton: new FloatingActionButton(
            onPressed: () {
              if (deviceName.length > 0 && deviceUrl.length > 0) {
                widget.callback(deviceName, deviceUrl);
              }
              Navigator.of(context).pop();
            },
            tooltip: 'Add',
            child: new Icon(Icons.add)),
        body: Column(
          children: [
            new TextField(
              autofocus: true,
              onChanged: (name) {
                deviceName = name;
              },
              decoration: new InputDecoration(
                  hintText: 'My Awsome Device',
                  contentPadding: const EdgeInsets.all(16.0)),
            ),
            new TextField(
              autofocus: false,
              onChanged: (url) {
                deviceUrl = url;
              },
              decoration: new InputDecoration(
                  hintText: 'Enter device URL. ex.: ws://192.168.4.1:81',
                  contentPadding: const EdgeInsets.all(16.0)),
            )
          ],
        ));
  }
}
