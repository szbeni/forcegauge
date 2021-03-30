part of 'settings_cubit.dart';

abstract class SettingsState {
  const SettingsState();
}

class SettingsStateLoading extends SettingsState {}

class SettingsStateDevicesLoaded extends SettingsState {
  final List<dynamic> devices;
  SettingsStateDevicesLoaded(this.devices) : super();
}

class SettingsStateDevicesSaved extends SettingsState {
  final List<Device> devices;
  SettingsStateDevicesSaved(this.devices) : super();
}

class SettingsStateSettingsChanged extends SettingsState {
  final Settings settings;
  SettingsStateSettingsChanged(this.settings) : super();
}

class SettingsStateTabataLoaded extends SettingsState {
  final Tabata tabata;
  SettingsStateTabataLoaded(this.tabata) : super();
}

class SettingsStateTabataSaved extends SettingsState {
  final Tabata tabata;
  SettingsStateTabataSaved(this.tabata) : super();
}
