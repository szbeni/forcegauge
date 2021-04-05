import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:assets_audio_player/assets_audio_player.dart';

import '../../main.dart';

class TabataSounds {
  String countdownPip;
  String startRep;
  String startRest;
  String startBreak;
  String startSet;
  String endWorkout;
  String warningBeforeBreakEnds;
}

class Tabata {
  /// Sets in a workout
  int sets;

  /// Reps in a set
  int reps;

  /// Time to exercise for in each rep
  Duration exerciseTime;

  /// Rest time between reps
  Duration restTime;

  /// Break time between sets
  Duration breakTime;

  /// Initial countdown before starting workout
  Duration startDelay;

  /// Warning time before end of break
  Duration warningBeforeBreakEndsTime;

  Tabata({
    this.sets,
    this.reps,
    this.startDelay,
    this.exerciseTime,
    this.restTime,
    this.breakTime,
    this.warningBeforeBreakEndsTime,
  });

  Duration getTotalTime() {
    return (exerciseTime * sets * reps) + (restTime * sets * (reps - 1)) + (breakTime * (sets - 1));
  }

  Tabata.fromJson(Map<String, dynamic> json)
      : sets = json['sets'],
        reps = json['reps'],
        exerciseTime = Duration(seconds: json['exerciseTime']),
        restTime = Duration(seconds: json['restTime']),
        breakTime = Duration(seconds: json['breakTime']),
        startDelay = Duration(seconds: json['startDelay']),
        warningBeforeBreakEndsTime = Duration(seconds: json['warningBeforeBreakEndsTime']);

  Map<String, dynamic> toJson() => {
        'sets': sets,
        'reps': reps,
        'exerciseTime': exerciseTime.inSeconds,
        'restTime': restTime.inSeconds,
        'breakTime': breakTime.inSeconds,
        'startDelay': startDelay.inSeconds,
        'warningBeforeBreakEndsTime': warningBeforeBreakEndsTime.inSeconds,
      };
}

Tabata get defaultTabata => Tabata(
      sets: 5,
      reps: 5,
      startDelay: Duration(seconds: 10),
      exerciseTime: Duration(seconds: 20),
      restTime: Duration(seconds: 10),
      breakTime: Duration(seconds: 60),
      warningBeforeBreakEndsTime: Duration(seconds: 20),
    );

enum WorkoutState { initial, starting, exercising, resting, breaking, finished }

class WorkoutReport {
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

class SetRep {
  final int set;
  final int rep;
  SetRep(this.set, this.rep);

  @override
  String toString() {
    return "Set: $set, Rep: $rep";
  }
}

class Workout {
  Tabata _config;
  TabataSounds _sounds;

  Map<String, WorkoutReport> _workoutReports = {};

  /// Callback for when the workout's state has changed.
  Function _onStateChange;

  WorkoutState _step = WorkoutState.initial;

  Timer _timer;

  /// Time left in the current step
  Duration _timeLeft;

  Duration _totalTime = Duration(seconds: 0);

  double _targetForce = 0;

  double _lastForceValue = 0;

  bool _recordReportStarted = false;

  /// Current set
  int _set = 0;

  /// Current rep
  int _rep = 0;

  Workout(this._config, this._sounds, this._targetForce, this._onStateChange);

  void newForceValue(double force) {
    this._lastForceValue = force;
    if (force > this._targetForce) {
      this._recordReportStarted = true;
    }
    //record only in workout
    if (_step == WorkoutState.exercising && this._recordReportStarted) {
      var current = SetRep(_set, _rep).toString();
      if (!_workoutReports.containsKey(current)) _workoutReports[current] = WorkoutReport();
      _workoutReports[current].addValue(force);
    }
  }

  WorkoutReport getLastReport() {
    return getWorkoutReport(_set, _rep);
  }

  WorkoutReport getWorkoutReport(int set, int rep) {
    var current = SetRep(set, rep).toString();
    if (_workoutReports.containsKey(current)) return _workoutReports[current];
    return null;
  }

  Map<String, WorkoutReport> getWorkoutReports() {
    return _workoutReports;
  }

