import 'dart:async';
import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';

var audioPlayer = AudioPlayer();
var audioCache = AudioCache();

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
    return (exerciseTime * sets * reps) +
        (restTime * sets * (reps - 1)) +
        (breakTime * (sets - 1));
  }

  Tabata.fromJson(Map<String, dynamic> json)
      : sets = json['sets'],
        reps = json['reps'],
        exerciseTime = Duration(seconds: json['exerciseTime']),
        restTime = Duration(seconds: json['restTime']),
        breakTime = Duration(seconds: json['breakTime']),
        startDelay = Duration(seconds: json['startDelay']),
        warningBeforeBreakEndsTime =
            Duration(seconds: json['warningBeforeBreakEndsTime']);

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

class Workout {
  Tabata _config;
  TabataSounds _sounds;

  /// Callback for when the workout's state has changed.
  Function _onStateChange;

  WorkoutState _step = WorkoutState.initial;

  Timer _timer;

  /// Time left in the current step
  Duration _timeLeft;

  Duration _totalTime = Duration(seconds: 0);

  /// Current set
  int _set = 0;

  /// Current rep
  int _rep = 0;

  Workout(this._config, this._sounds, this._onStateChange);

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

    if (_timeLeft.inSeconds == 1) {
      _nextStep();
    } else {
      _timeLeft -= Duration(seconds: 1);
      if (_timeLeft.inSeconds <= 3 && _timeLeft.inSeconds >= 1) {
        _playSound(_sounds.countdownPip);
      }
      if (_timeLeft.inSeconds == _config.warningBeforeBreakEndsTime &&
          config.warningBeforeBreakEndsTime > 0) {
        _playSound(_sounds.warningBeforeBreakEnds);
      }
    }

    _onStateChange();
  }

  /// Moves the workout to the next step and sets up state for it.
  _nextStep() {
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
    } else if (_step == WorkoutState.starting ||
        _step == WorkoutState.breaking) {
      _startSet();
    }
  }

  Future _playSound(String sound) {
    //silent mode
    if (_sounds == null) {
      return Future.value();
    }
    try {
      return audioCache.play("sounds/" + sound);
    } catch (e) {}
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
