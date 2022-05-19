#pragma once

#include "tabata.h"

class Workout {
 private:
  enum WorkoutState { initial, starting, exercising, resting, breaking, finished };
  static std::string stepName(WorkoutState step) {
    switch (step) {
      case exercising:
        return "Exercise";
      case resting:
        return "Rest";
      case breaking:
        return "Break";
      case finished:
        return "Finished";
      case starting:
        return "Starting";
      default:
        return "";
    }
  }

  Tabata _config;
  WorkoutState _step = initial;
  int _set = 0;  // Current set
  int _rep = 0;  // Current rep
  int _totalTime = 0;
  float _targetForce = 0;
  float _lastForceValue = 0;
  bool _recordReportStarted = false;
  //   TabataSounds _sounds;
  //   WorkoutReport _workoutReport;
  //   Function _onStateChange;
  //   Timer _timer;
  //   Duration _timeLeft;
  //   Duration _totalTime = Duration(seconds : 0);
  //   /// Callback for when the workout's state has changed.
  //   /// Time left in the current step
  //   // Wait a bit after user action
  //   Duration _waitAfterUserAction = Duration(seconds : 0);
  //   Workout(this._config, this._sounds, this._targetForce, this._onStateChange) {
  //     this._workoutReport = new WorkoutReport(_config.name, DateTime.now(), _targetForce);
  //   }

 public:
  Workout(Tabata& tabata, float targetForce = 0) : _config(tabata), _targetForce(targetForce){};

  // New force value has arrived
  void newForceValue(double force) {
    _lastForceValue = force;
    bool playSound = false;
    if (force > _targetForce && _recordReportStarted == false) {
      _recordReportStarted = true;
      playSound = true;
    }
    // record only in workout
    if (_step == exercising && _recordReportStarted) {
      //   _workoutReport.addValue(_set, _rep, force);
      //   if (playSound)
      //     _playSound(_sounds.targetReached);
    }
  }

  // Starts or resumes the workout
  void start() {
    if (_step == initial) {
      _step = starting;
      if (_config.startDelay == 0) {
        _nextStep();
      } else {
        _timeLeft = _config.startDelay;
      }
    }
    //_timer = Timer.periodic(Duration(seconds : 1), _tick);
    //_onStateChange();
  }

  void next() {
    //_waitAfterUserAction = Duration(seconds : 0);
    _nextStep();
  }

  void previous() {
    //_waitAfterUserAction = Duration(seconds : 0);
    _prevStep();
  }

  void finished() {
    pause();
    _step = finished;
    _onStateChange();
  }

  //   /// Pauses the workout
  void pause() {
    _timer.cancel();
    _onStateChange();
  }

  //   /// Stops the timer without triggering the state change callback.
  //   dispose() { _timer.cancel(); }

  void _tick() {
    // if (_waitAfterUserAction > 0) {
    //   _waitAfterUserAction -= Duration(seconds : 1);
    //   return;
    // }

    if (_step != starting) {
      _totalTime += 1;
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
        _timeLeft -= Duration(seconds : 1);

        if (_timeLeft.inSeconds <= 3 && _timeLeft.inSeconds >= 1) {
          _playSound(_sounds.countdownPip);
        } else if (_targetForce != null && this._step == WorkoutState.exercising) {
          if (_targetForce > 0.001)
            _playSound(_sounds.countdownPip);
        }
        if (_timeLeft.inSeconds == _config.warningBeforeBreakEndsTime.inSeconds &&
            config.warningBeforeBreakEndsTime.inSeconds > 0 && _step != WorkoutState.exercising) {
          _playSound(_sounds.warningBeforeBreakEnds);
        }
      }
    }
    _onStateChange();
  }

  void _prevStep() {
    //_workoutReport.clearValues(_set, _rep);
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

  //   /// Moves the workout to the next step and sets up state for it.
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

  //   Future _playSound(String sound) {
  //     // silent mode
  //     if (sound == null || sound.length == 0) {
  //       return Future.value();
  //     }
  //     // audioCache.duckAudio = true;
  //     // return audioCache.play("sounds/" + sound);
  //     AssetsAudioPlayer.newPlayer().open(Audio("assets/sounds/" + sound), showNotification : false, autoStart : true,
  //     );

  //     return Future.value();
  //   }

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
    _timeLeft = Duration(seconds : 0);
    _playSound(_sounds.endWorkout).then((p) {
      if (p == null) {
        return;
      }
      p.onPlayerCompletion.first.then((_) { _playSound(_sounds.endWorkout); });
    });
  }

  //   get config = > _config;

  //   get set = > _set;

  //   get rep = > _rep;

  //   get step = > _step;

  //   get targetForce = > targetForce;

  //   get timeLeft = > _timeLeft;

  //   get workoutReport = > _workoutReport;

  //   get totalTime = > _totalTime;

  //   get isActive = > _timer != null&& _timer.isActive;
};
