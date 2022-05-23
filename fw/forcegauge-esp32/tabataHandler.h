#pragma once
#include "tabata.h"
#include <ArduinoJson.h>

class TabataHandler
{
private:
    DynamicJsonDocument &_tabataJSON;
    const char *_tabataFile;
    static const int maxTabataCount = 30;

public:
    TabataHandler(DynamicJsonDocument &tabataJSON, const char *tabataFile) : _tabataJSON(tabataJSON), _tabataFile(tabataFile)
    {
    }

    void begin()
    {
        refreshList();
    }

    int getTabataCount()
    {
        return _tabataJSON.size();
    }

    int refreshList()
    {
        if (SPIFFS.exists(_tabataFile))
        {
            File file = SPIFFS.open(_tabataFile, "r");
            DeserializationError error = deserializeJson(_tabataJSON, file);
            if (error)
            {
                Serial.print("Failed to parse tabatas: ");
                Serial.println(_tabataFile);
            }
            else
            {
                for (int i = 0; i < getTabataCount(); i++)
                {
                    String name = _tabataJSON[i]["name"];
                    name = Tabata::stripName(name);
                    _tabataJSON[i]["name"] = name;
                    Serial.println(name);
                }
            }
            file.close();
        }
        else
        {
            Serial.print("Tabata File doesn't exist, creating and empty one.");
            Serial.println(_tabataFile);

            File file = SPIFFS.open(_tabataFile, "w");
            file.print("[]");
            file.close();
        }

        return _tabataJSON.size();
    }

    void save()
    {
        File jsonFile = SPIFFS.open(_tabataFile, "w");
        if (serializeJsonPretty(_tabataJSON, jsonFile) == 0)
        {
            Serial.println("Failed to write tabata file: ");
            Serial.println(_tabataFile);
        }
        jsonFile.close();
    }

    JsonObject getTabata(int id)
    {
        return _tabataJSON[id];
    }

    bool addTabata(Tabata &t)
    {
        if (findTabataID(t.getName()) == -1)
        {
            JsonObject obj = _tabataJSON.createNestedObject();
            t.toJsonObject(obj);
            save();
            return true;
        }
        else
        {
            Serial.print("Tabata already exists: ");
            Serial.println(t.getName());
        }
        return false;
    }

    bool addTabata(String jsonStr)
    {
        Serial.println(jsonStr);
        Tabata t(jsonStr);
        if (t.isEmpty())
        {
            Serial.print("Cannot add tabta: ");
            Serial.println(jsonStr);
            return false;
        }
        else
        {
            return addTabata(t);
        }
    }

    const char *getTabataName(int id)
    {
        if (id >= getTabataCount())
            return nullptr;

        return (const char *)(_tabataJSON[id]["name"]);
    }

    void removeTabata(int id)
    {
        if (id < getTabataCount())
        {
            _tabataJSON.remove(id);
            save();
        }
    }

    void removeTabata(const char *name)
    {
        int id = findTabataID(name);
        if (id >= 0)
        {
            _tabataJSON.remove(id);
            save();
        }
    }

    int findTabataID(const char *name)
    {

        for (int i = 0; i < getTabataCount(); i++)
        {
            String currName = getTabataName(i);

            if (String(name) == currName)
            {
                return i;
            }
        }
        return -1;
    }
};