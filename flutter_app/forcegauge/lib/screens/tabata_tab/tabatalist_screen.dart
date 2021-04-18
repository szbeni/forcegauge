import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forcegauge/bloc/cubit/settings_cubit.dart';
import 'package:forcegauge/bloc/cubit/tabatamanager_cubit.dart';
import 'package:forcegauge/models/tabata/tabata.dart';
import 'package:forcegauge/screens/tabata_tab/tabata_screen.dart';
import 'package:forcegauge/screens/tabata_tab/workout_screen.dart';
import 'package:forcegauge/widgets/decimalpicker.dart';

class TabataListScreen extends StatefulWidget {
  @required
  final bool targetView;

  const TabataListScreen(this.targetView);
  @override
  createState() => new TabataListScreenState();
}

class TabataListScreenState extends State<TabataListScreen> {
  String newTabataName = "MyNewWorkout";
  addNewTabataDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return new AlertDialog(
            title: new Text('New Tabata'),
            content: TextField(
              controller: TextEditingController(text: newTabataName),

              onChanged: (value) {
                setState(() {
                  newTabataName = value;
                });
              },
              //controller: _textFieldController,
              decoration: InputDecoration(hintText: "MyNewWorkout"),
            ),
            actions: <Widget>[
              new TextButton(
                  child: new Text('Cancel'),
                  // The alert is actually part of the navigation stack, so to close it, we
                  // need to pop it.
                  onPressed: () => Navigator.of(context).pop()),
              new TextButton(
                  child: new Text('Add'),
                  onPressed: () {
                    bool success = BlocProvider.of<TabatamanagerCubit>(context).addTabata(newTabataName);
                    if (success) {
                      Navigator.of(context).pop();
                    }
                  })
            ],
          );
        });
  }

  // Build the whole screen
  @override
  Widget build(BuildContext context) {
    var targetForceListView = ListTile(
      title: Text('Target Force'),
      subtitle: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          return Text(BlocProvider.of<SettingsCubit>(context).settings.targetForce.toString());
        },
      ),
      leading: Icon(Icons.fitness_center),
      onTap: () {
        showDialog<double>(
          context: context,
          builder: (BuildContext context) {
            return DecimalPickerDialog(
              min: 0.0,
              max: 500.0,
              initialValue: BlocProvider.of<SettingsCubit>(context).settings.targetForce,
              decimals: 1,
              acceleration: 0.1,
              step: 0.1,
              title: Text('Sets in the workout'),
            );
          },
        ).then((force) {
          if (force == null) return;
          BlocProvider.of<SettingsCubit>(context).settings.targetForce = force;
          BlocProvider.of<SettingsCubit>(context).saveSettings();
        });
      },
    );

    return new Scaffold(
      body: Column(children: [
        widget.targetView == true ? targetForceListView : Container(),
        Expanded(child: TabataList(widget.targetView)),
      ]),
      floatingActionButton: new FloatingActionButton(
        onPressed: () => addNewTabataDialog(context),
        tooltip: 'Add Tabata',
        child: new Icon(Icons.add),
      ),
    );
  }
}

class TabataList extends StatelessWidget {
  final bool targetView;

  const TabataList(this.targetView);
  @override
  Widget build(BuildContext context) {
    final itemNameStyle = Theme.of(context).textTheme.headline6;

    return BlocBuilder<TabatamanagerCubit, TabatamanagerState>(
      builder: (context, state) {
        if (state is TabatamanagerInitial && state.tabatas.length > 0) {
          //return const CircularProgressIndicator();
          return const Text('List is empty, add new tabata');
        } else {
          return ListView.builder(
              itemCount: state.tabatas.length,
              itemBuilder: (context, index) {
                return TabataListTile(state.tabatas[index], targetView);
              });
        }
      },
    );
  }
}

class TabataListTile extends StatelessWidget {
  final bool targetView;
  Tabata _tabata;
  TabataListTile(this._tabata, this.targetView);
  Future<bool> _removedDeviceDialog(BuildContext context) async {
    return await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(title: new Text('Remove Tabata: "${_tabata.name}".'), actions: <Widget>[
            new TextButton(
                child: new Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop(false);
                }),
            new TextButton(
                child: new Text('Remove'),
                onPressed: () {
                  BlocProvider.of<TabatamanagerCubit>(context).removeTabata(_tabata.name);
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

      // Display item's title, price...
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        child: ListTile(
          title: new Text(_tabata.name, style: TextStyle(fontWeight: FontWeight.bold)),
          subtitle: new Text(
              "Sets:${_tabata.sets} Reps:${_tabata.sets} Exercise:${_tabata.exerciseTime.inSeconds} Rest:${_tabata.restTime.inSeconds} Break:${_tabata.breakTime.inSeconds}"),
          onLongPress: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TabataScreen(tabata: _tabata),
              ),
            );
          },
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => WorkoutScreen(
                    tabata: _tabata,
                    targetForce: targetView == false ? 0 : BlocProvider.of<SettingsCubit>(context).settings.targetForce),
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

    // return ListTile(
    //   title: Tooltip(
    //     message: _tabata.name,
    //     child: Row(
    //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //       children: [
    //         new Text(_tabata.name, style: TextStyle(fontWeight: FontWeight.bold)),
    //         new Icon(Icons.remove_circle_outline),
    //       ],
    //     ),
    //   ),
    //   subtitle: new Text(
    //       "Sets: ${_tabata.sets}, Reps:  ${_tabata.sets}, Exercise: ${_tabata.exerciseTime.inSeconds}  Rest: ${_tabata.restTime.inSeconds}, Break: ${_tabata.breakTime.inSeconds},"),
    //   onTap: () {
    //     //_removedDeviceDialog(context);
    //     Navigator.push(
    //       context,
    //       MaterialPageRoute(
    //         builder: (context) => TabataScreen(tabata: _tabata, targetForceEnabled: false),
    //       ),
    //     );
    //   },
    // );
  }
}
