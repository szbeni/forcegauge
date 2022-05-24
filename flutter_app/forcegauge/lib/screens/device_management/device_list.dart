import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forcegauge/bloc/cubit/device_cubit.dart';
import 'package:forcegauge/bloc/cubit/devicemanager_cubit.dart';
import 'package:forcegauge/bloc/cubit/settings_cubit.dart';
import 'package:forcegauge/bloc/cubit/tabatamanager_cubit.dart';
import 'package:forcegauge/models/devices/device.dart';

class DeviceList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final itemNameStyle = Theme.of(context).textTheme.headline6;

    return BlocBuilder<DevicemanagerCubit, DevicemanagerState>(
      builder: (context, state) {
        if (state is DevicemanagerInitial) {
          //return const CircularProgressIndicator();
          return const Text('Add a new device');
        } else {
          return ListView.builder(
              itemCount: state.devices.length,
              itemBuilder: (context, index) {
                return BlocProvider<DeviceCubit>(
                  create: (_) => DeviceCubit(state.devices[index]),
                  child: DeviceListTile(),
                );
              });
        }
        return const Text('Something went wrong!');
      },
    );
  }
}

class DeviceListTile extends StatelessWidget {
  void _sendTabatasDialog(BuildContext context, DeviceState state) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return new AlertDialog(title: new Text('Send tabatas to device: "${state.device.name}".'), actions: <Widget>[
            new FlatButton(
                child: new Text('Cancel'),
                // The alert is actually part of the navigation stack, so to close it, we
                // need to pop it.
                onPressed: () => Navigator.of(context).pop()),
            new FlatButton(
                child: new Text('Send tabatas'),
                onPressed: () {
                  // BlocProvider.of<DevicemanagerCubit>(context).removeDevice(state.device.name);
                  var tabatas = BlocProvider.of<TabatamanagerCubit>(context).getTabtas();
                  state.device.sendTabatas(tabatas);
                  //BlocProvider.of<DevicemanagerCubit>(context).sendTabatasToDevice(state.device.name);
                  Navigator.of(context).pop();
                })
          ]);
        });
  }

  void _removedDeviceDialog(BuildContext context, DeviceState state) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return new AlertDialog(title: new Text('Remove Device: "${state.device.name}".'), actions: <Widget>[
            new FlatButton(
                child: new Text('Cancel'),
                // The alert is actually part of the navigation stack, so to close it, we
                // need to pop it.
                onPressed: () => Navigator.of(context).pop()),
            new FlatButton(
                child: new Text('Remove'),
                onPressed: () {
                  BlocProvider.of<DevicemanagerCubit>(context).removeDevice(state.device.name);
                  Navigator.of(context).pop();
                })
          ]);
        });
  }

  // Build a single Device Item
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DeviceCubit, DeviceState>(
      builder: (context, state) {
        var connectedIcon = Icon(Icons.radio_button_checked, color: Colors.red);
        if (state.device.isConnected()) {
          connectedIcon = Icon(Icons.radio_button_checked, color: Colors.green);
        }
        return ListTile(
          title: Tooltip(
            message: state.device.connectionStatusMsg(),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [new Text("Name: " + state.device.name.toString()), connectedIcon],
            ),
          ),
          subtitle: new Text("Address: " + state.device.getUrl().toString()),
          onTap: () => _removedDeviceDialog(context, state),
          onLongPress: () {
            _sendTabatasDialog(context, state);
          },
        );
      },
    );
  }
}
