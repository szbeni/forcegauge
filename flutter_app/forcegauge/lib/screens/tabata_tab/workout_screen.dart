import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forcegauge/bloc/cubit/settings_cubit.dart';
import 'package:forcegauge/misc/format_time.dart';
import 'package:forcegauge/models/tabata/tabata.dart';

String stepName(WorkoutState step) {
  switch (step) {
    case WorkoutState.exercising:
      return 'Exercise';
    case WorkoutState.resting:
      return 'Rest';
    case WorkoutState.breaking:
      return 'Break';
    case WorkoutState.finished:
      return 'Finished';
    case WorkoutState.starting:
      return 'Starting';
    default:
      return '';
  }
}

class WorkoutScreen extends StatefulWidget {
  final Tabata tabata;

  WorkoutScreen({this.tabata});

  @override
  State<StatefulWidget> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  Workout _workout;

  @override
  initState() {
    super.initState();
    _workout = Workout(
        widget.tabata,
        BlocProvider.of<SettingsCubit>(context).settings.tabataSounds,
        this._onWorkoutChanged);
    _start();
  }

  @override
  dispose() {
    _workout.dispose();
    try {
      //Screen.keepOn(false);
    } catch (e) {}

    super.dispose();
  }

  _onWorkoutChanged() {
    if (_workout.step == WorkoutState.finished) {
      try {
        //Screen.keepOn(false);
      } catch (e) {}
    }
    this.setState(() {});
  }

  _getBackgroundColor(ThemeData theme) {
    switch (_workout.step) {
      case WorkoutState.exercising:
        return Colors.green;
      case WorkoutState.starting:
      case WorkoutState.resting:
        return Colors.blue;
      case WorkoutState.breaking:
        return Colors.red;
      default:
        return theme.scaffoldBackgroundColor;
    }
  }

  _pause() {
    _workout.pause();
    try {
      //Screen.keepOn(false);
    } catch (e) {}
  }

  _start() {
    _workout.start();
    try {
      //Screen.keepOn(true);
    } catch (e) {}
  }

  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var lightTextColor = theme.textTheme.bodyText2.color.withOpacity(0.8);
    return Scaffold(
      body: Container(
        color: _getBackgroundColor(theme),
        padding: EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          children: <Widget>[
            Expanded(child: Row()),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(stepName(_workout.step), style: TextStyle(fontSize: 60.0))
            ]),
            Divider(height: 32, color: lightTextColor),
            Container(
                width: MediaQuery.of(context).size.width,
                child: FittedBox(child: Text(formatTime(_workout.timeLeft)))),
            Divider(height: 32, color: lightTextColor),
            Table(columnWidths: {
              0: FlexColumnWidth(0.5),
              1: FlexColumnWidth(0.5),
              2: FlexColumnWidth(1.0)
            }, children: [
              TableRow(children: [
                TableCell(child: Text('Set', style: TextStyle(fontSize: 30.0))),
                TableCell(child: Text('Rep', style: TextStyle(fontSize: 30.0))),
                TableCell(
                    child: Text('Total Time',
                        textAlign: TextAlign.end,
                        style: TextStyle(fontSize: 30.0)))
              ]),
              TableRow(children: [
                TableCell(
                  child:
                      Text('${_workout.set}', style: TextStyle(fontSize: 60.0)),
                ),
                TableCell(
                  child:
                      Text('${_workout.rep}', style: TextStyle(fontSize: 60.0)),
                ),
                TableCell(
                    child: Text(
                  formatTime(_workout.totalTime),
                  style: TextStyle(fontSize: 60.0),
                  textAlign: TextAlign.right,
                ))
              ]),
            ]),
            Expanded(child: _buildButtonBar()),
          ],
        ),
      ),
    );
  }

  Widget _buildButtonBar() {
    if (_workout.step == WorkoutState.finished) {
      return Container();
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
            icon: Icon(_workout.isActive ? Icons.pause : Icons.play_arrow),
            onPressed: _workout.isActive ? _pause : _start),
        IconButton(
            icon: Icon(Icons.stop),
            onPressed: () {
              _workout.pause();
              Navigator.of(context).pop();
            }),
      ],
    );
  }
}
