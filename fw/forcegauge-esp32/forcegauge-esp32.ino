
#include "forcegauge.h"

configStruct config;
const char configFilename[] = "/config.json";
const char version[] = "1.0.0"; 

HX711 scale;
RingBuf<dataStruct, 64> dataBuffer;

ScreenHandler screenHandler;      //Screen hanlder
float maxForce=0;
float minForce=0;

TaskHandle_t anotherTaskHandle;


void setup() {
  delay(2000);
  Serial.begin(115200); // Start Serial
  config.filterCoeff = 0.5;
  config.scale = 1.0;
  config.offset = 0;
  
  
  if (!SPIFFS.begin(true)) {
    Serial.println("An Error has occurred while mounting SPIFFS");
    return;
  }
  File root = SPIFFS.open("/");
 
  File file = root.openNextFile();
 
  while(file){
 
      Serial.print("FILE: ");
      Serial.println(file.name());
 
      file = root.openNextFile();
  }
  
  startConfig();  
  int priority = (configMAX_PRIORITIES);
  //func| name | Stack in word | param | priority | handle
  xTaskCreate(anotherTask, "another Task", 5000, NULL, priority, &anotherTaskHandle); 

  startWiFi();
  startServer();
}

static unsigned long lastRefresh = millis();

void loop() {
  Serial.print("Main Loop: priority = ");
  Serial.println(uxTaskPriorityGet(NULL));
  
  Serial.print("ESP32 IP as soft AP: ");
  Serial.println(WiFi.softAPIP());
 
  Serial.print("ESP32 IP on the WiFi network: ");
  Serial.println(WiFi.localIP());
  
  delay(10000); 
}


void anotherTask( void   * parameter )
{
  
  startBuzzer();
  startButtons();
  startScreen();
  startHX711();
  Serial.print("Another Loop: priority = ");
  Serial.println(uxTaskPriorityGet(NULL));

  while(1)
  {
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
  //    if(wifiInitialized)
  //      webSocketBroadcastData(&data);
    }
    delay(2);
  }
  
  //Should never get here
  vTaskDelete( NULL );
}
 
