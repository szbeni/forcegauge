import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'device.dart';

DeviceManager deviceManager;

class DeviceManager {
  SharedPreferences _prefs;
  List<Device> _devices = [];

  DeviceManager(prefs) {
    this._prefs = prefs;
    this.loadSettings();
  }

  addDevice(String name, String url) {
    if (getDeviceByName(name) == null) {
      var newDevice = new Device(name, url);
      _devices.add(newDevice);
      return newDevice;
    }
    return null;
  }

  removeDevice(int index) {
    if (index >= 0 && index < _devices.length) {
      _devices.removeAt(index);
    }
  }

  List<Device> getDevices() {
    return _devices;
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
      var newDevice = new Device.fromJson(devJson);
      _devices.add(newDevice);
    }
  }

  saveSettings() {
    String json =
        jsonEncode(_devices.map((i) => i.toJson()).toList()).toString();
    _prefs.setString('devices', json);
  }
}
