
#include "forcegauge.h"

configStruct config;
const char configFilename[] = "/config.json";
const char version[] = "1.0.0";

HX711 scale;
RingBuf<dataStruct, 64> dataBuffer;

ScreenHandler screenHandler;      //Screen hanlder
float maxForce = 0;
float minForce = 0;

TaskHandle_t wifiTaskHandle;
TaskHandle_t httpServerTaskHandle;
TaskHandle_t websocketServerTaskHandle;


void setup() {
  Serial.begin(115200); // Start Serial
  startBuzzer();
  startButtons();
  startConfig();
  startScreen();
  startHX711();

  //int priority = (configMAX_PRIORITIES - 1);
  //Increase our priority
  vTaskPrioritySet( NULL, (configMAX_PRIORITIES - 1) );
  
  //func| name | Stack in word | param | priority | handle
  startWifi();
  xTaskCreate(wifiTask, "wifiTask", 10000, NULL, tskIDLE_PRIORITY + 1, &wifiTaskHandle);
  xTaskCreate(httpServerTask, "httpServerTask", 100000, NULL, tskIDLE_PRIORITY + 1, &httpServerTaskHandle);
  xTaskCreate(websocketServerTask, "websocketServerTask", 10000, NULL, configMAX_PRIORITIES - 1, &websocketServerTaskHandle);

}

static unsigned long lastRefresh = millis();

void loop() {
  static int spike_cntr = 0;

  buzzerLoop();
  buttonsLoop();
  if (millis() - lastRefresh >= 50)
  {
    lastRefresh = millis();
    screenLoop();
  }
  
  // static int32_t cntr = 0;
  // if (true)
  if (scale.is_ready())
  {
    dataStruct data;

    noInterrupts();
    data.v = scale.read();
    interrupts();
   
//    data.v = cntr;
//    cntr += 20;
//    if (cntr > 100000)
//      cntr = 0 ;
    
    data.t = config.time + millis();
    float value = (data.v - config.offset) * config.scale;

    float diff = fabsf(value - config.lastValue);
    //Filter out sudden spikes in reading, max 5 times in a row
    if (diff > 30 && spike_cntr < 5)
    {
      Serial.print("Spike filter: ");
      Serial.print(config.lastValue);
      Serial.print(" ");
      Serial.println(value);
      spike_cntr++;
    }
    else
    {
      config.lastRawValue = data.v;
      dataBuffer.lockedPush(data);
      spike_cntr = 0;
      config.lastValue = lowpassfilter(value, config.lastValue, config.filterCoeff);
      if (config.lastValue > maxForce)
        maxForce = config.lastValue;
      if (config.lastValue < minForce)
        minForce = config.lastValue;
    }
  }
  delay(2);
}
