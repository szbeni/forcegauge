import 'package:flutter/material.dart';
import 'package:forcegauge/models/tabata/tabata.dart';

class Settings {
  bool nightMode;
  bool silentMode;
  Color primarySwatch;
  double fontSize;
  Tabata savedTabata;
  TabataSounds tabataSounds = new TabataSounds();

  fromJson(Map<String, dynamic> json) {
    fontSize = json['fontSize'] ?? 150;
    nightMode = json['nightMode'] ?? false;
    silentMode = json['silentMode'] ?? false;
    primarySwatch = Colors.primaries[
        json['primarySwatch'] ?? Colors.primaries.indexOf(Colors.blue)];
    tabataSounds.countdownPip = json['countdownPip'] ?? 'pip.mp3';
    tabataSounds.startRep = json['startRep'] ?? 'boop.mp3';
    tabataSounds.startRest = json['startRest'] ?? 'dingdingding.mp3';
    tabataSounds.startBreak = json['startBreak'] ?? 'dingdingding.mp3';
    tabataSounds.startSet = json['startSet'] ?? 'boop.mp3';
    tabataSounds.endWorkout = json['endWorkout'] ?? 'dingdingding.mp3';
  }

  Map<String, dynamic> toJson() => {
        'fontSize': fontSize,
        'nightMode': nightMode,
        'silentMode': silentMode,
        'primarySwatch': Colors.primaries.indexOf(primarySwatch),
        'countdownPip': tabataSounds.countdownPip,
        'startRep': tabataSounds.startRep,
        'startRest': tabataSounds.startRest,
        'startBreak': tabataSounds.startBreak,
        'startSet': tabataSounds.startSet,
        'endWorkout': tabataSounds.endWorkout,
        'tabata': savedTabata
      };
}
