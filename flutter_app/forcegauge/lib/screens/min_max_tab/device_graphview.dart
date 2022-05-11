import 'dart:math';

/// Example of a time series chart with range annotations configured to render
/// labels in the chart margin area.
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forcegauge/bloc/cubit/device_cubit.dart';
import 'package:forcegauge/bloc/cubit/settings_cubit.dart';
import 'package:forcegauge/screens/min_max_tab/realtime_chart.dart';

class DeviceGraphView extends StatefulWidget {
  DeviceGraphView();
  @override
  _DeviceGraphViewState createState() => _DeviceGraphViewState();
}

class _DeviceGraphViewState extends State<DeviceGraphView> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Container(
            decoration: BoxDecoration(
              border: Border.all(width: 2.0),
              borderRadius: BorderRadius.all(Radius.circular(2.0)),
            ),
            child: Column(
              children: [
                BlocBuilder<DeviceCubit, DeviceState>(builder: (context, state) {
                  var minStr = state.device.minValue.toStringAsFixed(1);
                  var maxStr = state.device.maxValue.toStringAsFixed(1);
                  var lastStr = state.device.lastValue.toStringAsFixed(1);

                  var clearButton = MaterialButton(
                    onPressed: () {
                      state.device.clearMaxMin();
                      state.device.clearHistoricalData();
                    },
                    color: BlocProvider.of<SettingsCubit>(context).settings.primarySwatch,
                    textColor: Colors.white,
                    child: Icon(
                      Icons.delete,
                      size: 24,
                    ),
                    padding: EdgeInsets.all(16),
                    shape: CircleBorder(),
                  );

                  var zeroOffsetButton = MaterialButton(
                    onPressed: () {
                      setState(() {
                        state.device.resetOffset();
                      });
                    },
                    color: BlocProvider.of<SettingsCubit>(context).settings.primarySwatch,
                    textColor: Colors.white,
                    child: Icon(
                      Icons.vertical_align_center,
                      size: 24,
                    ),
                    padding: EdgeInsets.all(16),
                    shape: CircleBorder(),
                  );

                  var statusIcon = Icon(Icons.radio_button_checked, color: Colors.red);
                  if (state.device.isConnected()) statusIcon = Icon(Icons.radio_button_checked, color: Colors.green);

                  var textStyleForce = new TextStyle(
                      color: Colors.grey[800],
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.normal,
                      fontFamily: 'Open Sans',
                      fontSize: BlocProvider.of<SettingsCubit>(context).settings.fontSize);

                  var textStyleLarge = new TextStyle(
                      color: Colors.grey[800],
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.normal,
                      fontFamily: 'Open Sans',
                      fontSize: 40);

                  var textStyleSmall = new TextStyle(
                      color: Colors.grey[500],
                      fontWeight: FontWeight.w900,
                      fontStyle: FontStyle.italic,
                      fontFamily: 'Open Sans',
                      fontSize: 20);

                  return Column(
                    children: [
                      Container(
                        child: Row(children: [
                          Text(
                            "${state.device.name}",
                            style: textStyleSmall,
                          ),
                          statusIcon
                        ]),
                        alignment: Alignment.topLeft,
                      ),
                      Container(child: Text("$lastStr", style: textStyleForce)),
                      Container(
                          //width: 250,
                          child: Text("Min: $minStr", style: textStyleLarge)),
                      Container(
                          //width: 250,
                          child: Text("Max: $maxStr", style: textStyleLarge)),
                      Row(
                        //mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          clearButton,
                          zeroOffsetButton,
                        ],
                      ),
                    ],
                  );
                }),
                //EvenMoreRealtime(),
                Container(
                  height: 280,
                  //padding: EdgeInsets.all(0),
                  child: Card(
                    //child: Container(),
                    child: EvenMoreRealtime(false, 0.0),
                  ),
                ),
              ],
            )));
  }
}
