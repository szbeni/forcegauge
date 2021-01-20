import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:forcegauge/models/socket_manager.dart';

import 'device_data.dart';

class Device {
  //List<DeviceData> _historicalData = [];
  //int _historicalDataMaxLength = 3000;
  final String name;
  String _url;
  double offset = 0;
  double scaler = 0;
  double lastValue = 0;
  double lastRawValue = 0;
  double maxValue = 0;
  double minValue = 0;

  WebSocketsNotifications _socket = new WebSocketsNotifications();
  Device(this.name, url) {
    this._url = url;
    connect();
  }

  WebSocketsNotifications getSocket() {
    return this._socket;
  }

  // getHistoricalData() {
  //   return this._historicalData;
  // }

  setUrl(String url) {
    _url = url;
  }

  getUrl() {
    return _url;
  }

  toString() {
    return name + " - " + _url;
  }

  bool isConnected() {
    return _socket.isConnected();
  }

  String connectionStatusMsg() {
    return _socket.statusMsg();
  }

  connect() {
    _socket.connect(this._url);
    _socket.addOnMessageListener(onMessage);
  }

  resetOffset() {
    _socket.send("offset:$lastRawValue");
  }

  clearMaxMin() {
    this.maxValue = 0;
    this.minValue = 0;
  }

  onMessage(msg) {
    var message = jsonDecode(msg);
    var data = message['data'];
    List<DeviceData> newDataList = [];
    if (data is List) {
      for (var d in data) {
        // Convert JSON to DeviceData
        var dd = DeviceData.parseJSON(d);
        newDataList.add(dd);

        // Store last values
        this.lastRawValue = dd.raw;
        this.lastValue = dd.value;

        //Check for min and max
        if (this.lastValue > this.maxValue) {
          this.maxValue = this.lastValue;
        }
        if (this.lastValue < this.minValue) {
          this.minValue = this.lastValue;
        }
      }

      // Add new and remove old data
      // _historicalData.addAll(newDataList);
      // int difference = _historicalData.length - _historicalDataMaxLength;
      // if (difference > 0) {
      //   _historicalData.removeRange(0, difference);
      // }
    }
    _notifyListeners(newDataList);
  }

  // On data has changed listener
  ObserverList<Function> _listeners = new ObserverList<Function>();

  addListener(Function callback) {
    _listeners.add(callback);
  }

  removeListener(Function callback) {
    _listeners.remove(callback);
  }

  _notifyListeners(var data) {
    _listeners.forEach((Function callback) {
      callback(data);
    });
  }

  // JSON
  factory Device.fromJson(dynamic json) {
    var dev = Device(json['name'], json['url']);
    return dev;
  }

  Map<String, dynamic> toJson() {
    return {
      "name": this.name,
      "url": this._url,
    };
  }
}
