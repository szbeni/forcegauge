import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forcegauge/bloc/cubit/device_cubit.dart';
import 'package:forcegauge/bloc/cubit/devicemanager_cubit.dart';
import 'package:forcegauge/screens/history_tab/historylist_screen.dart';
import 'package:forcegauge/screens/settings_screen.dart';
import 'package:forcegauge/screens/navigation_drawer.dart';
import 'package:forcegauge/screens/tabata_tab/tabatalist_screen.dart';

import 'min_max_tab/device_graphview.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final List<Widget> _children = [
    DeviceGraphLists(),
    TabataListScreen(false),
    TabataListScreen(true),
    HistoryListScreen(),
  ];

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
      body: _children[_currentIndex],
      bottomNavigationBar:
          BottomNavigationBar(onTap: onTabTapped, type: BottomNavigationBarType.fixed, currentIndex: _currentIndex,
              //unselectedItemColor: BlocProvider.of<SettingsCubit>(context).settings.primarySwatch,
              //selectedItemColor: Colors.amber[800],
              items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart),
              label: 'MinMax',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.timer),
              label: 'Tabata',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.fitness_center),
              label: 'Taget',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.assessment),
              label: 'History',
            ),
          ]),
    );
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }
}

class DeviceGraphLists extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DevicemanagerCubit, DevicemanagerState>(builder: (context, state) {
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
