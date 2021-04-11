import 'dart:convert';
import 'dart:math';

import 'package:flutter/rendering.dart';

class WorkoutReport {
  String name;
  double targetForce;
  DateTime date;

  WorkoutReport(name, date, targetForce) {
    this.date = date;
    this.name = name;
    this.targetForce = targetForce;
  }

  List<ReportValues> _reportValuesList = [];

  addValue(int set, int rep, double value) {
    var reportValues = getSetRepReport(set, rep);
    if (reportValues == null) {
      reportValues = new ReportValues(set, rep);
      _reportValuesList.add(reportValues);
    }
    reportValues.addValue(value);
  }

  clearValues(int set, int rep) {
    var reportValues = getSetRepReport(set, rep);
    if (reportValues != null) {
      _reportValuesList.remove(reportValues);
    }
  }

  ReportValues getSetRepReport(int set, int rep) {
    for (int i = 0; i < _reportValuesList.length; i++) {
      if (set == _reportValuesList[i].set && rep == _reportValuesList[i].rep) {
        return _reportValuesList[i];
      }
    }
    return null;
  }

  List<ReportValues> getAllReports() {
    return _reportValuesList;
  }

  factory WorkoutReport.fromJson(dynamic json) {
    var name = json["name"] as String;
    var date = DateTime.fromMillisecondsSinceEpoch(json["date"] as int);
    double targetForce = json["targetForce"] as double;
    var workoutReport = WorkoutReport(name, date, targetForce);

    var reportValuesListJson = jsonDecode(json["reportValuesList"]) as List;
    for (var reportValuesJson in reportValuesListJson) {
      var reportValues = ReportValues.fromJson(reportValuesJson);
      for (var v in reportValues._values) {
        workoutReport.addValue(reportValues.set, reportValues.rep, v);
      }
    }

    return workoutReport;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> jsonMap = new Map<String, dynamic>();
    jsonMap['name'] = name;
    jsonMap['date'] = date.millisecondsSinceEpoch;
    jsonMap['targetForce'] = targetForce;
    String reportValuesListString = jsonEncode(_reportValuesList.map((i) => i.toJson()).toList()).toString();
    jsonMap['reportValuesList'] = reportValuesListString;
    return jsonMap;
  }
}

class ReportValues {
  final int set;
  final int rep;

  ReportValues(this.set, this.rep);
  List<double> _values = [];
  double _min = 0;
  double _max = 0;
  double _average = 0;

  addValue(double value) {
    _values.add(value);
    _min = _values.fold(_values[0], min);
    _max = _values.fold(_values[0], max);
    _average = _values.reduce((a, b) => a + b) / _values.length;
  }

  getValues() {
    return _values;
  }

  getMin() {
    return _min;
  }

  getMax() {
    return _max;
  }

  getAverage() {
    return _average;
  }

  clear() {
    _min = 0;
    _max = 0;
    _average = 0;
  }

  factory ReportValues.fromJson(dynamic json) {
    var set = json["set"] as int;
    var rep = json["rep"] as int;
    var reportValues = ReportValues(set, rep);
    var valuesList = jsonDecode(json["values"]) as List;
    for (var v in valuesList) {
      reportValues.addValue(v);
    }
    return reportValues;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> jsonMap = new Map<String, dynamic>();
    String valuesString = jsonEncode(_values.map((i) => i).toList()).toString();
    jsonMap['set'] = set;
    jsonMap['rep'] = rep;
    jsonMap['values'] = valuesString;
    return jsonMap;
  }

  @override
  String toString() {
    var min = _min.toStringAsFixed(1);
    var max = _max.toStringAsFixed(1);
    var avg = _average.toStringAsFixed(1);

    return "min: $min, max: $max, avg: $avg";
  }
}
