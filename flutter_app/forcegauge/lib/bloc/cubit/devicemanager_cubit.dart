import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:forcegauge/models/devices/device.dart';
import 'package:forcegauge/models/tabata/tabata.dart';

part 'devicemanager_state.dart';

class DevicemanagerCubit extends Cubit<DevicemanagerState> {
  DevicemanagerCubit() : super(DevicemanagerInitial([])) {}

  void loadDevicesFromJson(List<dynamic> devicesJson) {
    List<Device> deviceList = [];
    for (var devJson in devicesJson) {
      var newDevice = new Device.fromJson(devJson);
      deviceList.add(newDevice);
    }
    emit(DevicemanagerLoaded(deviceList));
  }

  void addDevice(String name, String url) {
    if (state.getDeviceByName(name) == null) {
      var newDevice = new Device(name, url);
      state.devices.add(newDevice);
      emit(DevicemanagerUpdated(state.devices));
    }
  }

  void removeDevice(String name) {
    Device dev = state.getDeviceByName(name);
    if (dev != null) {
      dev.close();
      state.devices.remove(dev);

      emit(DevicemanagerUpdated(state.devices));
    }
  }

  void removeDeviceAt(int index) {
    if (index >= 0 && index < state.devices.length) {
      state.devices[index].close();
      state.devices.removeAt(index);
      emit(DevicemanagerSaved(state.devices));
    }
  }

  // loadSettings() {
  //   var devicesString = _prefs.getString('devices') ?? '[]';
  //   var devicesJson = jsonDecode(devicesString) as List;
  //   for (var devJson in devicesJson) {
  //     var newDevice = new Device.fromJson(devJson);
  //     _devices.add(newDevice);
  //   }
  //   _notifyListeners(_devices.length);
  // }

  // saveSettings() {
  //   String json =
  //       jsonEncode(_devices.map((i) => i.toJson()).toList()).toString();
  //   _prefs.setString('devices', json);
  // }

}
