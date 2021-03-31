import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forcegauge/bloc/cubit/devicemanager_cubit.dart';
import 'package:forcegauge/bloc/cubit/settings_cubit.dart';
import 'package:forcegauge/screens/main_screen.dart';

import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';

var audioPlayer = AudioPlayer();
var audioCache = AudioCache();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitDown,
    DeviceOrientation.portraitUp,
  ]);

  runApp(MainApp());
}

class MainApp extends StatefulWidget {
  MainApp();

  @override
  State<StatefulWidget> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<DevicemanagerCubit>(
          create: (_) => DevicemanagerCubit(),
        ),
        BlocProvider<SettingsCubit>(
          create: (_) => SettingsCubit(),
        )
      ],
      child: BlocListener<DevicemanagerCubit, DevicemanagerState>(
        listener: (context, state) {
          print("Save new devices");
          if (state is DevicemanagerPopulated) {
            BlocProvider.of<SettingsCubit>(context).saveDevices(state.devices);
          }
        },
        child: BlocConsumer<SettingsCubit, SettingsState>(
          listener: (context, state) {
            if (state is SettingsStateDevicesLoaded) {
              print("Load new devices");
              BlocProvider.of<DevicemanagerCubit>(context).loadDevicesFromJson(state.devices);
            }
          },
          builder: (context, state) {
            if (state is SettingsStateLoading) {
              return const CircularProgressIndicator();
            } else {
              return MaterialApp(
                  title: 'Force Gauge',
                  theme: ThemeData(
                    primarySwatch: BlocProvider.of<SettingsCubit>(context).settings.primarySwatch,
                    brightness:
                        BlocProvider.of<SettingsCubit>(context).settings.nightMode ? Brightness.dark : Brightness.light,
                  ),
                  home: MainScreen());
            }
          },
        ),
      ),
    );
  }
}
