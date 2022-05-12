
#include "forcegauge.h"

configStruct config;
const char configFilename[] = "/config.json";
const char version[] = "1.0.0"; 

HX711 scale;
RingBuf<dataStruct, 64> dataBuffer;

ScreenHandler screenHandler;      //Screen hanlder
float maxForce=0;
float minForce=0;

TaskHandle_t wifiTaskHandle;



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
  int priority = 1;
  xTaskCreate(wifiTask, "wifiTask", 40000, NULL, priority, &wifiTaskHandle); 
}

static unsigned long lastRefresh = millis();

int32_t cntr = 0;
int spike_cntr = 0;
void loop() {
    buzzerLoop();
    buttonsLoop();
    if(millis() - lastRefresh >= 50)
    {
      lastRefresh = millis();
      screenLoop();
    } 
      
    //if (scale.is_ready())
    if(true)
    {
      dataStruct data;

//      noInterrupts();
//      data.v = scale.read();
//      interrupts();
      data.v = cntr+=100;
      if (cntr > 100000) 
        cntr = 0 ;
      
      data.t = config.time + millis();
      dataBuffer.lockedPush(data);
      float value = (data.v - config.offset) * config.scale;

      float diff = fabsf(value - config.lastValue);
      //Filter out sudden spikes in reading..
      if (diff > 100 && spike_cntr < 1) 
      {
        Serial.print("Spike filter: ");
        Serial.println(config.lastValue);
        Serial.println(value);
        spike_cntr++;
      }
      else
      {
        spike_cntr = 0;
        config.lastValue = lowpassfilter(value, config.lastValue, config.filterCoeff);
        if (config.lastValue > maxForce)
          maxForce = config.lastValue;
        if (config.lastValue < minForce)
          minForce = config.lastValue;
          //noInterrupts();
          //webSocketBroadcastData(&data);
          //interrupts();
      }
    }
    delay(12);
}



 
