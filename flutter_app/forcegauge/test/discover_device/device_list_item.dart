import 'package:flutter/material.dart';
import './device.dart';

class DeviceListItem extends StatelessWidget {
  final Device _device;
  DeviceListItem(this._device);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        _device.ipAddress,
      ),
      subtitle: Text("name: " + _device.name + ", version: " + _device.version),
    );
  }
}
