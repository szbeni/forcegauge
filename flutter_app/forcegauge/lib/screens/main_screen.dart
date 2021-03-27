import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forcegauge/bloc/cubit/device_cubit.dart';
import 'package:forcegauge/bloc/cubit/devicemanager_cubit.dart';
import 'package:forcegauge/screens/settings_screen.dart';
import 'package:forcegauge/screens/navigation_drawer.dart';
import 'package:forcegauge/screens/navigation_bottom.dart';

import 'device_graphview.dart';

class MainScreen extends StatelessWidget {
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
      body: DeviceGraphLists(),
      bottomNavigationBar: NavBottom(),
    );
  }
}

class DeviceGraphLists extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DevicemanagerCubit, DevicemanagerState>(
        builder: (context, state) {
      List<Widget> deviceGraphViewList = [];
      for (var i = 0; i < state.devices.length; i++) {
        var deviceGraphView = BlocProvider<DeviceCubit>(
          create: (_) => DeviceCubit(state.devices[i]),
          child: new DeviceGraphView(),
        );

        deviceGraphViewList.add(deviceGraphView);
      }
      return SingleChildScrollView(
        child: Column(
          children: deviceGraphViewList,
        ),
      );
    });
  }
}
