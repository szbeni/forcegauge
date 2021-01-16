import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:forcegauge/models/settings.dart';

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
  @override
  void initState() {
    settings.addListener(onSettingsChanged);
    super.initState();
  }

  @override
  dispose() {
    settings.removeListener(onSettingsChanged);
    super.dispose();
  }

  onSettingsChanged() {
    setState(() {});
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
            value: settings.nightMode,
            onChanged: (nightMode) {
              settings.nightMode = nightMode;
              settings.onSettingsChanged();
            },
          ),
          SwitchListTile(
            title: Text('Silent mode'),
            value: settings.silentMode,
            onChanged: (silentMode) {
              settings.silentMode = silentMode;
              settings.onSettingsChanged();
            },
          ),
          ListTile(
            title: Text(
              'Devices',
              style: Theme.of(context).textTheme.subtitle2,
            ),
          ),
          ListTile(
            title: Text('Light theme'),
            subtitle: Text(colorNames[settings.primarySwatch]),
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    content: SingleChildScrollView(
                      child: BlockPicker(
                        availableColors: Colors.primaries,
                        pickerColor: settings.primarySwatch,
                        onColorChanged: (Color color) {
                          settings.primarySwatch = color;
                          settings.onSettingsChanged();
                        },
                      ),
                    ),
                  );
                },
              );
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
            value: settings.countdownPip,
            title: 'Countdown pips',
            onChanged: (String value) {
              settings.countdownPip = value;
              settings.onSettingsChanged();
            },
          ),
          AudioSelectListItem(
            value: settings.startRep,
            title: 'Start next rep',
            onChanged: (String value) {
              settings.startRep = value;
              settings.onSettingsChanged();
            },
          ),
          AudioSelectListItem(
            value: settings.startRest,
            title: 'Rest',
            onChanged: (String value) {
              settings.startRest = value;
              settings.onSettingsChanged();
            },
          ),
          AudioSelectListItem(
            value: settings.startBreak,
            title: 'Break',
            onChanged: (String value) {
              settings.startBreak = value;
              settings.onSettingsChanged();
            },
          ),
          AudioSelectListItem(
            value: settings.startSet,
            title: 'Start next set',
            onChanged: (String value) {
              settings.startSet = value;
              settings.onSettingsChanged();
            },
          ),
          AudioSelectListItem(
            value: settings.endWorkout,
            title: 'End workout (plays twice)',
            onChanged: (String value) {
              settings.endWorkout = value;
              settings.onSettingsChanged();
            },
          ),
        ],
      ),
    );
  }
}
