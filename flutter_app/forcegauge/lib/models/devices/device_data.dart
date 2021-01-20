import 'package:forcegauge/models/devices/device.dart';

class DeviceData {
  final double time;
  final double raw;
  final double value;
  DeviceData(this.time, this.raw, this.value);

  static double _parseDouble(data, name) {
    double retval = 0;
    if (data[name].runtimeType == int) {
      retval = int.parse(data[name]).toDouble();
    } else if (data[name].runtimeType == double) {
      retval = data[name];
    } else {
      try {
        retval = double.parse(data[name]);
      } catch (e) {
        print("Cannot parse:");
        print(data[name]);
      }
    }
    return retval;
  }

  factory DeviceData.parseJSON(data) {
    double time = _parseDouble(data, 'time');
    double raw = _parseDouble(data, 'raw');
    double value = _parseDouble(data, 'value');
    return new DeviceData(time, raw, value);
  }
  @override
  String toString() {
    return "{'time': ${time}, 'raw':${raw}, 'value':${value}}";
  }
}
