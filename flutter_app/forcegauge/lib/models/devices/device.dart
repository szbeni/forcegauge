import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:forcegauge/models/socket_manager.dart';
import 'package:forcegauge/models/tabata/tabata.dart';

import 'device_data.dart';

enum DeviceNotificationType {
  newMessage,
  newStatus,
}

class Device extends Equatable {
  List<DeviceData> _historicalData = [];
  int _historicalDataMaxLength = 500;
  final String name;
  String _url;
  double offset = 0;
  double scaler = 0;
  double lastValue = 0;
  double lastRawValue = 0;
  double maxValue = 0;
  double minValue = 0;
  DeviceData lastData = new DeviceData(0, 0, 0);

  @override
  List<Object> get props => [name];

  WebSocketsNotifications _socket = new WebSocketsNotifications();
  Device(this.name, url) {
    this._url = url;
    connect();
  }

  WebSocketsNotifications getSocket() {
    return this._socket;
  }

  close() {
    _socket.close();
  }

  getHistoricalData() {
    return this._historicalData;
  }

  clearHistoricalData() {
    this._historicalData.clear();
  }

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
    _socket.addOnStatusChangedListener(onStatusChanged);
  }

  resetOffset() {
    _socket.send("offset:$lastRawValue");
  }

  sendTabatas(List<Tabata> tabatas) {
    for (var t in tabatas) {
      var tabatJson = jsonEncode(t.toJson());
      _socket.send("add_tabata:$tabatJson");
    }
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
        this.lastData = dd;
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
      _historicalData.addAll(newDataList);
      int difference = _historicalData.length - _historicalDataMaxLength;
      if (difference > 0) {
        _historicalData.removeRange(0, difference);
      }
    }
    _notifyListeners(DeviceNotificationType.newMessage, newDataList);
  }

  onStatusChanged(status) {
    _notifyListeners(DeviceNotificationType.newStatus, status);
  }

  // On data has changed listener
  ObserverList<Function> _listeners = new ObserverList<Function>();

  addListener(Function callback) {
    _listeners.add(callback);
  }

  removeListener(Function callback) {
    _listeners.remove(callback);
  }

  _notifyListeners(DeviceNotificationType type, data) {
    _listeners.forEach((Function callback) {
      callback(type, data);
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
