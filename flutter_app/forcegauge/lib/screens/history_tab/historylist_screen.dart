import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forcegauge/bloc/cubit/reportmanager_cubit.dart';
import 'package:forcegauge/bloc/cubit/settings_cubit.dart';
import 'package:forcegauge/models/tabata/report.dart';
import 'package:forcegauge/screens/history_tab/report_screen.dart';
import 'package:forcegauge/widgets/decimalpicker.dart';
import 'package:intl/intl.dart';

class HistoryListScreen extends StatefulWidget {
  const HistoryListScreen();
  @override
  createState() => new HistoryListScreenState();
}

class HistoryListScreenState extends State<HistoryListScreen> {
  // Build the whole screen
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: Column(children: [
        Expanded(child: HistoryList()),
      ]),
      // floatingActionButton: new FloatingActionButton(
      //   onPressed: () => addNewHistoryDialog(context),
      //   tooltip: 'Add History',
      //   child: new Icon(Icons.add),
      // ),
    );
  }
}

class HistoryList extends StatelessWidget {
  const HistoryList();
  @override
  Widget build(BuildContext context) {
    final itemNameStyle = Theme.of(context).textTheme.headline6;
    return BlocBuilder<ReportmanagerCubit, ReportmanagerState>(
      builder: (context, state) {
        if (state is ReportmanagerInitial || state.reports.length == 0) {
          return Container(child: Text("List is empty, do some workout you lazy!"));
        } else {
          return ListView.builder(
              itemCount: state.reports.length,
              itemBuilder: (context, index) {
                return HistoryListTile(state.reports[index], index);
              });
        }
      },
    );
  }
}

class HistoryListTile extends StatelessWidget {
  WorkoutReport _report;
  int _index;
  HistoryListTile(this._report, this._index);
  Future<bool> _removedDeviceDialog(BuildContext context) async {
    return await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(title: new Text('Remove History: "${_report.name}".'), actions: <Widget>[
            new TextButton(
                child: new Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop(false);
                }),
            new TextButton(
                child: new Text('Remove'),
                onPressed: () {
                  BlocProvider.of<ReportmanagerCubit>(context).removeWorkoutReportAt(_index);
                  Navigator.of(context).pop(true);
                })
          ]);
        });
  }

  // Build a single Device Item
  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: UniqueKey(),

      // only allows the user swipe from right to left
      //direction: [DismissDirection.endToStart, DismissDirection.startToEnd],

      // Remove this product from the list
      // In production enviroment, you may want to send some request to delete it on server side
      onDismissed: (_) {},
      confirmDismiss: (DismissDirection dismissDirection) async {
        return _removedDeviceDialog(context);
      },

      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        child: ListTile(
          title:
              new Text(DateFormat("yyyy-MM-dd - HH:mm").format(_report.date), style: TextStyle(fontWeight: FontWeight.bold)),
          subtitle: new Text("Workout type:${_report.name}"),
          onLongPress: () {},
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ReportScreen(_report),
              ),
            );
          },
        ),
      ),

      // This will show up when the user performs dismissal action
      // It is a red background and a trash icon
      background: Container(
        color: Colors.red,
        margin: EdgeInsets.symmetric(horizontal: 15),
        alignment: Alignment.centerRight,
        child: Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
    );
  }
}
