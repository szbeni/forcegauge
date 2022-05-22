#pragma once
#include <string>
#include "ArduinoJson.h"

class Tabata
{
public:
    String name;

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

    void fromJsonVariant(ArduinoJson::JsonVariant doc)
    {
        name = (const char*)(doc["name"]);
        sets = doc["sets"];
        reps = doc["reps"];
        exerciseTime = doc["exerciseTime"];
        restTime = doc["restTime"];
        breakTime = doc["breakTime"];
        startDelay = doc["startDelay"];
        warningBeforeBreakEndsTime = doc["warningBeforeBreakEndsTime"];
    }

    Tabata(ArduinoJson::JsonVariant doc)
    {
        fromJsonVariant(doc);
    }

    Tabata(String jsonStr)
    {
        DynamicJsonDocument doc(256);
        deserializeJson(doc, jsonStr);
        fromJsonVariant(doc);
    }

    String toJson(bool pretty = false)
    {
        String jsonStr;
        DynamicJsonDocument doc(256);

        doc["name"] = name;
        doc["sets"] = sets;
        doc["reps"] = reps;
        doc["exerciseTime"] = exerciseTime;
        doc["restTime"] = restTime;
        doc["breakTime"] = breakTime;
        doc["startDelay"] = startDelay;
        doc["warningBeforeBreakEndsTime"] = warningBeforeBreakEndsTime;

        if (pretty)
        {
            serializeJsonPretty(doc, jsonStr);
        }
        else
        {
            serializeJson(doc, jsonStr);
        }
        return jsonStr;
    }

    Tabata(const char *name,
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

    const char *getName() { return name.c_str(); }

    int getTotalTime()
    {
        return startDelay + (exerciseTime * sets * reps) + (restTime * sets * (reps - 1)) + (breakTime * (sets - 1));
    }
};