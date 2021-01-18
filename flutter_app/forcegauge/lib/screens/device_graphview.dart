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
  charts.LineChart _lineChart;
  var myRandom = new Random(1);

  @override
  void initState() {
    super.initState();

    var data = [
      new DeviceData(0, 1, 3),
      new DeviceData(1, 1, 6),
      new DeviceData(2, 1, 7),
      new DeviceData(3, 1, 3),
    ];

    _seriesList = [
      new charts.Series<DeviceData, int>(
        id: 'Force',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (DeviceData deviceData, _) {
          return (deviceData.time).toInt();
        },
        measureFn: (DeviceData deviceData, _) {
          return deviceData.value;
        },
        data: data,
      )
    ];

    _lineChart = new charts.LineChart(_seriesList, animate: false);
    //widget.device.addListener(onNewData);
  }

  @override
  dispose() {
    widget.device.removeListener(onNewData);
    super.dispose();
  }

  double index = 4;
  addRandomData() {
    index += 1;
    double raw = myRandom.nextDouble();
    double value = myRandom.nextDouble();
    var dd = DeviceData(index, raw, value);
    _seriesList[0].data.add(dd);
  }

  onNewData(newData) {
    setState(() {
      //_seriesList[0].data.addAll(newData);
    });
  }

  @override
  Widget build(BuildContext context) {
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
                style: Theme.of(context).textTheme.body2,
              ),
              Expanded(
                child: _lineChart,
              )
            ],
          ),
        ),
      ),
    );
  }
}
