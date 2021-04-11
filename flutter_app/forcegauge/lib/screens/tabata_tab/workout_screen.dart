import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forcegauge/bloc/cubit/device_cubit.dart';
import 'package:forcegauge/bloc/cubit/devicemanager_cubit.dart';
import 'package:forcegauge/bloc/cubit/settings_cubit.dart';
import 'package:forcegauge/misc/format_time.dart';
import 'package:forcegauge/models/tabata/report.dart';
import 'package:forcegauge/models/tabata/tabata.dart';
import 'package:forcegauge/models/tabata/workout.dart';
import 'package:forcegauge/screens/tabata_tab/report_graph.dart';

class WorkoutScreen extends StatefulWidget {
  final double targetForce;
  final Tabata tabata;

  WorkoutScreen({this.tabata, this.targetForce = 0});

  @override
  State<StatefulWidget> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  Workout _workout;

  @override
  initState() {
    super.initState();
    var tabataSounds = BlocProvider.of<SettingsCubit>(context).settings.tabataSounds;
    _workout = Workout(widget.tabata, tabataSounds, widget.targetForce, this._onWorkoutChanged);
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
        return Colors.red;
      case WorkoutState.starting:
        return Colors.green;
      case WorkoutState.resting:
        return Colors.lightBlue;
      case WorkoutState.breaking:
        return Colors.blue;
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

  Widget makeReportView(Map<String, ReportValues> reports) {
    var table = Table(border: TableBorder.all(), // Allows to add a border decoration around your table
        children: [
          TableRow(children: [
            Text('Workout', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('Min', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('Max', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('Average', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('Graph', style: TextStyle(fontWeight: FontWeight.bold)),
            //TextButton(onPressed: onPressed, child: Text("+"));
          ]),
        ]);
    for (var report in reports.keys) {
      var reportWidget = TableRow(children: [
        Text(report),
        Text(reports[report].getMin().toStringAsFixed(1)),
        Text(reports[report].getMax().toStringAsFixed(1)),
        Text(reports[report].getAverage().toStringAsFixed(1)),
        IconButton(
            icon: Icon(Icons.show_chart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ReportGraph(reports[report]),
                ),
              );
            })
      ]);
      table.children.add(reportWidget);
    }

    return table;
  }

  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var lightTextColor = theme.textTheme.bodyText2.color.withOpacity(0.8);
    var forceTextBox = BlocBuilder<DevicemanagerCubit, DevicemanagerState>(builder: (context, state) {
      if (!(state is DevicemanagerInitial) && state.devices.length > 0) {
        return BlocProvider<DeviceCubit>(
          create: (_) => DeviceCubit(state.devices[0]),
          child: BlocBuilder<DeviceCubit, DeviceState>(builder: (context, state) {
            _workout.newForceValue(state.device.lastValue.abs());
            if (_workout.step == WorkoutState.exercising) {
              return Text(state.device.lastValue.toStringAsFixed(1), style: TextStyle(fontSize: 60.0));
            } else {
              var lastReport = _workout.workoutReport.getSetRepReport(_workout.set, _workout.rep);

              if (lastReport != null) {
                return Column(children: [
                  Text(state.device.lastValue.toStringAsFixed(1), style: TextStyle(fontSize: 20.0)),
                  Text("Min: " + lastReport.getMin().toStringAsFixed(1), style: TextStyle(fontSize: 20.0)),
                  Text("Max: " + lastReport.getMax().toStringAsFixed(1), style: TextStyle(fontSize: 20.0)),
                  Text("Avg: " + lastReport.getAverage().toStringAsFixed(1), style: TextStyle(fontSize: 20.0)),
                ]);
              } else {
                return Text(state.device.lastValue.toStringAsFixed(1), style: TextStyle(fontSize: 40.0));
              }
            }
          }),
        );
      } else {
        return Text("");
      }
    });

    var tabataScreen;
    if (_workout.step == WorkoutState.finished) {
      var reportScreen = makeReportView(_workout.workoutReport.getAllReports());

      tabataScreen = SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("", style: TextStyle(fontSize: 20.0)),
            Text("Report", style: TextStyle(fontSize: 60.0)),
            reportScreen,
          ],
        ),
      );
    } else {
      tabataScreen = Column(
        children: <Widget>[
          Expanded(child: Row()),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [forceTextBox],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [Text(Workout.stepName(_workout.step), style: TextStyle(fontSize: 60.0))],
          ),
          Divider(height: 32, color: lightTextColor),
          Container(width: MediaQuery.of(context).size.width, child: FittedBox(child: Text(formatTime(_workout.timeLeft)))),
          Divider(height: 32, color: lightTextColor),
          Table(columnWidths: {
            0: FlexColumnWidth(0.5),
            1: FlexColumnWidth(0.5),
            2: FlexColumnWidth(1.0)
          }, children: [
            TableRow(children: [
              TableCell(child: Text('Set', style: TextStyle(fontSize: 30.0))),
              TableCell(child: Text('Rep', style: TextStyle(fontSize: 30.0))),
              TableCell(child: Text('Total Time', textAlign: TextAlign.end, style: TextStyle(fontSize: 30.0)))
            ]),
            TableRow(children: [
              TableCell(
                child: Text('${_workout.set}', style: TextStyle(fontSize: 60.0)),
              ),
              TableCell(
                child: Text('${_workout.rep}', style: TextStyle(fontSize: 60.0)),
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
      );
    }

    return Scaffold(
      body: Container(
        color: _getBackgroundColor(theme),
        padding: EdgeInsets.symmetric(horizontal: 15),
        child: tabataScreen,
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
          icon: Icon(Icons.skip_previous),
          onPressed: () {
            _workout.previous();
            _onWorkoutChanged();
          },
          iconSize: 64.0,
        ),
        IconButton(
          icon: Icon(_workout.isActive ? Icons.pause : Icons.play_arrow),
          onPressed: _workout.isActive ? _pause : _start,
          iconSize: 64.0,
        ),
        IconButton(
            icon: Icon(Icons.stop),
            iconSize: 64.0,
            onPressed: () {
              _workout.finished();
            }),
        IconButton(
          icon: Icon(Icons.skip_next),
          onPressed: () {
            _workout.next();
            _onWorkoutChanged();
          },
          iconSize: 64.0,
        ),
      ],
    );
  }
}
