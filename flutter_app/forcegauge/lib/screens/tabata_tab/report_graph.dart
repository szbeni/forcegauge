import 'dart:math';

import 'package:flutter/material.dart';
import 'package:forcegauge/models/tabata/tabata.dart';
import 'package:mp_chart/mp/chart/line_chart.dart';
import 'package:mp_chart/mp/controller/line_chart_controller.dart';
import 'package:mp_chart/mp/core/data/line_data.dart';
import 'package:mp_chart/mp/core/data_set/line_data_set.dart';
import 'package:mp_chart/mp/core/description.dart';
import 'package:mp_chart/mp/core/entry/entry.dart';
import 'package:mp_chart/mp/core/enums/mode.dart';
import 'package:mp_chart/mp/core/utils/color_utils.dart';

class ReportGraph extends StatefulWidget {
  final WorkoutReport report;
  const ReportGraph(this.report);
  @override
  _ReportGraphState createState() => _ReportGraphState();
}

class _ReportGraphState extends State<ReportGraph> {
  LineChartController _controller;
  var random = Random(1);

  @override
  void initState() {
    _initController();
    _initLineDataFromReport();
    //_initLineData(_range);
    super.initState();
  }

  @override
  String getTitle() => "Line Chart Performance";

  @override
  Widget build(BuildContext context) {
    return Container(height: 200, child: LineChart(_controller));
  }

  @override
  Widget getBody() {
    // return Stack(
    //   children: <Widget>[
    //     Positioned(right: 0, left: 0, top: 0, bottom: 100, child: LineChart(_controller)),
    //     Positioned(
    //       left: 0,
    //       right: 0,
    //       bottom: 0,
    //       child: Column(
    //         mainAxisSize: MainAxisSize.max,
    //         crossAxisAlignment: CrossAxisAlignment.start,
    //         children: <Widget>[
    //           Row(
    //             mainAxisSize: MainAxisSize.max,
    //             crossAxisAlignment: CrossAxisAlignment.start,
    //             children: <Widget>[
    //               Expanded(
    //                 child: Center(
    //                     child: Slider(
    //                         value: _range,
    //                         min: 0,
    //                         max: 9000,
    //                         onChanged: (value) {
    //                           _range = value;
    //                           _initLineData(_range);
    //                         })),
    //               ),
    //               Container(
    //                   constraints: BoxConstraints.expand(height: 50, width: 60),
    //                   padding: EdgeInsets.only(right: 15.0),
    //                   child: Center(
    //                       child: Text(
    //                     "$_count",
    //                     textDirection: TextDirection.ltr,
    //                     textAlign: TextAlign.center,
    //                     style: TextStyle(color: ColorUtils.BLACK, fontSize: 12, fontWeight: FontWeight.bold),
    //                   ))),
    //             ],
    //           ),
    //         ],
    //       ),
    //     )
    //   ],
    // );
  }

  void _initController() {
    var desc = Description()..enabled = false;
    _controller = LineChartController(
        axisLeftSettingFunction: (axisLeft, controller) {
          axisLeft.drawGridLines = (false);
        },
        axisRightSettingFunction: (axisRight, controller) {
          axisRight.enabled = (false);
        },
        legendSettingFunction: (legend, controller) {
          legend.enabled = (false);
        },
        xAxisSettingFunction: (xAxis, controller) {
          xAxis
            ..drawGridLines = (true)
            ..drawAxisLine = (false);
        },
        drawGridBackground: true,
        dragXEnabled: true,
        dragYEnabled: true,
        scaleXEnabled: false,
        scaleYEnabled: false,
        pinchZoomEnabled: false,
        description: desc);
  }

  void _initLineDataFromReport() {
    List<Entry> values = List();
    double counter = 0;
    //for (var report in widget.reports.keys) {
    for (var value in widget.report.getValues()) {
      values.add(new Entry(x: counter, y: value));
      counter += 1;
    }
    //}

    // create a dataset and give it a type
    LineDataSet set1 = new LineDataSet(values, "DataSet 1");

    set1.setColor1(ColorUtils.BLUE);
    set1.setLineWidth(2);
    set1.setDrawValues(false);
    set1.setDrawCircles(false);
    set1.setMode(Mode.LINEAR);
    set1.setDrawFilled(false);

    // create a data object with the data sets
    _controller.data = LineData.fromList(List()..add(set1));
    setState(() {});
  }

  // void _initLineData(double range) {
  //   List<Entry> values = List();

  //   _count = (range + 1000).toInt();

  //   for (int i = 0; i < _count; i++) {
  //     double val = (random.nextDouble() * (range + 1)) + 3;
  //     values.add(new Entry(x: i * 0.001, y: val));
  //   }

  //   // create a dataset and give it a type
  //   LineDataSet set1 = new LineDataSet(values, "DataSet 1");

  //   set1.setColor1(ColorUtils.BLUE);
  //   set1.setLineWidth(2);
  //   set1.setDrawValues(false);
  //   set1.setDrawCircles(false);
  //   set1.setMode(Mode.LINEAR);
  //   set1.setDrawFilled(false);

  //   // create a data object with the data sets
  //   _controller.data = LineData.fromList(List()..add(set1));

  //   setState(() {});
  // }
}
