import 'dart:math';

/// Example of a time series chart with range annotations configured to render
/// labels in the chart margin area.
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:forcegauge/models/devices/device.dart';
import 'package:forcegauge/models/devices/device_data.dart';
import 'package:universal_html/prefer_sdk/html.dart';

class DeviceGraphView extends StatefulWidget {
  final Device device;

  DeviceGraphView(this.device);
  @override
  _DeviceGraphViewState createState() => _DeviceGraphViewState();
}

class _DeviceGraphViewState extends State<DeviceGraphView> {
  List<charts.Series<DeviceData, int>> _seriesList;
  var myRandom = new Random(1);
  List<DeviceData> data;

  @override
  void initState() {
    data = [];
    super.initState();
    widget.device.addListener(onNewData);
  }

  @override
  dispose() {
    widget.device.removeListener(onNewData);
    super.dispose();
  }

  double index = 4;
  addRandomData() {
    setState(() {
      index += 1;
      double raw = myRandom.nextDouble();
      double value = myRandom.nextDouble();
      var dd = DeviceData(index, raw, value);
      data.add(dd);
    });
  }

  onNewData(newData) {
    setState(() {
      data.addAll(newData);
      if (data.length > 500) {
        data.removeAt(0);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var seriesList = [
      new charts.Series<DeviceData, double>(
        id: 'Force',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (DeviceData deviceData, _) {
          return deviceData.time / 1000.0;
        },
        measureFn: (DeviceData deviceData, _) {
          return deviceData.value;
        },
        data: data,
      )
    ];

    // if (data.length > 0) {
    //   xMin = data[0].time / 1000.0;
    //   xMax = data.last.time / 1000.0;
    // }
    // print(xMin);
    // print(xMax);
    var chart = new charts.LineChart(
      seriesList,
      animate: false,
      defaultInteractions: false,
      behaviors: [
        new charts.SeriesLegend(),
        new charts.SlidingViewport(),
        new charts.PanAndZoomBehavior(),
      ],
      // domainAxis: charts.NumericAxisSpec(
      //     renderSpec: new charts.SmallTickRendererSpec(),
      //     viewport: charts.NumericExtents(xMin, xMax))
      // // behaviors: [new charts.SelectNearest(), new charts.DomainHighlighter()],
      // domainAxis:
      //     charts.NumericAxisSpec(viewport: charts.NumericExtents(xMin, xMax)),
      // primaryMeasureAxis:
      //     charts.NumericAxisSpec(viewport: charts.NumericExtents(0, xMax)),
    );

    var chartWidget = new Padding(
      padding: new EdgeInsets.all(32.0),
      child: new SizedBox(
        height: 200.0,
        child: chart,
      ),
    );

    return Container(
      height: 400,
      padding: EdgeInsets.all(20),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: <Widget>[
              RaisedButton(
                  child: Text('Random Data'), onPressed: addRandomData),
              Text(
                "Device: ${widget.device.name}",
              ),
              Expanded(
                child: chartWidget,
              )
            ],
          ),
        ),
      ),
    );
  }
}

class NumericAxisSpecWorkaround extends charts.NumericAxisSpec {
  const NumericAxisSpecWorkaround(
      {charts.RenderSpec<num> renderSpec,
      charts.NumericTickProviderSpec tickProviderSpec,
      charts.NumericTickFormatterSpec tickFormatterSpec,
      bool showAxisLine,
      viewport})
      : super(
            renderSpec: renderSpec,
            tickProviderSpec: tickProviderSpec,
            tickFormatterSpec: tickFormatterSpec,
            showAxisLine: showAxisLine,
            viewport: viewport);

  @override
  configure(charts.Axis<num> axis, charts.ChartContext context,
      charts.GraphicsFactory graphicsFactory) {
    super.configure(axis, context, graphicsFactory);
    axis.autoViewport = false;
  }
}
