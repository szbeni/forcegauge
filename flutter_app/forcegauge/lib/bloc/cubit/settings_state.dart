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

class SettingsStateTabatasLoaded extends SettingsState {
  final List<dynamic> tabatas;
  SettingsStateTabatasLoaded(this.tabatas) : super();
}

class SettingsStateTabatasSaved extends SettingsState {
  final List<Tabata> tabatas;
  SettingsStateTabatasSaved(this.tabatas) : super();
}

class SettingsStateReportsLoaded extends SettingsState {
  final List<dynamic> reports;
  SettingsStateReportsLoaded(this.reports) : super();
}

class SettingsStateReportsSaved extends SettingsState {
  final List<WorkoutReport> reports;
  SettingsStateReportsSaved(this.reports) : super();
}
