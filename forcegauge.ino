#include "forcegauge.h"

configStruct config;
HX711 scale(DOUT, CLK);
RingBuf<dataStruct, 64> dataBuffer;

ESP8266WiFiMulti wifiMulti;       // Create an instance of the ESP8266WiFiMulti class, called 'wifiMulti'
ESP8266WebServer server(80);      //Server on port 80
WebSocketsServer webSocket(81);   // create a websocket server on port 81
File fsUploadFile;                  // a File variable to temporarily store the received file


void initConfig(configStruct* c)
{
  strcpy(c->mdnsName, "forcegauge ");
  strcpy(c->APssid, "ForceGauge");
  strcpy(c->APpasswd, "1234567890");
  strcpy(c->ssid1, "ABWifi");
  strcpy(c->passwd1, "Secret_12345");
  c->offset = 0;
  c->scale = 0.000231142;
  c->time = 0;
}

void setup() {
  initConfig(&config);
  Serial.begin(115200); // Start Serial
  startSPIFFS();
  startWiFi();
  startMDNS();
  startWebSocket();
  startServer();
  startHX711();
}

void loop() {
  webSocket.loop();                           // constantly check for websocket events
  server.handleClient();
  MDNS.update();
  if (scale.is_ready())
  {
    dataStruct data;
    data.v = scale.read();
    data.t = config.time + millis();
    dataBuffer.lockedPush(data);
    webSocketBroadcastData(&data);
  }
  yield();
}
