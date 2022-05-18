#pragma once
#include <iostream>
#include "ArduinoJson.h"

class Tabata {
 private:
  std::string name;

  /// Sets in a workout
  int sets;

  /// Reps in a set
  int reps;

  /// Time to exercise for in each rep
  int exerciseTime;

  /// Rest time between reps
  int restTime;

  /// Break time between sets
  int breakTime;

  /// Initial countdown before starting workout
  int startDelay;

  /// Warning time before end of break
  int warningBeforeBreakEndsTime;

 public:
  Tabata(std::string jsonStr) {
    DynamicJsonDocument doc(2048);
    deserializeJson(doc, jsonStr);
    name = (const char*)(doc["name"]);
    sets = doc["sets"];
    reps = doc["reps"];
    exerciseTime = doc["exerciseTime"];
    restTime = doc["restTime"];
    breakTime = doc["breakTime"];
    startDelay = doc["startDelay"];
    warningBeforeBreakEndsTime = doc["warningBeforeBreakEndsTime"];
  }

  std::string toJson() {
    std::string retval = "{";
    retval += "\"";
  }

  Tabata(std::string name,
         int sets,
         int reps,
         int exerciseTime,
         int restTime,
         int breakTime,
         int startDelay,
         int warningBeforeBreakEndsTime)
      : name(name),
        sets(sets),
        reps(reps),
        exerciseTime(exerciseTime),
        restTime(restTime),
        breakTime(breakTime),
        startDelay(startDelay),
        warningBeforeBreakEndsTime(warningBeforeBreakEndsTime) {}

  const std::string getName() { return name; }

  int getTotalTime() {
    return (exerciseTime * sets * reps) + (restTime * sets * (reps - 1)) + (breakTime * (sets - 1));
  }
};