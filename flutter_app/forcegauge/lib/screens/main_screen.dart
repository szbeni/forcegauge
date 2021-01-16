import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:forcegauge/screens/settings_screen.dart';
import 'package:forcegauge/screens/nav_drawer.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavDrawer(),
      appBar: new AppBar(title: new Text('Force Gauge'), actions: <Widget>[
        IconButton(
          icon: Icon(
            Icons.settings,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SettingsScreen(),
              ),
            );
          },
          tooltip: 'Settings',
        )
      ]),
      body: new Center(
          child: Column(
        children: [
          // new RaisedButton(
          //   onPressed: () => {resetOffset()},
          //   child: new Text("Reset Offset"),
          // ),
          // new RaisedButton(
          //   onPressed: () => {clearMaxMin()},
          //   child: new Text("Clear Max/Min"),
          // ),
          new Text(
            "0",
            style: TextStyle(fontSize: 50),
          ),
          new Text(
            "Max Value: 0",
            style: TextStyle(fontSize: 20),
          ),
          new Text(
            "Min Value: 0",
            style: TextStyle(fontSize: 20),
          )
        ],
      )),
    );
  }
}
