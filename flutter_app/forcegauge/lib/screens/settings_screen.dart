import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:forcegauge/bloc/cubit/settings_cubit.dart';
import 'package:forcegauge/models/settings.dart';
import 'package:forcegauge/widgets/numberpickerdialog.dart';
import 'package:numberpicker/numberpicker.dart';

import '../main.dart';

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

  AudioSelectListItem({@required this.title, @required this.onChanged, this.value});

  generateSoundDropdownMenu() {
    List<DropdownMenuItem<String>> menu = [];
    for (var k in Settings.soundFiles.keys) {
      var menuItem = DropdownMenuItem(child: Text(k), value: Settings.soundFiles[k]);
      menu.add(menuItem);
    }
    return menu;
  }

  Widget build(BuildContext context) {
    return ListTile(
      trailing: IconButton(
        icon: Icon(Icons.play_circle_outline),
        onPressed: () {
          if (value == null || value.length == 0) return;
          AssetsAudioPlayer.newPlayer().open(
            Audio("assets/sounds/" + value),
            showNotification: false,
            autoStart: true,
          );
        },
      ),
      title: Text(title, style: Theme.of(context).textTheme.subtitle2),
      subtitle: DropdownButton<String>(
        isDense: true,
        value: value,
        items: generateSoundDropdownMenu(),
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
        return new NumberPickerDialog(
          initialValue: BlocProvider.of<SettingsCubit>(context).settings.fontSize.toInt(),
          min: 50,
          max: 250,
          step: 5,
          title: Text("Select Font size"),
        );
      },
    ).then((num value) {
      if (value != null) {
        setState(() {
          BlocProvider.of<SettingsCubit>(context).settings.fontSize = value.toDouble();
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
              BlocProvider.of<SettingsCubit>(context).settings.nightMode = nightMode;
              BlocProvider.of<SettingsCubit>(context).saveSettings();
            },
          ),
          SwitchListTile(
            title: Text('Silent mode'),
            value: BlocProvider.of<SettingsCubit>(context).settings.silentMode,
            onChanged: (silentMode) {
              BlocProvider.of<SettingsCubit>(context).settings.silentMode = silentMode;
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
            subtitle: Text(colorNames[BlocProvider.of<SettingsCubit>(context).settings.primarySwatch]),
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    content: SingleChildScrollView(
                      child: BlockPicker(
                        availableColors: Colors.primaries,
                        pickerColor: BlocProvider.of<SettingsCubit>(context).settings.primarySwatch,
                        onColorChanged: (Color color) {
                          BlocProvider.of<SettingsCubit>(context).settings.primarySwatch = color;
                          BlocProvider.of<SettingsCubit>(context).saveSettings();
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
            subtitle: Text('${BlocProvider.of<SettingsCubit>(context).settings.fontSize}'),
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
            value: BlocProvider.of<SettingsCubit>(context).settings.tabataSounds.countdownPip,
            title: 'Countdown pips',
            onChanged: (String value) {
              BlocProvider.of<SettingsCubit>(context).settings.tabataSounds.countdownPip = value;
              BlocProvider.of<SettingsCubit>(context).saveSettings();
            },
          ),
          AudioSelectListItem(
            value: BlocProvider.of<SettingsCubit>(context).settings.tabataSounds.startRep,
            title: 'Start next rep',
            onChanged: (String value) {
              BlocProvider.of<SettingsCubit>(context).settings.tabataSounds.startRep = value;
              BlocProvider.of<SettingsCubit>(context).saveSettings();
            },
          ),
          AudioSelectListItem(
            value: BlocProvider.of<SettingsCubit>(context).settings.tabataSounds.startRest,
            title: 'Rest',
            onChanged: (String value) {
              BlocProvider.of<SettingsCubit>(context).settings.tabataSounds.startRest = value;
              BlocProvider.of<SettingsCubit>(context).saveSettings();
            },
          ),
          AudioSelectListItem(
            value: BlocProvider.of<SettingsCubit>(context).settings.tabataSounds.startBreak,
            title: 'Break',
            onChanged: (String value) {
              BlocProvider.of<SettingsCubit>(context).settings.tabataSounds.startBreak = value;
              BlocProvider.of<SettingsCubit>(context).saveSettings();
            },
          ),
          AudioSelectListItem(
            value: BlocProvider.of<SettingsCubit>(context).settings.tabataSounds.startSet,
            title: 'Start next set',
            onChanged: (String value) {
              BlocProvider.of<SettingsCubit>(context).settings.tabataSounds.startSet = value;
              BlocProvider.of<SettingsCubit>(context).saveSettings();
            },
          ),
          AudioSelectListItem(
            value: BlocProvider.of<SettingsCubit>(context).settings.tabataSounds.warningBeforeBreakEnds,
            title: 'Warning Before break',
            onChanged: (String value) {
              BlocProvider.of<SettingsCubit>(context).settings.tabataSounds.warningBeforeBreakEnds = value;
              BlocProvider.of<SettingsCubit>(context).saveSettings();
            },
          ),
          AudioSelectListItem(
            value: BlocProvider.of<SettingsCubit>(context).settings.tabataSounds.endWorkout,
            title: 'End workout (plays twice)',
            onChanged: (String value) {
              BlocProvider.of<SettingsCubit>(context).settings.tabataSounds.endWorkout = value;
              BlocProvider.of<SettingsCubit>(context).saveSettings();
            },
          ),
          AudioSelectListItem(
            value: BlocProvider.of<SettingsCubit>(context).settings.tabataSounds.targetReached,
            title: 'Taget Force Reached',
            onChanged: (String value) {
              BlocProvider.of<SettingsCubit>(context).settings.tabataSounds.targetReached = value;
              BlocProvider.of<SettingsCubit>(context).saveSettings();
            },
          ),
        ],
      ),
    );
  }
}
