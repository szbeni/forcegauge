part of 'devicemanager_cubit.dart';

abstract class DevicemanagerState extends Equatable {
  final List<Device> devices;
  DevicemanagerState(this.devices);

  @override
  List<Object> get props => [devices];

  Device getDeviceByName(String name) {
    for (var d in this.devices) {
      if (d.name == name) return d;
    }
    return null;
  }

  @override
  String toString() {
    String retval = "";
    int counter = 1;
    for (Device d in devices) {
      retval += "${counter}: ${d}\n";
    }
    return retval;
  }
}

class DevicemanagerInitial extends DevicemanagerState {
  DevicemanagerInitial(List<Device> devices) : super(devices);
}

class DevicemanagerPopulated extends DevicemanagerState {
  DevicemanagerPopulated(List<Device> devices) : super(devices);
}
