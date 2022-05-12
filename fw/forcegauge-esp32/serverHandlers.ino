//
//
//
//void onUpload(AsyncWebServerRequest * request, const String & filename, size_t index, uint8_t *data, size_t len, bool final) {
//  if (!index) {
//    String path = filename;
//    if (!path.startsWith("/")) path = "/" + path;
//    if (!path.endsWith(".gz")) {                         // The file server always prefers a compressed version of a file
//      String pathWithGz = path + ".gz";                  // So if an uploaded file is not compressed, the existing compressed
//      if (SPIFFS.exists(pathWithGz))                     // version of that file must be deleted (if it exists)
//        SPIFFS.remove(pathWithGz);
//    }
//    Serial.println("Upload started: " + path);
//    request->_tempFile = SPIFFS.open(path, "w");
//  }
//
//  if (request->_tempFile) {
//    if (len) {
//      request->_tempFile.write(data, len);
//    }
//    if (final) {
//      Serial.println("Upload finished");
//      request->_tempFile.close();
//      //request->send(200, "text/plain", "File Uploaded !");
//      request->redirect("/success.htm");
//    }
//  }
//  else
//  {
//    request->send(500, "text/plain", "500: couldn't create file");
//  }
//}
//
//
//void handleGetData(AsyncWebServerRequest * request) {
//  String jsonObj = "{\"data\": [";
//  dataStruct data;
//  bool first = true;
//  while (dataBuffer.lockedPop(data))
//  {
//    if (first)
//    {
//      first = false;
//    }
//    else
//    {
//      jsonObj += ",";
//    }
//    float valueFloat = (data.v - config.offset) * config.scale;
//    jsonObj += "{\"time\":\"" + String(data.t) + "\", ";
//    jsonObj += "\"value\":\"" + String(valueFloat) + "\"}";
//  }
//  jsonObj += "]}";
//  request->send(200, "text/plane", jsonObj);
//}
//
//
//void handleGetFile(AsyncWebServerRequest * request)
//{
//  String path(request->url());
//  Serial.println("handleFileRead: " + path);
//
//  if (path.endsWith("/"))
//    path += "index.htm";                                  // If a folder is requested, send the index file
//
//  if (path.endsWith(configFilename))
//    saveConfig(&config);                                  //save config before display it to user
//
//  request->send(SPIFFS, path, String(), false, nullptr);
//}
//
//void handleConfigUpdate(AsyncWebServerRequest * request)
//{
//  for (int i = 0; i < request->args(); i++) {
//    if (configJSON.containsKey(request->argName(i)))
//    {
//      configJSON[request->argName(i)] = request->arg(i);
//    }
//  }
//  copyConfig(&config);
//  saveConfig(&config);
//
//  //Serve /configure.htm
//  request->send(SPIFFS, "/configure.htm", String(), false, nullptr);
//}
//
//
//bool loggedIn = false;
//void handleLoginPage(AsyncWebServerRequest * request)
//{
//  Serial.println("Login page");
//  Serial.println(loggedIn);
//  if (loggedIn == false)
//  {
//    if (request->method() == HTTP_POST)
//    {
//      request->send(200, "text/plain", "Logged in");
//      //handleConfigUpdate();
//      loggedIn = true;
//    }
//    else
//    {
//      //Serve configure
//      //request->send(SPIFFS, "/configure.htm", String(), false, nullptr);
//      request->send(SPIFFS, "/login.htm", String(), false, nullptr);
//    }
//  }
//  else
//  {
//    request->send(204);
//  }
//}
//
//
//void handleAbout(AsyncWebServerRequest * request)
//{
//  String response = "type:forcegauge\n";
//  response += "name:" + String(config.name) + "\n";
//  response += "version:" + String(version)  + "\n";
//  request->send(200, "text/plane", response);
//}
