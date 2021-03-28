import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ping_discover_network/ping_discover_network.dart';
import 'package:wifi/wifi.dart';
import './device_list_item.dart';
import './device.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Device Scanner',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(
        title: 'Local Device Scanner',
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Device> devices = [];

  Future<Null> _scanDevices() async {
    final String ip = await Wifi.ip;
    final String subnet = ip.substring(0, ip.lastIndexOf('.'));
    final int port = 80;

    final stream = NetworkAnalyzer.discover2(subnet, port);
    http.Client client = http.Client();

    stream.listen((NetworkAddress addr) {
      if (addr.exists) {
        print('Found device: ${addr.ip}');
        _testConnection(client, addr.ip);
      }
    });

    return null;
  }

  void _testConnection(final http.Client client, final String ip) async {
    try {
      final response = await client.get(Uri.parse('http://$ip/about'));
      if (response.statusCode == 200) {
        if (response.body.contains("type:forcegauge")) {
          var fields = response.body.split("\n");
          var name = "Forcegauge";
          var version = "unknown";
          for (var field in fields) {
            if (field.startsWith("name:")) {
              name = field.replaceFirst("name:", "");
            }
            if (field.startsWith("version:")) {
              version = field.replaceFirst("version:", "");
            }
          }

          if (!devices.contains(ip)) {
            print(
                'Found a device with ip $ip and name $name $version! Adding it to list of devices');
            setState(() {
              devices.add(
                Device(ip, name, version),
              );
            });
          }
        }
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () {
              devices.clear();
              _scanDevices();
            },
          ),
        ],
      ),
      backgroundColor: Color.fromARGB(255, 242, 244, 243),
      body: RefreshIndicator(
        onRefresh: () {},
        child: Flex(
          crossAxisAlignment: CrossAxisAlignment.start,
          direction: Axis.vertical,
          children: <Widget>[
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: devices.length,
                itemBuilder: (BuildContext ctxt, int index) {
                  return DeviceListItem(devices[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
