import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forcegauge/bloc/cubit/devicemanager_cubit.dart';
import 'package:forcegauge/screens/main_screen.dart';
import 'package:forcegauge/models/settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitDown,
    DeviceOrientation.portraitUp,
  ]);

  SharedPreferences prefs = await SharedPreferences.getInstance();
  settings = new Settings(prefs);

  runApp(MainApp());
}

class MainApp extends StatefulWidget {
  MainApp();

  @override
  State<StatefulWidget> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  void initState() {
    settings.addListener(onSettingsChanged);
    super.initState();
  }

  @override
  dispose() {
    settings.removeListener(onSettingsChanged);
    super.dispose();
  }

  onSettingsChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<DevicemanagerCubit>(
          create: (_) => DevicemanagerCubit(),
        ),
      ],
      child: MaterialApp(
          title: 'Force Gauge',
          theme: ThemeData(
            primarySwatch: settings.primarySwatch,
            brightness: settings.nightMode ? Brightness.dark : Brightness.light,
          ),
          home: MainScreen()),
    );

    return MaterialApp(
        title: 'Force Gauge',
        theme: ThemeData(
          primarySwatch: settings.primarySwatch,
          brightness: settings.nightMode ? Brightness.dark : Brightness.light,
        ),
        home: MainScreen());
  }
}
