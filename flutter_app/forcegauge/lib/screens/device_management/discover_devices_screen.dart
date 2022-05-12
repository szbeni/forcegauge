import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forcegauge/bloc/cubit/devicemanager_cubit.dart';
import 'package:forcegauge/models/network_analyzer.dart';
import 'package:http/http.dart' as http;

import 'package:network_info_plus/network_info_plus.dart';

class Device {
  String ipAddress = "";
  String name = "";
  String version = "";
  Device(this.ipAddress, this.name, this.version);
}

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
      onTap: () {
        var deviceName = _device.name;
        var deviceUrl = "ws://" + _device.ipAddress + ":81";
        if (deviceName.length > 0 && deviceUrl.length > 0) {
          BlocProvider.of<DevicemanagerCubit>(context).addDevice(deviceName, deviceUrl);
        }
        Navigator.of(context).pop();
      },
    );
  }
}

class DiscoverDevicesScreen extends StatefulWidget {
  DiscoverDevicesScreen();
  @override
  _DiscoverDevicesScreenState createState() => _DiscoverDevicesScreenState();
}

class _DiscoverDevicesScreenState extends State<DiscoverDevicesScreen> {
  List<Device> devices = [];

  bool scanInProgress = false;
  @override
  initState() {
    this.scanInProgress = false;
    super.initState();
    this._scanDevices();
  }

  Future<Null> _scanDevices() async {
    if (scanInProgress == true) {
      print("Scan is already in progress");
      return;
    }
    final info = NetworkInfo();
    final String ip = await info.getWifiIP();
    final String subnet = ip.substring(0, ip.lastIndexOf('.'));
    final int port = 80;
    print("Scan started");
    scanInProgress = true;

    http.Client client = http.Client();
    final stream = NetworkAnalyzer.discover2(subnet, port);
    stream.listen((NetworkAddress addr) {
      if (addr.exists) {
        print('Found online IP: ${addr.ip}');
        _testConnection(client, addr.ip);
      }
    }).onDone(() {
      print("Scan finished");
      scanInProgress = false;
    });

    return null;
  }

  void _testConnection(final http.Client client, final String ip) async {
    try {
      final response = await client.get(Uri.parse('http://$ip/about'));
      print(ip);
      print(response.statusCode);
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
            print('Device found: $ip, $name, $version');
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
        title: Text("Discover Devices"),
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
