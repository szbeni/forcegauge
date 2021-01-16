import 'package:flutter/foundation.dart';
import 'package:forcegauge/models/websocket_html.dart'
    if (dart.library.io) 'package:forcegauge/models/websocket_io.dart';

// WebSocketsNotifications sockets = new WebSocketsNotifications();

class WebSocketsNotifications extends WebsocketGetter {
  var address;
  var _channel;
  bool _isOn = false;

  ObserverList<Function> _listeners = new ObserverList<Function>();
  connect(address) async {
    this.address = address;
    reset();
    try {
      _channel = WebsocketGetter.newWebsocket(this.address);
      _channel.stream.listen(_onReceptionOfMessageFromServer);
    } catch (e) {
      print(e);
    }
  }

  reset() {
    if (_channel != null) {
      if (_channel.sink != null) {
        _channel.sink.close();
        _isOn = false;
      }
    }
  }

  send(String message) {
    if (_channel != null) {
      if (_channel.sink != null && _isOn) {
        _channel.sink.add(message);
      }
    }
  }

  addListener(Function callback) {
    _listeners.add(callback);
  }

  removeListener(Function callback) {
    _listeners.remove(callback);
  }

  _onReceptionOfMessageFromServer(message) {
    _isOn = true;
    _listeners.forEach((Function callback) {
      callback(message);
    });
  }
}
