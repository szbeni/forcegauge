import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forcegauge/bloc/cubit/devicemanager_cubit.dart';

class DeviceList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final itemNameStyle = Theme.of(context).textTheme.headline6;

    return BlocBuilder<DevicemanagerCubit, DevicemanagerState>(
      builder: (context, state) {
        if (state is DevicemanagerInitial) {
          return const CircularProgressIndicator();
          return const Text('Empty');
        }
        if (state is DevicemanagerPopulated) {
          return ListView.builder(
            itemCount: state.devices.length,
            itemBuilder: (context, index) => ListTile(
              leading: const Icon(Icons.done),
              title: Text(
                state.devices[index].name,
                style: itemNameStyle,
              ),
            ),
          );
        }
        return const Text('Something went wrong!');
      },
    );
  }
}