  /// Starts or resumes the workout
  start() {
    if (_step == WorkoutState.initial) {
      _step = WorkoutState.starting;
      if (_config.startDelay.inSeconds == 0) {
        _nextStep();
      } else {
        _timeLeft = _config.startDelay;
      }
    }
    _timer = Timer.periodic(Duration(seconds: 1), _tick);
    _onStateChange();
  }

  finished() {
    this.pause();
    this._step = WorkoutState.finished;
  }

  /// Pauses the workout
  pause() {
    _timer.cancel();
    _onStateChange();
  }

  /// Stops the timer without triggering the state change callback.
  dispose() {
    _timer.cancel();
  }

  _tick(Timer timer) {
    if (_step != WorkoutState.starting) {
      _totalTime += Duration(seconds: 1);
    }

    bool targetForceReached = true;
    if (this.step == WorkoutState.exercising) {
      if (this._recordReportStarted == false) {
        targetForceReached = false;
      }
    }
    if (targetForceReached) {
      if (_timeLeft.inSeconds == 1) {
        _nextStep();
      } else {
        _timeLeft -= Duration(seconds: 1);

        if (_timeLeft.inSeconds <= 3 && _timeLeft.inSeconds >= 1) {
          _playSound(_sounds.countdownPip);
        }
        if (_timeLeft.inSeconds == _config.warningBeforeBreakEndsTime.inSeconds &&
            config.warningBeforeBreakEndsTime.inSeconds > 0 &&
            _step != WorkoutState.exercising) {
          _playSound(_sounds.warningBeforeBreakEnds);
        }
      }
    }
    _onStateChange();
  }

  /// Moves the workout to the next step and sets up state for it.
  _nextStep() {
    if (this._targetForce == 0)
      _recordReportStarted = true;
    else
      _recordReportStarted = false;
    if (_step == WorkoutState.exercising) {
      if (rep == _config.reps) {
        if (set == _config.sets) {
          _finish();
        } else {
          _startBreak();
        }
      } else {
        _startRest();
      }
    } else if (_step == WorkoutState.resting) {
      _startRep();
    } else if (_step == WorkoutState.starting || _step == WorkoutState.breaking) {
      _startSet();
    }
  }

  Future _playSound(String sound) {
    //silent mode
    if (_sounds == null) {
      return Future.value();
    }
    //audioCache.duckAudio = true;
    //return audioCache.play("sounds/" + sound);
    AssetsAudioPlayer.newPlayer().open(
      Audio("assets/sounds/" + sound),
      showNotification: false,
      autoStart: true,
    );

    return Future.value();
  }

  _startRest() {
    _step = WorkoutState.resting;
    if (_config.restTime.inSeconds == 0) {
      _nextStep();
      return;
    }
    _timeLeft = _config.restTime;
    _playSound(_sounds.startRest);
  }

  _startRep() {
    _rep++;
    _step = WorkoutState.exercising;
    _timeLeft = _config.exerciseTime;
    _playSound(_sounds.startRep);
  }

  _startBreak() {
    _step = WorkoutState.breaking;
    if (_config.breakTime.inSeconds == 0) {
      _nextStep();
      return;
    }
    _timeLeft = _config.breakTime;
    _playSound(_sounds.startBreak);
  }

  _startSet() {
    _set++;
    _rep = 1;
    _step = WorkoutState.exercising;
    _timeLeft = _config.exerciseTime;
    _playSound(_sounds.startSet);
  }

  _finish() {
    _timer.cancel();
    _step = WorkoutState.finished;
    _timeLeft = Duration(seconds: 0);
    _playSound(_sounds.endWorkout).then((p) {
      if (p == null) {
        return;
      }
      p.onPlayerCompletion.first.then((_) {
        _playSound(_sounds.endWorkout);
      });
    });
  }

  get config => _config;

  get set => _set;

  get rep => _rep;

  get step => _step;

  get timeLeft => _timeLeft;

  get totalTime => _totalTime;

  get isActive => _timer != null && _timer.isActive;
}
