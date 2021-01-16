import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'device.dart';

DeviceManager deviceManager;

class DeviceManager {
  SharedPreferences _prefs;
  List<Device> _devices = [];
  Map<String, Device> devicesByName;

  DeviceManager(prefs) {
    this._prefs = prefs;
    this.loadSettings();
  }

  addDevice(String name, String url) {
    if (getDeviceByName(name) == null) {
      var dev = new Device(name);
      dev.setUrl(url);
      dev.connect();
      _devices.add(dev);
      return dev;
    }
    return null;
  }

  removeDevice(int index) {
    if (index >= 0 && index < _devices.length) {
      _devices.removeAt(index);
    }
  }

  getDeviceNum() {
    if (_devices == null) return 0;
    return _devices.length;
  }

  Device getDevice(int index) {
    if (index >= 0 && index < _devices.length) {
      return _devices[index];
    }
    return null;
  }

  Device getDeviceByName(String name) {
    for (var d in _devices) {
      if (d.name == name) return d;
    }
    return null;
  }

  loadSettings() {
    var devicesString = _prefs.getString('devices') ?? '[]';
    var devicesJson = jsonDecode(devicesString) as List;
    for (var devJson in devicesJson) {
      var newDev = new Device.fromJson(devJson);
      _devices.add(newDev);
    }
  }

  saveSettings() {
    String json =
        jsonEncode(_devices.map((i) => i.toJson()).toList()).toString();
    _prefs.setString('devices', json);
  }
}
