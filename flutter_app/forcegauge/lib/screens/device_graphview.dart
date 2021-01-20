import 'dart:math';

/// Example of a time series chart with range annotations configured to render
/// labels in the chart margin area.
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:forcegauge/models/devices/device.dart';
import 'package:forcegauge/models/devices/device_data.dart';
import 'package:forcegauge/models/settings.dart';

class DeviceGraphView extends StatefulWidget {
  final Device device;

  DeviceGraphView(this.device);
  @override
  _DeviceGraphViewState createState() => _DeviceGraphViewState();
}

class _DeviceGraphViewState extends State<DeviceGraphView> {
  List<DeviceData> data;
  var myRandom = new Random(1);

  @override
  void initState() {
    data = [];
    super.initState();
    widget.device.addListener(onNewData);
    settings.addListener(onSettingsChanged);
  }

  @override
  dispose() {
    widget.device.removeListener(onNewData);
    settings.removeListener(onSettingsChanged);
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

  onSettingsChanged() {
    setState(() {});
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
        id: "${widget.device.name}",
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

    var minStr = widget.device.minValue.toStringAsFixed(1);
    var maxStr = widget.device.maxValue.toStringAsFixed(1);
    var lastStr = widget.device.lastValue.toStringAsFixed(1);

    var clearButton = MaterialButton(
      onPressed: () {
        setState(() {
          widget.device.clearMaxMin();
        });
      },
      color: Colors.blue,
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
          widget.device.resetOffset();
        });
      },
      color: Colors.blue,
      textColor: Colors.white,
      child: Icon(
        Icons.vertical_align_center,
        size: 24,
      ),
      padding: EdgeInsets.all(16),
      shape: CircleBorder(),
    );

    var statusIcon = Icon(Icons.radio_button_checked, color: Colors.red);
    if (widget.device.isConnected())
      statusIcon = Icon(Icons.radio_button_checked, color: Colors.green);

    var textStyleForce = new TextStyle(
        color: Colors.grey[800],
        fontWeight: FontWeight.bold,
        fontStyle: FontStyle.normal,
        fontFamily: 'Open Sans',
        fontSize: settings.fontSize);

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

    return SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Container(
            decoration: BoxDecoration(
              border: Border.all(width: 2.0),
              borderRadius: BorderRadius.all(Radius.circular(2.0)),
            ),
            child: Column(
              children: [
                Container(
                  child: Row(children: [
                    Text(
                      "${widget.device.name}",
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
                Container(
                  height: 400,
                  padding: EdgeInsets.all(20),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [],
                          ),
                          // RaisedButton(
                          //     child: Text('Random Data'), onPressed: addRandomData),
                          Expanded(
                            //child: Container(),
                            child: chartWidget,
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            )));
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
