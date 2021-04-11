import 'dart:math';

class SetRep {
  final int set;
  final int rep;
  SetRep(this.set, this.rep);

  @override
  String toString() {
    return "Set: $set, Rep: $rep";
  }
}

class WorkoutReport {
  Map<String, ReportValues> _valuesMap = new Map<String, ReportValues>();
  addValue(int set, int rep, double value) {
    var current = SetRep(set, rep).toString();

    if (!_valuesMap.containsKey(current)) _valuesMap[current] = ReportValues();
    _valuesMap[current].addValue(value);
  }

  clearValues(int set, int rep) {
    var current = SetRep(set, rep).toString();
    if (_valuesMap.containsKey(current)) {
      _valuesMap.remove(current);
    }
  }

  ReportValues getSetRepReport(int set, int rep) {
    var current = SetRep(set, rep).toString();
    if (_valuesMap.containsKey(current)) {
      return _valuesMap[current];
    }
    return null;
  }

  Map<String, ReportValues> getAllReports() {
    return _valuesMap;
  }
}

class ReportValues {
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

  @override
  String toString() {
    var min = _min.toStringAsFixed(1);
    var max = _max.toStringAsFixed(1);
    var avg = _average.toStringAsFixed(1);

    return "min: $min, max: $max, avg: $avg";
  }
}
