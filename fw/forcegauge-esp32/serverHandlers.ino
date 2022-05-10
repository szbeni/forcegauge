AsyncWebSocketClient * globalClient = NULL;

void webSocketBroadcastScaleOffset()
{
  if (globalClient != NULL && globalClient->status() == WS_CONNECTED) {
    String data = "{\"scale\":" + String(config.scale, 10) + ", \"offset\":" + String(config.offset) + "}";
    globalClient->text(data);
  }
}

void webSocketBroadcastData(dataStruct* data)
{
  if (globalClient != NULL && globalClient->status() == WS_CONNECTED) {
    String jsonObj = "{\"data\": [";
    jsonObj += "{\"time\":\"" + String(data->t) + "\", ";
    jsonObj += "\"raw\":\"" + String(data->v) + "\", ";
    jsonObj += "\"value\":\"" + String(config.lastValue) + "\"}";
    jsonObj += "]}";
    globalClient->text(jsonObj);
  }
}

void handleWSMessage(String& data)
{
  if (data.startsWith("offset:"))
  {
    String val = getValue(data, ':', 1);
    config.offset = val.toInt();
    Serial.print("Set offset: ");
    Serial.print(config.offset);
    Serial.println("");
    webSocketBroadcastScaleOffset();
  }
  else if (data.startsWith("scale:"))
  {
    String val = getValue(data, ':', 1);
    config.scale = val.toFloat();
    Serial.print("Set scale: ");
    Serial.print(config.scale, 10);
    Serial.println("");
    webSocketBroadcastScaleOffset();
  }
  else if (data.startsWith("time:"))
  {
    String val = getValue(data, ':', 1);
    config.time = atol(val.c_str()) - millis();
    Serial.print("Set time: ");
    Serial.print(config.time);
    Serial.println("");
  }
}

void onWsEvent(AsyncWebSocket * server, AsyncWebSocketClient * client, AwsEventType type, void * arg, uint8_t *data, size_t len) {
  if (type == WS_EVT_CONNECT)
  {
    //Serial.printf("ws[%s][%u] connect\n", server->url(), client->id());
    //client->printf("Hello Client %u :)", client->id());
    globalClient = client;
    client->ping();
  }
  else if (type == WS_EVT_DISCONNECT)
  {
    //Serial.printf("ws[%s][%u] disconnect\n", server->url(), client->id());
    globalClient = NULL;

  }
  //  else if(type == WS_EVT_ERROR){
  //    //Serial.printf("ws[%s][%u] error(%u): %s\n", server->url(), client->id(), *((uint16_t*)arg), (char*)data);
  //  }
  //  else if(type == WS_EVT_PONG){
  //    //Serial.printf("ws[%s][%u] pong[%u]: %s\n", server->url(), client->id(), len, (len)?(char*)data:"");
  //  }
  else if (type == WS_EVT_DATA) {
    AwsFrameInfo * info = (AwsFrameInfo*)arg;
    String msg = "";
    if (info->final && info->index == 0 && info->len == len)
    {
      if (info->opcode == WS_TEXT)
      {
        for (size_t i = 0; i < info->len; i++) {
          msg += (char) data[i];
        }
        handleWSMessage(msg);
      }
    }
  }
}


void onUpload(AsyncWebServerRequest * request, const String & filename, size_t index, uint8_t *data, size_t len, bool final) {
  if (!index) {
    String path = filename;
    if (!path.startsWith("/")) path = "/" + path;
    if (!path.endsWith(".gz")) {                         // The file server always prefers a compressed version of a file
      String pathWithGz = path + ".gz";                  // So if an uploaded file is not compressed, the existing compressed
      if (SPIFFS.exists(pathWithGz))                     // version of that file must be deleted (if it exists)
        SPIFFS.remove(pathWithGz);
    }
    Serial.println("Upload started: " + path);
    request->_tempFile = SPIFFS.open(path, "w");
  }

  if (request->_tempFile) {
    if (len) {
      request->_tempFile.write(data, len);
    }
    if (final) {
      Serial.println("Upload finished");
      request->_tempFile.close();
      //request->send(200, "text/plain", "File Uploaded !");
      request->redirect("/success.html");
    }
  }
  else
  {
    request->send(500, "text/plain", "500: couldn't create file");
  }
}


void handleGetData(AsyncWebServerRequest * request) {
  String jsonObj = "{\"data\": [";
  dataStruct data;
  bool first = true;
  while (dataBuffer.lockedPop(data))
  {
    if (first)
    {
      first = false;
    }
    else
    {
      jsonObj += ",";
    }
    float valueFloat = (data.v - config.offset) * config.scale;
    jsonObj += "{\"time\":\"" + String(data.t) + "\", ";
    jsonObj += "\"value\":\"" + String(valueFloat) + "\"}";
  }
  jsonObj += "]}";
  request->send(200, "text/plane", jsonObj);
}


void handleGetFile(AsyncWebServerRequest * request)
{
  String path(request->url());
  Serial.println("handleFileRead: " + path);

  if (path.endsWith("/"))
    path += "index.html";                                  // If a folder is requested, send the index file

  if (path.endsWith(configFilename))
    saveConfig(&config);                                  //save config before display it to user

  request->send(SPIFFS, path, String(), false, nullptr);
}

void handleConfigUpdate(AsyncWebServerRequest * request)
{
  for (int i = 0; i < request->args(); i++) {
    if (configJSON.containsKey(request->argName(i)))
    {
      configJSON[request->argName(i)] = request->arg(i);
    }
  }
  copyConfig(&config);
  saveConfig(&config);

  //Serve /configure.html
  request->send(SPIFFS, "/configure.html", String(), false, nullptr);
}


bool loggedIn = false;
void handleLoginPage(AsyncWebServerRequest * request)
{
  Serial.println("Login page");
  Serial.println(loggedIn);
  if (loggedIn == false)
  {
    if (request->method() == HTTP_POST)
    {
      request->send(200, "text/plain", "Logged in");
      //handleConfigUpdate();
      loggedIn = true;
    }
    else
    {
      //Serve configure
      //request->send(SPIFFS, "/configure.html", String(), false, nullptr);
      request->send(SPIFFS, "/login.html", String(), false, nullptr);
    }
  }
  else
  {
    request->send(204);
  }
}


void handleAbout(AsyncWebServerRequest * request)
{
  String response = "type:forcegauge\n";
  response += "name:" + String(config.name) + "\n";
  response += "version:" + String(version)  + "\n";
  request->send(200, "text/plane", response);
}
