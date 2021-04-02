void webSocketBroadcastScaleOffset()
{
  String data = "{\"scale\":" + String(config.scale, 10) + ", \"offset\":" + String(config.offset) + "}";
  webSocket.broadcastTXT(data);
}

void webSocketBroadcastData(dataStruct* data)
{
  String jsonObj = "{\"data\": [";
  config.lastValue = (data->v - config.offset) * config.scale;
  jsonObj += "{\"time\":\"" + String(data->t) + "\", ";
    jsonObj += "\"raw\":\"" + String(data->v) + "\", ";
  jsonObj += "\"value\":\"" + String(config.lastValue) + "\"}";
  jsonObj += "]}";
  webSocket.broadcastTXT(jsonObj);
}

void webSocketEvent(uint8_t num, WStype_t type, uint8_t * payload, size_t lenght) { // When a WebSocket message is received
  switch (type) {
    case WStype_DISCONNECTED:             // if the websocket is disconnected
      Serial.printf("[%u] Disconnected!\n", num);
      break;
    case WStype_CONNECTED: {              // if a new websocket connection is established
        IPAddress ip = webSocket.remoteIP(num);
        Serial.printf("[%u] Connected from %d.%d.%d.%d url: %s\n", num, ip[0], ip[1], ip[2], ip[3], payload);
        webSocketBroadcastScaleOffset();
      }
      break;
    case WStype_TEXT:                     // if new text data is received
      Serial.printf("[%u] get Text: %s\n", num, payload);

      String data = String((char*)payload);
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

      break;
  }
}

bool handleFileRead(String path) { // send the right file to the client (if it exists)
  Serial.println("handleFileRead: " + path);
  if (path.endsWith("/")) path += "index.html";          // If a folder is requested, send the index file
  if (server.uri().endsWith(configFilename)) saveConfig(&config); //save config before display it to user

  String contentType = getContentType(path);             // Get the MIME type
  String pathWithGz = path + ".gz";
  if (SPIFFS.exists(pathWithGz) || SPIFFS.exists(path)) { // If the file exists, either as a compressed archive, or normal
    if (SPIFFS.exists(pathWithGz))                         // If there's a compressed version available
      path += ".gz";                                         // Use the compressed verion
    File file = SPIFFS.open(path, "r");                    // Open the file
    size_t sent = server.streamFile(file, contentType);    // Send it to the client
    file.close();                                          // Close the file again
    Serial.println(String("\tSent file: ") + path);
    return true;
  }
  Serial.println(String("\tFile Not Found: ") + path);   // If the file doesn't exist, return false
  
  return false;
}

void handleFileUpload() { // upload a new file to the SPIFFS
  HTTPUpload& upload = server.upload();
  String path;
  if (upload.status == UPLOAD_FILE_START) {
    path = upload.filename;
    if (!path.startsWith("/")) path = "/" + path;
    if (!path.endsWith(".gz")) {                         // The file server always prefers a compressed version of a file
      String pathWithGz = path + ".gz";                  // So if an uploaded file is not compressed, the existing compressed
      if (SPIFFS.exists(pathWithGz))                     // version of that file must be deleted (if it exists)
        SPIFFS.remove(pathWithGz);
    }
    Serial.print("handleFileUpload Name: "); Serial.println(path);
    fsUploadFile = SPIFFS.open(path, "w");            // Open the file for writing in SPIFFS (create if it doesn't exist)
    path = String();
  } else if (upload.status == UPLOAD_FILE_WRITE) {
    if (fsUploadFile)
      fsUploadFile.write(upload.buf, upload.currentSize); // Write the received bytes to the file
  } else if (upload.status == UPLOAD_FILE_END) {
    if (fsUploadFile) {                                   // If the file was successfully created
      fsUploadFile.close();                               // Close the file again
      Serial.print("handleFileUpload Size: "); Serial.println(upload.totalSize);
      server.sendHeader("Location", "/success.html");     // Redirect the client to the success page
      server.send(303);
    } else {
      server.send(500, "text/plain", "500: couldn't create file");
    }
  }
}


void handleGetData() {
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
  server.send(200, "text/plane", jsonObj);
  yield();
}

void handleAbout()
{
  String response = "type:forcegauge\n";
  response += "name:" + String(config.name) + "\n";
  response += "version:" + String(version)  + "\n";
  server.send(200, "text/plane", response);
}
