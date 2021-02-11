import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forcegauge/bloc/cubit/device_cubit.dart';
import 'package:mp_chart/mp/chart/line_chart.dart';
import 'package:mp_chart/mp/controller/line_chart_controller.dart';
import 'package:mp_chart/mp/core/common_interfaces.dart';
import 'package:mp_chart/mp/core/data/line_data.dart';
import 'package:mp_chart/mp/core/data_interfaces/i_line_data_set.dart';
import 'package:mp_chart/mp/core/data_set/line_data_set.dart';
import 'package:mp_chart/mp/core/description.dart';
import 'package:mp_chart/mp/core/entry/entry.dart';
import 'package:mp_chart/mp/core/enums/axis_dependency.dart';
import 'package:mp_chart/mp/core/enums/legend_form.dart';
import 'package:mp_chart/mp/core/highlight/highlight.dart';
import 'package:mp_chart/mp/core/utils/color_utils.dart';

PopupMenuItem item(String text, String id) {
  return PopupMenuItem<String>(
      value: id,
      child: Container(
          padding: EdgeInsets.only(top: 15.0),
          child: Center(
              child: Text(
            text,
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.center,
            style: TextStyle(
                color: ColorUtils.BLACK,
                fontSize: 18,
                fontWeight: FontWeight.bold),
          ))));
}

class EvenMoreRealtime extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return EvenMoreRealtimeState();
  }
}

