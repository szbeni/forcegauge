
void webSocketBroadcastScaleOffset()
{
  if (ws.count())
  {
    String data = "{\"scale\":" + String(config.scale, 10) + ", \"offset\":" + String(config.offset) + "}";    
    ws.textAll(data);
  }
}

void webSocketBroadcastData(dataStruct* data)
{
  if (ws.count())
  {
    String jsonObj = "{\"data\": [";
    jsonObj += "{\"time\":\"" + String(data->t) + "\", ";
    jsonObj += "\"raw\":\"" + String(data->v) + "\", ";
    jsonObj += "\"value\":\"" + String(config.lastValue) + "\"}";
    jsonObj += "]}";
    ws.textAll(jsonObj);
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
    client->ping();
  }
  else if (type == WS_EVT_DISCONNECT)
  {
    //Serial.printf("ws[%s][%u] disconnect\n", server->url(), client->id());

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
