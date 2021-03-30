import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:forcegauge/bloc/cubit/settings_cubit.dart';
import 'package:forcegauge/models/settings.dart';
import 'package:numberpicker/numberpicker.dart';

/// Names of colours in Colors.primaries
var colorNames = {
  Colors.red: 'Red',
  Colors.pink: 'Pink',
  Colors.purple: 'Purple',
  Colors.deepPurple: 'Deep purple',
  Colors.indigo: 'Indigo',
  Colors.blue: 'Blue',
  Colors.lightBlue: 'Light blue',
  Colors.cyan: 'Cyan',
  Colors.teal: 'Teal',
  Colors.green: 'Green',
  Colors.lightGreen: 'Light green',
  Colors.lime: 'Lime',
  Colors.yellow: 'Yellow',
  Colors.amber: 'Amber',
  Colors.orange: 'Orange',
  Colors.deepOrange: 'Deep orange',
  Colors.brown: 'Brown',
  Colors.blueGrey: 'Blue grey',
};

class SettingsScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SettingsScreenState();
}

class AudioSelectListItem extends StatelessWidget {
  final String title;
  final String value;
  final Function(String) onChanged;

  AudioSelectListItem(
      {@required this.title, @required this.onChanged, this.value});

  Widget build(BuildContext context) {
    return ListTile(
      trailing: IconButton(
        icon: Icon(Icons.play_circle_outline),
        onPressed: () {
          //player.play(value);
        },
      ),
      title: Text(title, style: Theme.of(context).textTheme.subtitle2),
      subtitle: DropdownButton<String>(
        isDense: true,
        value: value,
        items: [
          DropdownMenuItem(child: Text('Low Beep'), value: 'pip.mp3'),
          DropdownMenuItem(child: Text('High Beep'), value: 'boop.mp3'),
          DropdownMenuItem(
              child: Text('Ding Ding Ding!'), value: 'dingdingding.mp3'),
        ],
        isExpanded: true,
        onChanged: onChanged,
      ),
    );
  }
}

class _SettingsScreenState extends State<SettingsScreen> {
  Future _showInfIntDialog() async {
    await showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return new NumberPickerDialog.integer(
          minValue: 50,
          maxValue: 250,
          step: 5,
          initialIntegerValue:
              BlocProvider.of<SettingsCubit>(context).settings.fontSize.toInt(),
          infiniteLoop: true,
        );
      },
    ).then((num value) {
      if (value != null) {
        setState(() {
          BlocProvider.of<SettingsCubit>(context).settings.fontSize =
              value.toDouble();
          BlocProvider.of<SettingsCubit>(context).saveSettings();
        });
      }
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: new ListView(
        children: <Widget>[
          // TextFormField(
          //   decoration: InputDecoration(labelText: 'DeviceURL'),
          //   initialValue: settings.deviceUrl,
          //   onChanged: (String url) {
          //     settings.deviceUrl = url;
          //     settings.onSettingsChanged();
          //   },
          // ),
          ListTile(
            title: Text(
              'Theme',
              style: Theme.of(context).textTheme.subtitle2,
            ),
          ),
          SwitchListTile(
            title: Text('Night mode'),
            value: BlocProvider.of<SettingsCubit>(context).settings.nightMode,
            onChanged: (nightMode) {
              BlocProvider.of<SettingsCubit>(context).settings.nightMode =
                  nightMode;
              BlocProvider.of<SettingsCubit>(context).saveSettings();
            },
          ),
          SwitchListTile(
            title: Text('Silent mode'),
            value: BlocProvider.of<SettingsCubit>(context).settings.silentMode,
            onChanged: (silentMode) {
              BlocProvider.of<SettingsCubit>(context).settings.silentMode =
                  silentMode;
              BlocProvider.of<SettingsCubit>(context).saveSettings();
            },
          ),
          ListTile(
            title: Text(
              'Devices',
              style: Theme.of(context).textTheme.subtitle2,
            ),
          ),
          ListTile(
            title: Text('Theme Color'),
            subtitle: Text(colorNames[BlocProvider.of<SettingsCubit>(context)
                .settings
                .primarySwatch]),
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    content: SingleChildScrollView(
                      child: BlockPicker(
                        availableColors: Colors.primaries,
                        pickerColor: BlocProvider.of<SettingsCubit>(context)
                            .settings
                            .primarySwatch,
                        onColorChanged: (Color color) {
                          BlocProvider.of<SettingsCubit>(context)
                              .settings
                              .primarySwatch = color;
                          BlocProvider.of<SettingsCubit>(context)
                              .saveSettings();
                        },
                      ),
                    ),
                  );
                },
              );
            },
          ),
          ListTile(
            title: Text('Font Size'),
            subtitle: Text(
                '${BlocProvider.of<SettingsCubit>(context).settings.fontSize}'),
            onTap: () {
              _showInfIntDialog();
            },
          ),

          Divider(height: 10),
          ListTile(
            title: Text(
              'Sounds',
              style: Theme.of(context).textTheme.subtitle2,
            ),
          ),
          AudioSelectListItem(
            value: BlocProvider.of<SettingsCubit>(context)
                .settings
                .tabataSounds
                .countdownPip,
            title: 'Countdown pips',
            onChanged: (String value) {
              BlocProvider.of<SettingsCubit>(context)
                  .settings
                  .tabataSounds
                  .countdownPip = value;
              BlocProvider.of<SettingsCubit>(context).saveSettings();
            },
          ),
          AudioSelectListItem(
            value: BlocProvider.of<SettingsCubit>(context)
                .settings
                .tabataSounds
                .startRep,
            title: 'Start next rep',
            onChanged: (String value) {
              BlocProvider.of<SettingsCubit>(context)
                  .settings
                  .tabataSounds
                  .startRep = value;
              BlocProvider.of<SettingsCubit>(context).saveSettings();
            },
          ),
          AudioSelectListItem(
            value: BlocProvider.of<SettingsCubit>(context)
                .settings
                .tabataSounds
                .startRest,
            title: 'Rest',
            onChanged: (String value) {
              BlocProvider.of<SettingsCubit>(context)
                  .settings
                  .tabataSounds
                  .startRest = value;
              BlocProvider.of<SettingsCubit>(context).saveSettings();
            },
          ),
          AudioSelectListItem(
            value: BlocProvider.of<SettingsCubit>(context)
                .settings
                .tabataSounds
                .startBreak,
            title: 'Break',
            onChanged: (String value) {
              BlocProvider.of<SettingsCubit>(context)
                  .settings
                  .tabataSounds
                  .startBreak = value;
              BlocProvider.of<SettingsCubit>(context).saveSettings();
            },
          ),
          AudioSelectListItem(
            value: BlocProvider.of<SettingsCubit>(context)
                .settings
                .tabataSounds
                .startSet,
            title: 'Start next set',
            onChanged: (String value) {
              BlocProvider.of<SettingsCubit>(context)
                  .settings
                  .tabataSounds
                  .startSet = value;
              BlocProvider.of<SettingsCubit>(context).saveSettings();
            },
          ),
          AudioSelectListItem(
            value: BlocProvider.of<SettingsCubit>(context)
                .settings
                .tabataSounds
                .endWorkout,
            title: 'End workout (plays twice)',
            onChanged: (String value) {
              BlocProvider.of<SettingsCubit>(context)
                  .settings
                  .tabataSounds
                  .endWorkout = value;
              BlocProvider.of<SettingsCubit>(context).saveSettings();
            },
          ),
        ],
      ),
    );
  }
}
