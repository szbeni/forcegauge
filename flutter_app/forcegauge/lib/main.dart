import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forcegauge/bloc/cubit/devicemanager_cubit.dart';
import 'package:forcegauge/bloc/cubit/settings_cubit.dart';
import 'package:forcegauge/bloc/cubit/tabatamanager_cubit.dart';
import 'package:forcegauge/screens/main_screen.dart';

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
        BlocProvider<TabatamanagerCubit>(
          create: (_) => TabatamanagerCubit(),
        ),
        BlocProvider<DevicemanagerCubit>(
          create: (_) => DevicemanagerCubit(),
        ),
        BlocProvider<SettingsCubit>(
          create: (_) => SettingsCubit(),
        )
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<DevicemanagerCubit, DevicemanagerState>(
            listener: (context, state) {
              if (state is DevicemanagerUpdated) {
                print("Devices updated, saving..");
                BlocProvider.of<SettingsCubit>(context).saveDevices(state.devices);
              }
            },
          ),
          BlocListener<TabatamanagerCubit, TabatamanagerState>(
            listener: (context, state) {
              if (state is TabatamanagerUpdated) {
                print("Tabatas updated, saving...");
                BlocProvider.of<SettingsCubit>(context).saveTabatas(state.tabatas);
              }
            },
          )
        ],
        child: BlocConsumer<SettingsCubit, SettingsState>(
          listener: (context, state) {
            if (state is SettingsStateDevicesLoaded) {
              print("Settings Loaded: devices");
              BlocProvider.of<DevicemanagerCubit>(context).loadDevicesFromJson(state.devices);
            } else if (state is SettingsStateTabatasLoaded) {
              print("Settings Loaded: Tabatas");
              BlocProvider.of<TabatamanagerCubit>(context).loadTabatasFromJson(state.tabatas);
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
