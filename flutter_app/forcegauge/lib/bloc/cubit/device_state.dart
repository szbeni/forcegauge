part of 'device_cubit.dart';

abstract class DeviceState {
  final Device device;
  const DeviceState(this.device);

  //@override
  //List<Object> get props => [device];
}

class DeviceStateInit extends DeviceState {
  DeviceStateInit(Device device) : super(device);
}

class DeviceStateNewMessage extends DeviceState {
  DeviceStateNewMessage(Device device) : super(device);
}

class DeviceStateNewStatus extends DeviceState {
  final status;
  DeviceStateNewStatus(Device device, this.status) : super(device);
}
