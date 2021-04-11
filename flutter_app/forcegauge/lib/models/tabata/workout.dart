import 'dart:async';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:forcegauge/models/tabata/report.dart';
import 'package:forcegauge/models/tabata/tabata.dart';

enum WorkoutState { initial, starting, exercising, resting, breaking, finished }

class Workout {
  static String stepName(WorkoutState step) {
    switch (step) {
      case WorkoutState.exercising:
        return 'Exercise';
      case WorkoutState.resting:
        return 'Rest';
      case WorkoutState.breaking:
        return 'Break';
      case WorkoutState.finished:
        return 'Finished';
      case WorkoutState.starting:
        return 'Starting';
      default:
        return '';
    }
  }

  Tabata _config;
  TabataSounds _sounds;

  //
  WorkoutReport _workoutReport;

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

  //Wait a bit after user action
  Duration _waitAfterUserAction = Duration(seconds: 0);

  Workout(this._config, this._sounds, this._targetForce, this._onStateChange) {
    this._workoutReport = new WorkoutReport(_config.name, DateTime.now(), _targetForce);
  }

  void newForceValue(double force) {
    this._lastForceValue = force;
    bool playSound = false;
    if (force > this._targetForce && this._recordReportStarted == false) {
      this._recordReportStarted = true;
      playSound = true;
    }
    //record only in workout
    if (_step == WorkoutState.exercising && this._recordReportStarted) {
      _workoutReport.addValue(_set, _rep, force);
      if (playSound) _playSound(_sounds.targetReached);
    }
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

  next() {
    _waitAfterUserAction = Duration(seconds: 0);
    _nextStep();
  }

  previous() {
    _waitAfterUserAction = Duration(seconds: 0);
    _prevStep();
  }

  finished() {
    this.pause();
    this._step = WorkoutState.finished;
    _onStateChange();
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
    if (_waitAfterUserAction.inSeconds > 0) {
      _waitAfterUserAction -= Duration(seconds: 1);
      return;
    }

    if (_step != WorkoutState.starting) {
      _totalTime += Duration(seconds: 1);
    }

    bool targetForceReached = true;
    if (this._step == WorkoutState.exercising) {
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
        } else if (_targetForce != null && this._step == WorkoutState.exercising) {
          if (_targetForce > 0.001) _playSound(_sounds.countdownPip);
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

  _prevStep() {
    _workoutReport.clearValues(_set, _rep);
    if (rep == 0 && set == 0) {
      _step = WorkoutState.starting;
      _timeLeft = _config.startDelay;
      return;
    }
    if (_step == WorkoutState.exercising) {
      if (rep == 1) {
        if (set == 1) {
          _set = 0;
          _rep = 0;
          _step = WorkoutState.starting;
          _timeLeft = _config.startDelay;
        } else {
          _set--;
          _rep = config.reps;
          _startBreak();
        }
      } else {
        _rep--;
        _startRest();
      }
    } else if (_step == WorkoutState.resting) {
      _rep--;
      _startRep();
      _workoutReport.clearValues(_set, _rep);
    } else if (_step == WorkoutState.starting || _step == WorkoutState.breaking) {
      _set--;
      _startSet();
      _rep = config.reps;
      _workoutReport.clearValues(_set, _rep);
    }
  }

  /// Moves the workout to the next step and sets up state for it.
  _nextStep() {
    print("Rep: $rep, Set: $set");
    if (this._targetForce < 0.001)
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
    if (sound == null || sound.length == 0) {
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
    print("Start rep: $_targetForce");
    if (_targetForce < 0.001 && _sounds.targetReached != '') {
      _playSound(_sounds.startRep);
    }
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
    if (_targetForce < 0.001 && _sounds.targetReached != '') {
      _playSound(_sounds.startSet);
    }
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

  get targetForce => targetForce;

  get timeLeft => _timeLeft;

  get workoutReport => _workoutReport;

  get totalTime => _totalTime;

  get isActive => _timer != null && _timer.isActive;
}
