#include "forcegauge.h"

const char configFilename[] = "/config.json";
const char version[] = "1.0.0"; 

configStruct config;
HX711 scale(DOUT, CLK);
RingBuf<dataStruct, 64> dataBuffer;

IPAddress apIP(192, 168, 4, 1);
ESP8266WiFiMulti wifiMulti;       // Create an instance of the ESP8266WiFiMulti class, called 'wifiMulti'
ESP8266WebServer server(80);      //Server on port 80
WebSocketsServer webSocket(81);   // create a websocket server on port 81
File fsUploadFile;                  // a File variable to temporarily store the received file
DNSServer dnsServer;              //DNS server for captive portal


void setup() {
  Serial.begin(115200); // Start Serial
  startSPIFFS();
  startConfig();
  startWiFi();
  startOTA();
  startDNSServer();
  //startMDNS();
  startWebSocket();
  startServer();
  startHX711();
}

void loop() {
  ArduinoOTA.handle();
  webSocket.loop();                           // constantly check for websocket events
  server.handleClient();
  //MDNS.update();
  dnsServer.processNextRequest();
  
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
