import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forcegauge/bloc/cubit/device_cubit.dart';
import 'package:forcegauge/bloc/cubit/settings_cubit.dart';

import 'package:forcegauge/bloc/cubit/tabatamanager_cubit.dart';
import 'package:forcegauge/models/tabata/tabata.dart';

import 'package:flutter/material.dart';
import 'package:forcegauge/screens/device_management/discover_devices_screen.dart';
import 'package:forcegauge/screens/device_management/add_new_device_screen.dart';
import 'package:forcegauge/screens/device_management/device_list.dart';

class TabataListScreen extends StatefulWidget {
  @override
  createState() => new TabataListScreenState();
}

class TabataListScreenState extends State<TabataListScreen> {
  String newDeviceName;

//  TextEditingController _textFieldController = TextEditingController();

  addNewTabataDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return new AlertDialog(
            title: new Text('New Tabata'),
            content: TextField(
              onChanged: (value) {
                setState(() {
                  newDeviceName = value;
                });
              },
              //controller: _textFieldController,
              decoration: InputDecoration(hintText: "MyWorkout"),
            ),
            actions: <Widget>[
              new TextButton(
                  child: new Text('Cancel'),
                  // The alert is actually part of the navigation stack, so to close it, we
                  // need to pop it.
                  onPressed: () => Navigator.of(context).pop()),
              new TextButton(
                  child: new Text('Add'),
                  onPressed: () {
                    print(newDeviceName);
                    BlocProvider.of<TabatamanagerCubit>(context).addTabata(newDeviceName);
                    Navigator.of(context).pop();
                  })
            ],
          );
        });
  }

  // Build the whole screen
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: TabataList(),
      floatingActionButton: new FloatingActionButton(
        onPressed: () => addNewTabataDialog(context),
        tooltip: 'Add Tabata',
        child: new Icon(Icons.add),
      ),
    );
  }
}

class TabataList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final itemNameStyle = Theme.of(context).textTheme.headline6;

    return BlocBuilder<TabatamanagerCubit, TabatamanagerState>(
      builder: (context, state) {
        if (state is TabatamanagerInitial && state.tabatas.length > 0) {
          //return const CircularProgressIndicator();
          return const Text('List is empty, add new tabata');
        } else {
          return ListView.builder(
              itemCount: state.tabatas.length,
              itemBuilder: (context, index) {
                print(state.tabatas[index].name);
                return TabataListTile(state.tabatas[index]);
              });
        }
      },
    );
  }
}

class TabataListTile extends StatelessWidget {
  Tabata _tabata;
  TabataListTile(this._tabata);
  void _removedDeviceDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return new AlertDialog(title: new Text('Remove Tabata: "${_tabata.name}".'), actions: <Widget>[
            new TextButton(
                child: new Text('Cancel'),
                // The alert is actually part of the navigation stack, so to close it, we
                // need to pop it.
                onPressed: () => Navigator.of(context).pop()),
            new TextButton(
                child: new Text('Remove'),
                onPressed: () {
                  BlocProvider.of<TabatamanagerCubit>(context).removeTabata(_tabata.name);
                  Navigator.of(context).pop();
                })
          ]);
        });
  }

  // Build a single Device Item
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Tooltip(
        message: _tabata.name,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            new Text(_tabata.name, style: TextStyle(fontWeight: FontWeight.bold)),
            new Icon(Icons.remove_circle),
          ],
        ),
      ),
      subtitle: new Text(
          "Sets: ${_tabata.sets}, Break: ${_tabata.breakTime.inSeconds}, Reps:  ${_tabata.sets},  Rest: ${_tabata.restTime.inSeconds}"),
      onTap: () => _removedDeviceDialog(context),
    );
  }
}
