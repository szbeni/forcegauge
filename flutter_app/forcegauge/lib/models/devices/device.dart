import 'dart:convert';

import 'package:forcegauge/models/socket_manager.dart';

class Device {
  final String name;
  String _url;
  double offset = 0;
  double scaler = 0;
  double lastValue = 0;
  double lastRawValue = 0;
  double maxValue = 0;
  double minValue = 0;
  bool _isConnected = false;

  WebSocketsNotifications socket = new WebSocketsNotifications();
  Device(this.name);

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
    return _isConnected;
  }

  connect() {
    if (_url != null) {
      socket.connect(this._url);
      socket.addListener(onMessage);
    }
  }

  resetOffset() {
    socket.send("offset:$lastRawValue");
  }

  clearMaxMin() {
    this.maxValue = 0;
    this.minValue = 0;
  }

  onMessage(msg) {
    _isConnected = true;
    var message = jsonDecode(msg);
    var data = message['data'];
    if (data is List) {
      this.lastRawValue = double.parse(data[data.length - 1]['raw']);
      this.lastValue = double.parse(data[data.length - 1]['value']);
      if (this.lastValue > this.maxValue) {
        this.maxValue = this.lastValue;
      }
      if (this.lastValue < this.minValue) {
        this.minValue = this.lastValue;
      }
    }
  }

  factory Device.fromJson(dynamic json) {
    var dev = Device(json['name']);
    dev.setUrl(json['url']);
    return dev;
  }

  Map<String, dynamic> toJson() {
    return {
      "name": this.name,
      "url": this._url,
    };
  }
}
