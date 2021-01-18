import 'package:forcegauge/models/devices/device.dart';

class DeviceData {
  final double time;
  final double raw;
  final double value;
  DeviceData(this.time, this.raw, this.value);

  factory DeviceData.parseJSON(data) {
    var time = double.parse(data['time']);
    var raw = double.parse(data['raw']);
    var value = double.parse(data['value']);
    return new DeviceData(time, raw, value);
  }
  @override
  String toString() {
    return "{'time': ${time}, 'raw':${raw}, 'value':${value}}";
  }
}
