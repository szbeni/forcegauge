import 'dart:math';

class TabataSounds {
  String countdownPip = "";
  String startRep = "";
  String startRest = "";
  String startBreak = "";
  String startSet = "";
  String endWorkout = "";
  String warningBeforeBreakEnds = "";
  String targetReached = "";
}

class Tabata {
  String name;

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
    this.name,
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
      : name = json['name'],
        sets = json['sets'],
        reps = json['reps'],
        exerciseTime = Duration(seconds: json['exerciseTime']),
        restTime = Duration(seconds: json['restTime']),
        breakTime = Duration(seconds: json['breakTime']),
        startDelay = Duration(seconds: json['startDelay']),
        warningBeforeBreakEndsTime = Duration(seconds: json['warningBeforeBreakEndsTime']);

  Map<String, dynamic> toJson() => {
        'name': name,
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
      name: "MyWorkout",
      sets: 5,
      reps: 5,
      startDelay: Duration(seconds: 10),
      exerciseTime: Duration(seconds: 20),
      restTime: Duration(seconds: 10),
      breakTime: Duration(seconds: 60),
      warningBeforeBreakEndsTime: Duration(seconds: 20),
    );
