import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:forcegauge/screens/pushed_screen.dart';
import 'package:forcegauge/models/socket_manager_web.dart'
    if (dart.library.io) 'package:forcegauge/models/socket_manager.dart';
import 'dart:developer';
//import 'package:web_socket_channel/io.dart';
//import 'package:web_socket_channel/html.dart';
//import 'package:universal_html/html.dart'
//import 'package:forcegauge/models/force_data.dart';

class FirstScreen extends StatefulWidget {
  static const route = '/first';

  @override
  _FirstScreenState createState() => _FirstScreenState();
}

class _FirstScreenState extends State<FirstScreen> {
  double lastValue = 0;
  double lastRawValue = 0;
  double maxValue = 0;
  double minValue = 0;
  bool wasError = false;

  //HtmlWebSocketChannel channel;

  @override
  void initState() {
    // if (widget.onInit != null) {
    //   widget.onInit();
    // }
    //this.channel = HtmlWebSocketChannel.connect("ws://192.168.3.99:81");
    //this.channel.stream.listen(_onMessageReceived);
    sockets.initCommunication();
    sockets.addListener(_onMessageReceived);
    super.initState();
  }

  _onMessageReceived(msg) {
    try {
      var message = jsonDecode(msg);
      var data = message['data'];
      if (data is List) {
        // var time = data[data.length - 1]['time'];
        // var raw = data[data.length - 1]['raw'];
        this.lastRawValue = double.parse(data[data.length - 1]['raw']);
        this.lastValue = double.parse(data[data.length - 1]['value']);
        if (this.lastValue > this.maxValue) {
          this.maxValue = this.lastValue;
        }
        if (this.lastValue < this.minValue) {
          this.minValue = this.lastValue;
        }
      }
    } catch (e) {}

    setState(() {});
  }

  clearMaxMin() {
    this.maxValue = 0;
    this.minValue = 0;
    setState(() {});
  }

  resetOffset() {
    this.wasError = false;
    sockets.send("offset:$lastRawValue");
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Force Gauge'),
      ),
      body: new Center(
          child: Column(
        children: [
          new RaisedButton(
            onPressed: () => {resetOffset()},
            child: new Text("Reset Offset"),
          ),
          new RaisedButton(
            onPressed: () => {clearMaxMin()},
            child: new Text("Clear Max/Min"),
          ),
          new Text(
            "${lastValue}",
            style: TextStyle(fontSize: 50),
          ),
          new Text(
            "Max Value: ${maxValue}",
            style: TextStyle(fontSize: 20),
          ),
          new Text(
            "Min Value: ${minValue}",
            style: TextStyle(fontSize: 20),
          )
        ],
      )),
    );
  }
}

// class FirstScreen extends StatefulWidget {
//   static const route = '/first';

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('First Screen')),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             RaisedButton(
//               onPressed: () {
//                 // Push with bottom navigation visible
//                 Navigator.of(
//                   context,
//                   rootNavigator: false,
//                 ).pushNamed(PushedScreen.route);
//               },
//               child: Text('Push route with bottom bar'),
//             ),
//             RaisedButton(
//               onPressed: () {
//                 // Push without bottom navigation
//                 Navigator.of(
//                   context,
//                   rootNavigator: true,
//                 ).pushNamed(PushedScreen.route);
//               },
//               child: Text('Push route without bottom bar'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
