import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:forcegauge/models/devices/device.dart';
import 'package:forcegauge/models/settings.dart';
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
      loadTabata();
    });
  }

  loadTabata() {
    //if (this._prefs == null) return;
    var tabataString =
        _prefs.getString('tabata') ?? jsonEncode(defaultTabata.toJson());
    var tabataJson = jsonDecode(tabataString);
    var tabata = Tabata.fromJson(tabataJson);
    emit(SettingsStateTabataLoaded(tabata));
  }

  saveTabata(Tabata tabata) {
    //if (this._prefs == null) return;
    String json = jsonEncode(tabata).toString();
    _prefs.setString('tabata', json);
    emit(SettingsStateTabataLoaded(tabata));
  }

  loadDevices() {
    if (this._prefs == null) return;
    var devicesString = _prefs.getString('devices') ?? '[]';
    var devicesJson = jsonDecode(devicesString) as List;
    emit(SettingsStateDevicesLoaded(devicesJson));
  }

  saveDevices(List<Device> deviceList) {
    if (this._prefs == null) return;
    String json =
        jsonEncode(deviceList.map((i) => i.toJson()).toList()).toString();
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
    Map<String, dynamic> json =
        jsonDecode(_prefs.getString('settings') ?? '{}');
    settings.fromJson(json);
    emit(SettingsStateSettingsChanged(settings));
  }
}
