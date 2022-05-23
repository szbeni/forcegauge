WebSocketsServer webSocket(81);

void webSocketEvent(uint8_t num, WStype_t type, uint8_t *payload, size_t length)
{
  String msg = "";
  switch (type)
  {
  case WStype_DISCONNECTED:
    DBG_OUTPUT_PORT.printf("[%u] Disconnected!\n", num);
    break;
  case WStype_CONNECTED:
  {
    IPAddress ip = webSocket.remoteIP(num);
    DBG_OUTPUT_PORT.printf("[%u] Connected from %d.%d.%d.%d url: %s\n", num, ip[0], ip[1], ip[2], ip[3], payload);

    // send message to client
    // webSocket.sendTXT(num, "Connected");
  }
  break;
  case WStype_TEXT:
    // DBG_OUTPUT_PORT.printf("[%u] get Text: %s\n", num, payload);
    for (size_t i = 0; i < length; i++)
    {
      msg += (char)payload[i];
    }
    handleWSMessage(msg);
    // send message to client
    // webSocket.sendTXT(num, "message here");

    // send data to all connected clients
    // webSocket.broadcastTXT("message here");
    break;
  case WStype_BIN:
    DBG_OUTPUT_PORT.printf("[%u] get binary length: %u\n", num, length);
    // hexdump(payload, length);

    // send message to client
    // webSocket.sendBIN(num, payload, length);
    break;
  case WStype_ERROR:
  case WStype_FRAGMENT_TEXT_START:
  case WStype_FRAGMENT_BIN_START:
  case WStype_FRAGMENT:
  case WStype_FRAGMENT_FIN:
    break;
  }
}

void webSocketBroadcastScaleOffset()
{
  // No connected clients
  if (webSocket.connectedClients() == 0)
    return;
  String data = "{\"scale\":" + String(config.scale, 10) + ", \"offset\":" + String(config.offset) + "}";
  webSocket.broadcastTXT(data);
}

void webSocketBroadcastData()
{
  // Nothing to send
  if (websocketBuffer.isEmpty())
    return;
  // No connected clients
  if (webSocket.connectedClients() == 0)
    return;

  String jsonObj = "{\"data\": [";
  dataStruct data;
  bool first = true;
  while (websocketBuffer.lockedPop(data))
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
    jsonObj += "\"raw\":\"" + String(data.v) + "\", ";
    jsonObj += "\"value\":\"" + String(valueFloat) + "\"}";
  }
  jsonObj += "]}";

  webSocket.broadcastTXT(jsonObj);
}

void handleWSMessage(String &data)
{
  // Serial.print("New WS message: ");
  // Serial.println(data);

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
  else if (data.startsWith("add_tabata:"))
  {
    data.replace("add_tabata:", "");
    tabataHandler.addTabata(data);
  }
  else if (data.startsWith("del_tabata:"))
  {
    String val = getValue(data, ':', 1);
    tabataHandler.removeTabata(val.toInt());
  }
}

void websocketServerTask(void *parameter)
{
  Serial.print("websocketServerTask: priority = ");
  Serial.println(uxTaskPriorityGet(NULL));

  webSocket.begin();
  webSocket.onEvent(webSocketEvent);

  DBG_OUTPUT_PORT.println("Websocket server started");

  while (1)
  {
    webSocket.loop();
    webSocketBroadcastData();
    delay(10);
  }

  // Should never get here
  vTaskDelete(NULL);
}
