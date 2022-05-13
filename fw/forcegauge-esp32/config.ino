#include <ArduinoJson.h>

DynamicJsonDocument configJSON(CONFIG_BUFFER_SIZE);

void startSPIFFS()
{
  if (!SPIFFS.begin(true)) {
    Serial.println("An Error has occurred while mounting SPIFFS");
    return;
  }
  File root = SPIFFS.open("/");
  File file = root.openNextFile();
  while (file) {
    Serial.print("FILE: ");
    Serial.println(file.name());
    file = root.openNextFile();
  }

//  
//  File file2 = SPIFFS.open("/index.htm");
//  if (!file2) {
//    Serial.println("Failed to open file for reading");
//    return;
//  }
//  Serial.println("File Content:");
//
//  while (file2.available()) {
//
//    Serial.write(file2.read());
//  }
//  file2.close();
}

void startConfig()
{
  startSPIFFS();
  
  if (loadConfig(&config) == false)
  {
    Serial.println("Failed to load config.json. making new one\n");
    makeDefaultConfig(&config);
    saveConfig(&config);
  }
  serializeJsonPretty(configJSON, Serial);
}

void makeDefaultConfig(configStruct* c)
{
  configJSON["name"] = "forcegauge";
  configJSON["APssid"] = "ForceGauge";
  configJSON["APpasswd"] = "1234567890";
  configJSON["ssid1"] = "";
  configJSON["passwd1"] = "";
  configJSON["ssid2"] = "";
  configJSON["passwd2"] = "";
  configJSON["ssid3"] = "";
  configJSON["passwd3"] = "";
  configJSON["offset"] = 0;
  configJSON["scale"] = 0.000231142;
  configJSON["filterCoeff"] = 0.0;
  configJSON["time"] = 0;
  copyConfig(c);
}

bool saveConfig(configStruct* c)
{
  bool retval = true;
  configJSON["offset"] = c->offset;
  configJSON["scale"] = c->scale;
  configJSON["filterCoeff"] = c->filterCoeff;
  configJSON["time"] = c->time;


  File jsonFile = SPIFFS.open(configFilename, "w");
  if (serializeJsonPretty(configJSON, jsonFile) == 0) {
    Serial.println("Failed to write to file.");
    retval = false;
  }
  jsonFile.close();
  Serial.println("Saving config: ");
  serializeJsonPretty(configJSON, Serial);
  return retval;
}

bool loadConfig(configStruct* c)
{
  bool retval = false;
  if (SPIFFS.exists(configFilename))
  {
    File file = SPIFFS.open(configFilename, "r");
    DeserializationError error = deserializeJson(configJSON, file);
    if (error) {
      Serial.print(F("deserializeJson() failed: "));
      Serial.println(error.f_str());
    }
    else
    {
      copyConfig(c);
      retval = true;
    }
    file.close();
  }
  return retval;
}

void copyConfig(configStruct *c)
{
  c->name = configJSON["name"];
  c->APssid = configJSON["APssid"];
  c->APpasswd = configJSON["APpasswd"];
  c->ssid1 = configJSON["ssid1"];
  c->passwd1 = configJSON["passwd1"];
  c->ssid2 = configJSON["ssid2"];
  c->passwd2 = configJSON["passwd2"];
  c->ssid3 = configJSON["ssid3"];
  c->passwd3 = configJSON["passwd3"];
  c->offset = configJSON["offset"];
  c->scale = configJSON["scale"];
  c->time = configJSON["time"];
  c->filterCoeff = configJSON["filterCoeff"];
}


const char* getConfigSSID(int n)
{
  if (n ==0 ) return config.ssid1;
  else if (n == 1 ) return config.ssid2;
  else if (n == 2 ) return config.ssid3;
  return nullptr;
}

const char* getConfigPasswd(int n)
{
  if (n ==0 ) return config.passwd1;
  else if (n == 1 ) return config.passwd2;
  else if (n == 2 ) return config.passwd3;
  return nullptr;
}
