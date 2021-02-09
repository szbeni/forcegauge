import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:forcegauge/models/websocket_html.dart'
    if (dart.library.io) 'package:forcegauge/models/websocket_io.dart';

// WebSocketsNotifications sockets = new WebSocketsNotifications();

class WebSocketsNotifications extends WebsocketGetter {
  var _url;
  var _channel;
  //Connection established
  bool _isConnected = false;
  //Flags if we have already trying to connect
  bool _isConnecting = false;
  String _lastStatusMsg = "";
  DateTime _lastMessageTime;
  int _timeout = 5000;
  int _connectionCheckPeriod = 5000;
  Timer _timer;

  WebSocketsNotifications() {
    _timer = Timer.periodic(
      Duration(milliseconds: this._connectionCheckPeriod),
      this._periodicConnectionCheck,
    );
  }

  _newStatus(statusMsg) {
    // For debugging
    _lastStatusMsg = statusMsg;
    _listenersOnStatusChanged.forEach((Function callback) {
      callback(statusMsg);
    });
  }

  ObserverList<Function> _listenersOnMessage = new ObserverList<Function>();
  ObserverList<Function> _listenersOnStatusChanged =
      new ObserverList<Function>();

  connect(url) async {
    this._url = url;
    reset();
    _newStatus("Connecting to " + this._url.toString());
    try {
      _channel = WebsocketGetter.newWebsocket(this._url);
      _isConnecting = true;
      _channel.stream.listen(
        _onReceptionOfMessageFromServer,
        onDone: _onDisconnected,
        onError: _onError,
      );
    } catch (e) {
      print("Websocket Error: ${e}");
    }
  }

  close() {
    if (_timer != null) {
      _timer.cancel();
      _timer = null;
      reset();
    }
  }

  reset() {
    if (_channel != null) {
      if (_channel.sink != null) {
        _channel.sink.close();
        _isConnected = false;
        _isConnecting = false;
      }
    }
  }

  send(String message) {
    if (_channel != null) {
      if (_channel.sink != null && _isConnected) {
        _channel.sink.add(message);
      }
    }
  }

  addOnMessageListener(Function callback) {
    _listenersOnMessage.add(callback);
  }

  removeOnMessageListener(Function callback) {
    _listenersOnMessage.remove(callback);
  }

  addOnStatusChangedListener(Function callback) {
    _listenersOnStatusChanged.add(callback);
  }

  removeOnStatusChangedListener(Function callback) {
    _listenersOnStatusChanged.remove(callback);
  }

  statusMsg() {
    return _lastStatusMsg;
  }

  isConnected() {
    return _isConnected;
  }

  _onTimeout() {
    _isConnected = false;
    _isConnecting = false;
    _newStatus("Timeout");
  }

  _onDisconnected() {
    _isConnected = false;
    _isConnecting = false;
    _newStatus("Disconnected");
  }

  _onError(error) {
    _isConnected = false;
    _isConnecting = false;
    _newStatus("Error: " + error.toString());
  }

  _onReceptionOfMessageFromServer(message) {
    if (_isConnected == false) {
      _isConnected = true;
      _newStatus("Connected");
    }
    _lastMessageTime = DateTime.now();
    _isConnecting = false;
    _listenersOnMessage.forEach((Function callback) {
      callback(message);
    });
  }

  _periodicConnectionCheck(timer) {
    if (_isConnected == false) {
      if (_isConnecting == false) {
        if (_url != null) {
          connect(this._url);
        }
      }
    } else {
      //Check for timeout
      if (_lastMessageTime != null) {
        var now = new DateTime.now();
        var diff = now.difference(_lastMessageTime);
        if (diff.inMilliseconds > _timeout) {
          _onTimeout();
        }
      }
      // Maybe check if URL has changed and reconnect
    }
  }
}
