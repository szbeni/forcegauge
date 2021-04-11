import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forcegauge/bloc/cubit/settings_cubit.dart';
import 'package:forcegauge/bloc/cubit/tabatamanager_cubit.dart';
import 'package:forcegauge/misc/format_time.dart';
import 'package:forcegauge/models/tabata/tabata.dart';
import 'package:forcegauge/screens/tabata_tab/workout_screen.dart';
import 'package:forcegauge/widgets/decimalpicker.dart';
import 'package:forcegauge/widgets/durationpicker.dart';
import 'package:forcegauge/widgets/numberpickerdialog.dart';

class TabataScreen extends StatefulWidget {
  final Tabata tabata;

  TabataScreen({
    @required this.tabata,
  });

  @override
  State<StatefulWidget> createState() => _TabataScreenState();
}

class _TabataScreenState extends State<TabataScreen> {
  Tabata _tabata;

  @override
  initState() {
    _tabata = widget.tabata;
    super.initState();
  }

  _onTabataChanged() {
    BlocProvider.of<TabatamanagerCubit>(context).updateTabata(_tabata);
    setState(() {});
  }

  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(_tabata.name),
            leading: Icon(Icons.timer),
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
                      return NumberPickerDialog(
                        min: 1,
                        max: 30,
                        initialValue: _tabata.sets,
                        step: 1,
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
                      return NumberPickerDialog(
                        min: 1,
                        max: 30,
                        initialValue: _tabata.reps,
                        step: 1,
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
              ListTile(
                title: Text('Warning before break ends time'),
                subtitle: Text(formatTime(_tabata.warningBeforeBreakEndsTime)),
                leading: Icon(Icons.timer),
                onTap: () {
                  showDialog<Duration>(
                    context: context,
                    builder: (BuildContext context) {
                      return DurationPickerDialog(
                        initialDuration: _tabata.warningBeforeBreakEndsTime,
                        title: Text('Warning before break ends'),
                      );
                    },
                  ).then((warningBeforeBreakEndsTime) {
                    if (warningBeforeBreakEndsTime == null) return;
                    _tabata.warningBeforeBreakEndsTime = warningBeforeBreakEndsTime;
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
          // floatingActionButton: FloatingActionButton(
          //   onPressed: () {
          //     Navigator.push(
          //         context,
          //         MaterialPageRoute(
          //             builder: (context) => WorkoutScreen(
          //                   tabata: _tabata,
          //                   targetForce: widget.targetForceEnabled == false
          //                       ? 0
          //                       : BlocProvider.of<SettingsCubit>(context).settings.targetForce,
          //                 )));
          //   },
          //   backgroundColor: Theme.of(context).primaryColor,
          //   foregroundColor: Theme.of(context).primaryTextTheme.button.color,
          //   tooltip: 'Start Workout',
          //   child: Icon(Icons.play_arrow),
          // ),
        );
      },
    );
  }
}
