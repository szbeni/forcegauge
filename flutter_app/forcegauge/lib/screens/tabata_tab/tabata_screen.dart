import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forcegauge/bloc/cubit/settings_cubit.dart';
import 'package:forcegauge/misc/format_time.dart';
import 'package:forcegauge/models/tabata/tabata.dart';
import 'package:forcegauge/screens/tabata_tab/workout_screen.dart';
import 'package:forcegauge/widgets/durationpicker.dart';
import 'package:numberpicker/numberpicker.dart';

class TabataScreen extends StatefulWidget {
  //final Settings settings;
  //final SharedPreferences prefs;
  final Function onSettingsChanged;

  TabataScreen({
    //@required this.settings,
    //@required this.prefs,
    @required this.onSettingsChanged,
  });

  @override
  State<StatefulWidget> createState() => _TabataScreenState();
}

class _TabataScreenState extends State<TabataScreen> {
  Tabata _tabata;

  @override
  initState() {
    BlocProvider.of<SettingsCubit>(context).loadTabata();
    super.initState();
  }

  _onTabataChanged() {
    setState(() {});
    _saveTabata();
  }

  _saveTabata() {
    BlocProvider.of<SettingsCubit>(context).saveTabata(_tabata);
  }

  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        if (state is SettingsStateTabataLoaded) {
          _tabata = state.tabata;
        }
        if (_tabata == null) {
          return Container();
        } else
          return Scaffold(
            appBar: AppBar(
              title: Text('Tabata Timer'),
              leading: Icon(Icons.timer),
              // actions: <Widget>[
              //   Builder(
              //     builder: (context) => IconButton(
              //       icon: Icon(Icons.volume_off),
              //       //icon: Icon(widget.settings.silentMode? Icons.volume_off: Icons.volume_up),
              //       onPressed: () {
              //         //widget.settings.silentMode = !widget.settings.silentMode;
              //         // widget.onSettingsChanged();
              //         // var snackBar = SnackBar(
              //         //     duration: Duration(seconds: 1),
              //         //     content: Text('Silent mode ${!widget.settings.silentMode ? 'de' : ''}activated'));
              //         // Scaffold.of(context).showSnackBar(snackBar);
              //       },
              //       tooltip: 'Toggle silent mode',
              //     ),
              //   ),
              //   IconButton(
              //     icon: Icon(
              //       Icons.settings,
              //     ),
              //     onPressed: () {
              //       // Navigator.push(
              //       //   context,
              //       //   MaterialPageRoute(
              //       //     builder: (context) => SettingsScreen(
              //       //         settings: widget.settings,
              //       //         onSettingsChanged: widget.onSettingsChanged),
              //       //   ),
              //       // );
              //     },
              //     tooltip: 'Settings',
              //   ),
              // ],
            ),
            body: ListView(
              children: <Widget>[
                ListTile(
                  title: Text('Sets'),
                  subtitle: Text('${_tabata.sets}'),
                  leading: Icon(Icons.fitness_center),
                  onTap: () {
                    showDialog<int>(
                      context: context,
                      builder: (BuildContext context) {
                        return NumberPickerDialog.integer(
                          minValue: 1,
                          maxValue: 10,
                          initialIntegerValue: _tabata.sets,
                          title: Text('Sets in the workout'),
                        );
                      },
                    ).then((sets) {
                      if (sets == null) return;
                      _tabata.sets = sets;
                      _onTabataChanged();
                    });
                  },
                ),
                ListTile(
                  title: Text('Reps'),
                  subtitle: Text('${_tabata.reps}'),
                  leading: Icon(Icons.repeat),
                  onTap: () {
                    showDialog<int>(
                      context: context,
                      builder: (BuildContext context) {
                        return NumberPickerDialog.integer(
                          minValue: 1,
                          maxValue: 10,
                          initialIntegerValue: _tabata.reps,
                          title: Text('Repetitions in each set'),
                        );
                      },
                    ).then((reps) {
                      if (reps == null) return;
                      _tabata.reps = reps;
                      _onTabataChanged();
                    });
                  },
                ),
                Divider(
                  height: 10,
                ),
                ListTile(
                  title: Text('Starting Countdown'),
                  subtitle: Text(formatTime(_tabata.startDelay)),
                  leading: Icon(Icons.timer),
                  onTap: () {
                    showDialog<Duration>(
                      context: context,
                      builder: (BuildContext context) {
                        return DurationPickerDialog(
                          initialDuration: _tabata.startDelay,
                          title: Text('Countdown before starting workout'),
                        );
                      },
                    ).then((startDelay) {
                      if (startDelay == null) return;
                      _tabata.startDelay = startDelay;
                      _onTabataChanged();
                    });
                  },
                ),
                ListTile(
                  title: Text('Exercise Time'),
                  subtitle: Text(formatTime(_tabata.exerciseTime)),
                  leading: Icon(Icons.timer),
                  onTap: () {
                    showDialog<Duration>(
                      context: context,
                      builder: (BuildContext context) {
                        return DurationPickerDialog(
                          initialDuration: _tabata.exerciseTime,
                          title: Text('Excercise time per repetition'),
                        );
                      },
                    ).then((exerciseTime) {
                      if (exerciseTime == null) return;
                      _tabata.exerciseTime = exerciseTime;
                      _onTabataChanged();
                    });
                  },
                ),
                ListTile(
                  title: Text('Rest Time'),
                  subtitle: Text(formatTime(_tabata.restTime)),
                  leading: Icon(Icons.timer),
                  onTap: () {
                    showDialog<Duration>(
                      context: context,
                      builder: (BuildContext context) {
                        return DurationPickerDialog(
                          initialDuration: _tabata.restTime,
                          title: Text('Rest time between repetitions'),
                        );
                      },
                    ).then((restTime) {
                      if (restTime == null) return;
                      _tabata.restTime = restTime;
                      _onTabataChanged();
                    });
                  },
                ),
                ListTile(
                  title: Text('Break Time'),
                  subtitle: Text(formatTime(_tabata.breakTime)),
                  leading: Icon(Icons.timer),
                  onTap: () {
                    showDialog<Duration>(
                      context: context,
                      builder: (BuildContext context) {
                        return DurationPickerDialog(
                          initialDuration: _tabata.breakTime,
                          title: Text('Break time between sets'),
                        );
                      },
                    ).then((breakTime) {
                      if (breakTime == null) return;
                      _tabata.breakTime = breakTime;
                      _onTabataChanged();
                    });
                  },
                ),
                Divider(height: 10),
                ListTile(
                  title: Text(
                    'Total Time',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  subtitle: Text(formatTime(_tabata.getTotalTime())),
                  leading: Icon(Icons.timelapse),
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => WorkoutScreen(tabata: _tabata)));
              },
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Theme.of(context).primaryTextTheme.button.color,
              tooltip: 'Start Workout',
              child: Icon(Icons.play_arrow),
            ),
          );
      },
    );
  }
}
