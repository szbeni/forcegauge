// import 'package:flutter/material.dart';

// class EvenMoreRealtime extends StatefulWidget {
//   @override
//   _EvenMoreRealtimeState createState() => _EvenMoreRealtimeState();
// }

// class _EvenMoreRealtimeState extends State<EvenMoreRealtime> {
//   @override
//   Widget build(BuildContext context) {
//     return Container();
//   }
// }

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

class EvenMoreRealtime extends StatefulWidget {
  @required
  final bool showOnlyAbsolute;
  final double targetForce;
  const EvenMoreRealtime(this.showOnlyAbsolute, this.targetForce);

  @override
  State<StatefulWidget> createState() {
    return EvenMoreRealtimeState();
  }
}

class EvenMoreRealtimeState extends State<EvenMoreRealtime> implements OnChartValueSelectedListener {
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
    return BlocListener<DeviceCubit, DeviceState>(
        listener: (context, state) {
          if (state is DeviceStateNewStatus) {
            print("New status: ${state.status}");
            if (state.status == "Connected") {
              print("Clearchart");
              _clearChart();
            }
          } else if (state is DeviceStateNewMessage) {
            _addData(state.device.lastData.time, state.device.lastData.value, state.device.minValue, state.device.maxValue);
          }
        },
        child: getBody());
  }

  Widget getBody() {
    return Container(child: LineChart(controller));
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
            ..textColor = ColorUtils.GRAY
            ..drawGridLines = true;
        },
        axisRightSettingFunction: (axisRight, controller) {
          axisRight.enabled = false;
        },
        drawGridBackground: false,
        dragXEnabled: false,
        dragYEnabled: false,
        scaleXEnabled: false,
        scaleYEnabled: false,
        backgroundColor: ColorUtils.WHITE,
        selectionListener: this,
        pinchZoomEnabled: false,
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

  void _addData(double newX, double newY, double yMin, double yMax) {
    LineData data = controller.data;

    if (data != null) {
      ILineDataSet set = data.getDataSetByIndex(0);
      // set.addEntry(...); // can be called as well

      if (set == null) {
        set = _createSet();
        data.addDataSet(set);
      }
      if (widget.showOnlyAbsolute) newY = newY.abs();

      data.addEntry(Entry(x: newX, y: newY), 0);
      if (data.dataSets[0].getEntryCount() > 800) {
        data.dataSets[0].removeFirst();
      }

      if (widget.showOnlyAbsolute) {
        yMin = 0;
        yMax = widget.targetForce * 1.2;
        if (data.yMax > yMax) yMax = data.yMax;
      }

      if (yMin > 0) yMin = 0;
      if (yMax < 0) yMax = 0;

      if (yMax < 5) yMax = 5;
      if (yMin > -5) yMin = -5;
      controller.axisLeft.setAxisMinimum(yMin);
      controller.axisLeft.setAxisMaximum(yMax);
      data.notifyDataChanged();
      //controller.moveViewToY(0, AxisDependency.LEFT);
      //controller.axisLeft.setStartAtZero(false);

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
      data.updateEntryByIndex(index, Entry(x: x, y: (random.nextDouble() * 40) + 30.0), 0);

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
