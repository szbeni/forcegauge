DynamicJsonDocument configJSON(CONFIG_BUFFER_SIZE);

void startConfig()
{
  if (loadConfig(&config) == false)
  {
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
  configJSON["time"] = 0;
  copyConfig(c);
}

bool saveConfig(configStruct* c)
{
  bool retval = true;
  configJSON["offset"] = c->offset;
  configJSON["scale"] = c->scale;
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
}


void handleConfigUpdate()
{
  for (int i = 0; i < server.args(); i++) {
    if (configJSON.containsKey(server.argName(i)))
    {
        configJSON[server.argName(i)] = server.arg(i);
    }
  }
  copyConfig(&config);
  saveConfig(&config);
  if (server.uri().endsWith("/configure.html"))
    handleFileRead("/configure.html");
}

bool loggedIn = false;
void handleLoginPage()
{
  Serial.println("Login page");
  Serial.println(loggedIn);
  if (loggedIn == false)
  {
    if (server.method() == HTTP_POST)
    {
      handleConfigUpdate();
      loggedIn = true;
    }
    else
    {
      handleFileRead("/configure.html");
    }      
  }
  else
  {
    server.send(204);
  }
}
