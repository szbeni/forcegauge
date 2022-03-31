#include "forcegauge.h"

const char configFilename[] = "/config.json";
const char version[] = "1.0.0"; 

configStruct config;
HX711 scale;
RingBuf<dataStruct, 64> dataBuffer;

IPAddress apIP(192, 168, 4, 1);
ESP8266WiFiMulti wifiMulti;       // Create an instance of the ESP8266WiFiMulti class, called 'wifiMulti'
ESP8266WebServer server(80);      //Server on port 80
WebSocketsServer webSocket(81);   // create a websocket server on port 81
File fsUploadFile;                  // a File variable to temporarily store the received file
DNSServer dnsServer;              //DNS server for captive portal
ScreenHandler screenHandler;      //Screen hanlder
float maxForce=0;
float minForce=0;


void setup() {
  Serial.begin(115200); // Start Serial
  startBuzzer();
  startButtons();
  startSPIFFS();
  startConfig();
  startScreen();
  startHX711();
  startWiFi();
}

bool wifiInitialized = false;
void WiFiLoop()
{
  if(wifiInitialized == false)
  {
    
      if (checkWifiConnected())
      {
        startOTA();
        startDNSServer();
        //startMDNS();
        startWebSocket();
        startServer();
        wifiInitialized = true;
      }
  }
  else
  {
    ArduinoOTA.handle();
    webSocket.loop();                           // constantly check for websocket events
    server.handleClient();
    //MDNS.update();
    dnsServer.processNextRequest();
  }
}

static float lowpassfilter(float new_input, float current, float coeff)
{
  return coeff * current + (1 - coeff) * new_input;
}


static unsigned long lastRefresh = millis();

void loop() {
  WiFiLoop();
  buzzerLoop();
  buttonsLoop();
  
  if(millis() - lastRefresh >= 50)
  {
    lastRefresh = millis();
    screenLoop();
  } 
    
  if (scale.is_ready())
  {
    dataStruct data;
    data.v = scale.read();
    data.t = config.time + millis();
    dataBuffer.lockedPush(data);
    float value = (data.v - config.offset) * config.scale;
    //Add simple filter
    config.lastValue = lowpassfilter(value, config.lastValue, config.filterCoeff);
    if (config.lastValue > maxForce)
      maxForce = config.lastValue;
    if (config.lastValue < minForce)
      minForce = config.lastValue;


    if(wifiInitialized)
      webSocketBroadcastData(&data);
  }
  yield();
}
