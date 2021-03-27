import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:forcegauge/models/devices/device.dart';

part 'device_state.dart';

class DeviceCubit extends Cubit<DeviceState> {
  DeviceCubit(device) : super(DeviceStateInit(device)) {
    //Add subscription
    device.addListener(onDeviceEvent);
  }

  onDeviceEvent(DeviceNotificationType type, dynamic data) {
    if (type == DeviceNotificationType.newMessage) {
      emit(DeviceStateNewMessage(state.device));
    } else if (type == DeviceNotificationType.newStatus) {
      emit(DeviceStateNewStatus(state.device, data));
    }
  }

  @override
  Future<void> close() {
    //remove subscription
    state.device.removeListener(onDeviceEvent);
    return super.close();
  }
}
