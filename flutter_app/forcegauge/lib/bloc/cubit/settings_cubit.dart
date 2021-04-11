import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:forcegauge/models/devices/device.dart';
import 'package:forcegauge/models/settings.dart';
import 'package:forcegauge/models/tabata/report.dart';
import 'package:forcegauge/models/tabata/tabata.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SharedPreferences _prefs;
  final Settings settings = new Settings();

  SettingsCubit() : super(SettingsStateLoading()) {
    SharedPreferences.getInstance().then((prefs) {
      this._prefs = prefs;
      loadSettings();
      loadDevices();
      loadTabatas();
      loadReports();
    });
  }

  loadReports() {
    var reportsString = _prefs.getString('reports') ?? '[{"name":"Malc","date":1000000}]';
    var reportsJson = jsonDecode(reportsString) as List;
    emit(SettingsStateReportsLoaded(reportsJson));
  }

  saveReports(List<WorkoutReport> reportList) {
    if (this._prefs == null) return;
    String json = jsonEncode(reportList.map((i) => i.toJson()).toList()).toString();
    _prefs.setString('reports', json);
    emit(SettingsStateReportsSaved(reportList));
  }

  loadTabatas() {
    var tabatasString = _prefs.getString('tabatas') ?? '[]';
    var tabatasJson = jsonDecode(tabatasString) as List;
    emit(SettingsStateTabatasLoaded(tabatasJson));
  }

  saveTabatas(List<Tabata> tabataList) {
    if (this._prefs == null) return;
    String json = jsonEncode(tabataList.map((i) => i.toJson()).toList()).toString();
    _prefs.setString('tabatas', json);
    emit(SettingsStateTabatasSaved(tabataList));
  }

  loadDevices() {
    if (this._prefs == null) return;
    var devicesString = _prefs.getString('devices') ?? '[]';
    var devicesJson = jsonDecode(devicesString) as List;
    emit(SettingsStateDevicesLoaded(devicesJson));
  }

  saveDevices(List<Device> deviceList) {
    if (this._prefs == null) return;
    String json = jsonEncode(deviceList.map((i) => i.toJson()).toList()).toString();
    _prefs.setString('devices', json);
    emit(SettingsStateDevicesSaved(deviceList));
  }

  saveSettings() {
    if (this._prefs == null) return;
    _prefs.setString('settings', jsonEncode(settings));
    emit(SettingsStateSettingsChanged(settings));
  }

  loadSettings() {
    if (this._prefs == null) return;
    Map<String, dynamic> json = jsonDecode(_prefs.getString('settings') ?? '{}');
    settings.fromJson(json);
    emit(SettingsStateSettingsChanged(settings));
  }
}