class EvenMoreRealtimeState extends State<EvenMoreRealtime>
    implements OnChartValueSelectedListener {
  LineChartController controller;
  var random = Random(1);
  var isMultipleRun = false;

  @override
  void initState() {
    _initController();
    Timer.periodic(Duration(milliseconds: 50), (timer) {
      controller.state?.setStateIfNotDispose();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            actions: <Widget>[
              PopupMenuButton<String>(
                itemBuilder: getBuilder(),
                onSelected: (String action) {
                  itemClick(action);
                },
              ),
            ],
            // Here we take the value from the MyHomePage object that was created by
            // the App.build method, and use it to set our appbar title.
            // title: Text(getTitle())),
            title: BlocListener<DeviceCubit, DeviceState>(
                listener: (context, state) {
                  if (state is DeviceStateNewStatus) {
                    print("New status: ${state.status}");
                    if (state.status == "Connected") {
                      print("Clearchart");
                      _clearChart();
                    }
                  } else if (state is DeviceStateNewMessage) {
                    print(state.device.lastData);
                    _addData(state.device.lastData.time,
                        state.device.lastData.value);
                  }
                },
                child: Text("Test"))),
        //title:  ,
        body: getBody());
  }

  Widget getBody() {
    return Container(child: LineChart(controller));

    return Stack(
      children: <Widget>[
        Positioned(
          right: 0,
          left: 0,
          top: 0,
          bottom: 0,
          child: LineChart(controller),
        )
      ],
    );
  }

  // @override
  getBuilder() {
    return (BuildContext context) => <PopupMenuItem<String>>[
          item('View on GitHub', 'A'),
          item('Add Entry', 'B'),
          item('Clear Chart', 'C'),
          item('Add Multiple', 'D'),
          item('Save to Gallery', 'E'),
          item('Update Random Single Entry', 'F'),
        ];
  }

  String getTitle() {
    return "Even More Realtime";
  }

  void itemClick(String action) {
    if (controller.state == null) {
      return;
    }

    switch (action) {
      case 'A':
        //Util.openGithub();
        break;
      case 'B':
        _addEntry();
        controller.state.setStateIfNotDispose();
        break;
      case 'C':
        _clearChart();
        controller.state.setStateIfNotDispose();
        break;
      case 'D':
        _addMultiple();
        controller.state.setStateIfNotDispose();
        break;
      case 'E':
        // captureImg(() {
        //   controller.state.capture();
        // });
        break;
      case 'F':
        _updateEntry();
        break;
    }
  }

  void _initController() {
    var desc = Description()..enabled = false;
    controller = LineChartController(
        legendSettingFunction: (legend, controller) {
          legend
            ..shape = LegendForm.LINE
            //..typeface = Util.LIGHT
            ..textColor = ColorUtils.WHITE;
        },
        xAxisSettingFunction: (xAxis, controller) {
          xAxis
            //..typeface = Util.LIGHT
            ..textColor = ColorUtils.WHITE
            ..drawGridLines = true
            ..avoidFirstLastClipping = true
            ..enabled = true;
        },
        axisLeftSettingFunction: (axisLeft, controller) {
          axisLeft
            //..typeface = Util.LIGHT
            ..textColor = ColorUtils.WHITE
            ..axisMaximum = 100.0
            ..axisMinimum = 0.0
            ..drawGridLines = true;
        },
        axisRightSettingFunction: (axisRight, controller) {
          axisRight.enabled = false;
        },
        drawGridBackground: false,
        dragXEnabled: true,
        dragYEnabled: true,
        scaleXEnabled: true,
        scaleYEnabled: true,
        backgroundColor: ColorUtils.LTGRAY,
        selectionListener: this,
        pinchZoomEnabled: true,
        description: desc);

    LineData data = controller?.data;

    if (data == null) {
      data = LineData();
      controller.data = data;
    }
  }

  @override
  void onNothingSelected() {}

  @override
  void onValueSelected(Entry e, Highlight h) {}

  void _addData(double newX, double newY) {
    LineData data = controller.data;

    if (data != null) {
      ILineDataSet set = data.getDataSetByIndex(0);
      // set.addEntry(...); // can be called as well

      if (set == null) {
        set = _createSet();
        data.addDataSet(set);
      }

      data.addEntry(Entry(x: newX, y: newY), 0);
      if (data.dataSets[0].getEntryCount() > 300) {
        data.dataSets[0].removeFirst();
      }
      data.notifyDataChanged();

      // limit the number of visible entries
      //controller.setVisibleXRangeMaximum(1000);
      // chart.setVisibleYRange(30, AxisDependency.LEFT);

      // move to the latest entry
      //controller.moveViewToX(data.getEntryCount().toDouble());

      //controller.state?.setStateIfNotDispose();
    }
  }

  void _addEntry() {
    // LineData data = controller.data;

    // if (data != null) {
    //   ILineDataSet set = data.getDataSetByIndex(0);
    //   // set.addEntry(...); // can be called as well

    //   if (set == null) {
    //     set = _createSet();
    //     data.addDataSet(set);
    //   }

    //   data.addEntry(
    //       Entry(
    //           x: set.getEntryCount().toDouble(),
    //           y: (random.nextDouble() * 40) + 30.0),
    //       0);
    //   data.notifyDataChanged();

    //   // limit the number of visible entries
    //   controller.setVisibleXRangeMaximum(1000);
    //   // chart.setVisibleYRange(30, AxisDependency.LEFT);

    //   // move to the latest entry
    //   controller.moveViewToX(data.getEntryCount().toDouble());

    //   controller.state?.setStateIfNotDispose();
    // }
  }

  void _updateEntry() {
    LineData data = controller.data;

    if (data != null) {
      ILineDataSet set = data.getDataSetByIndex(0);
      // set.addEntry(...); // can be called as well

      if (set == null) {
        set = _createSet();
        data.addDataSet(set);
      }

      if (set.getEntryCount() == 0) {
        return;
      }

      //for test ChartData's updateEntryByIndex
      var index = (random.nextDouble() * set.getEntryCount()).toInt();
      var x = set.getEntryForIndex(index).x;
      data.updateEntryByIndex(
          index, Entry(x: x, y: (random.nextDouble() * 40) + 30.0), 0);

      data.notifyDataChanged();

      // limit the number of visible entries
      controller.setVisibleXRangeMaximum(120);
      // chart.setVisibleYRange(30, AxisDependency.LEFT);

      // move to the latest entry
      controller.moveViewToX(data.getEntryCount().toDouble());

      controller.state?.setStateIfNotDispose();
    }
  }

  void _clearChart() {
    controller.data?.clearValues();
    controller.state?.setStateIfNotDispose();
  }

  void _addMultiple() {
    if (isMultipleRun) {
      return;
    }

    isMultipleRun = true;
    var i = 0;
    Timer.periodic(Duration(milliseconds: 25), (timer) {
      _addEntry();
      if (i++ > 1000) {
        timer.cancel();
        isMultipleRun = false;
      }
    });
  }

  LineDataSet _createSet() {
    LineDataSet set = LineDataSet(null, "Dynamic Data");
    set.setAxisDependency(AxisDependency.LEFT);
    set.setColor1(ColorUtils.getHoloBlue());
    set.setDrawCircles(false);
    set.setCircleColor(ColorUtils.WHITE);
    set.setLineWidth(3.0);
    set.setCircleRadius(4.0);
    set.setFillAlpha(65);
    set.setFillColor(ColorUtils.getHoloBlue());
    set.setHighLightColor(Color.fromARGB(255, 244, 117, 117));
    set.setValueTextColor(ColorUtils.WHITE);
    set.setValueTextSize(9.0);
    set.setDrawValues(false);
    return set;
  }
}
