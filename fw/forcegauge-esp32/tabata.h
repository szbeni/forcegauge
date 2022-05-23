#pragma once
#include <string>
#include "ArduinoJson.h"

class Tabata
{
private:
    // If tabata is Empty
    bool _isEmpty = true;

public:
    static const int maxNameLen = 32;

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

    static String stripName(String name)
    {
        return name.substring(0, maxNameLen);
    }

    void fromJsonVariant(ArduinoJson::JsonVariant doc)
    {
        name = (const char *)(doc["name"]);
        sets = doc["sets"];
        reps = doc["reps"];
        exerciseTime = doc["exerciseTime"];
        restTime = doc["restTime"];
        breakTime = doc["breakTime"];
        startDelay = doc["startDelay"];
        warningBeforeBreakEndsTime = doc["warningBeforeBreakEndsTime"];
        name = stripName(name);
        _isEmpty = false;
    }

    Tabata(ArduinoJson::JsonVariant doc)
    {
        fromJsonVariant(doc);
        name = stripName(name);

        _isEmpty = false;
    }

    Tabata(String jsonStr)
    {
        DynamicJsonDocument doc(256);
        deserializeJson(doc, jsonStr);
        fromJsonVariant(doc);
        _isEmpty = false;
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

    void toJsonObject(JsonObject obj)
    {
        obj["name"] = name;
        obj["sets"] = sets;
        obj["reps"] = reps;
        obj["exerciseTime"] = exerciseTime;
        obj["restTime"] = restTime;
        obj["breakTime"] = breakTime;
        obj["startDelay"] = startDelay;
        obj["warningBeforeBreakEndsTime"] = warningBeforeBreakEndsTime;
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
          warningBeforeBreakEndsTime(warningBeforeBreakEndsTime)
    {
        this->name = stripName(this->name);
        _isEmpty = false;
    }

    Tabata()
    {
    }

    bool isEmpty()
    {
        return _isEmpty;
    }

    const char *getName() { return name.c_str(); }

    int getTotalTime()
    {
        return startDelay + (exerciseTime * sets * reps) + (restTime * sets * (reps - 1)) + (breakTime * (sets - 1));
    }
};