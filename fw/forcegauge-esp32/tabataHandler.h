#pragma once
#include "tabata.h"

class TabataHandler
{

private:
    static const int maxTabataCount = 30;
    const char *_tabataDir;
    int _tabataCntr = 0;
    char tabataNames[maxTabataCount][32];

    String getTabataPath(String name)
    {
        String fullPath = _tabataDir;
        fullPath += "/";
        fullPath += name;
        fullPath += ".json";
        return fullPath;
    }

public:
    TabataHandler(const char *tabataDir) : _tabataDir(tabataDir)
    {
        _tabataCntr = 0;
    }

    void begin()
    {
        refreshList();
    }

    int getTabataCount()
    {
        return _tabataCntr;
    }

    int refreshList()
    {
        _tabataCntr = 0;
        File root = SPIFFS.open(_tabataDir);
        File file = root.openNextFile();
        if (!file)
            return _tabataCntr;

        while (file)
        {
            Serial.println(file.name());
            strncpy(tabataNames[_tabataCntr], file.name(), 31);
            _tabataCntr++;
            if (_tabataCntr >= maxTabataCount)
                break;
            file = root.openNextFile();
        }
        return _tabataCntr;
    }

    bool openTabata(int id, DynamicJsonDocument *tabataJSON)
    {
        if (id >= _tabataCntr)
            return false;

        String filename = _tabataDir;
        filename += "/";
        filename += tabataNames[id];

        bool retval = false;
        if (SPIFFS.exists(filename.c_str()))
        {
            File file = SPIFFS.open(filename.c_str(), "r");
            DeserializationError error = deserializeJson(*tabataJSON, file);
            if (error)
            {
                Serial.print("Failed to parse tabata: ");
                Serial.println(filename);
            }
            else
            {
                retval = true;
            }
            file.close();
        }
        return retval;
    }

    bool createTabata(Tabata &t, const char *name = nullptr)
    {
        bool retval = false;

        String strippedName = "";
        if (name != nullptr)
        {
            strippedName = name;
        }
        else
        {
            strippedName = (char *)t.getName();
        }
        strippedName.replace(" ", "_");
        strippedName.replace("/[^A-Za-z0-9]/g", "");

        String filename = getTabataPath(strippedName);

        File jsonFile = SPIFFS.open(filename.c_str(), "w");
        if (jsonFile.print(t.toJson()))
        {
            Serial.print("Tabata written");
            Serial.println(filename);
            retval = true;
        }
        else
        {
            Serial.print("Failed to write tabata: ");
            Serial.println(filename);
        }
        jsonFile.close();
        return retval;
    }

    const char *getTabataName(int id)
    {
        if (id >= _tabataCntr)
            return nullptr;
        return tabataNames[id];
    }
    bool removeTabata(const char *name)
    {
        int id = findTabataID(name);
        if (id >= 0)
        {
            String filename = getTabataPath(name);
            if (SPIFFS.exists(filename.c_str()))
            {
                SPIFFS.remove(filename.c_str());
                return true;
            }
        }
        return false;
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