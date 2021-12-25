#include "screen_handler.h"
#include <Wire.h>
#include <Adafruit_GFX.h>
#include <Adafruit_SSD1306.h>

#define SCREEN_WIDTH 128 // OLED display width, in pixels
#define SCREEN_HEIGHT 64 // OLED display height, in pixels

#define OLED_RESET     -1 // Reset pin # (or -1 if sharing Arduino reset pin)
#define SCREEN_ADDRESS 0x3C ///< See datasheet for Address; 0x3D for 128x64, 0x3C for 128x32

Adafruit_SSD1306 display(SCREEN_WIDTH, SCREEN_HEIGHT, &Wire, OLED_RESET);

boolean screenInit();
boolean screenForce();
boolean screenTabata();
boolean screenSettings();
boolean screenShutdown();

ScreenItem screenItemShutdown = { "Shutdown", screenShutdown };

ScreenItem screenItems[] = {   
  { "Force", screenForce },
  { "Tabata", screenTabata },
  { "Settings", screenSettings },
};

ScreenList screenList(screenItems, 3);


void startScreen()
{
  if(!display.begin(SSD1306_SWITCHCAPVCC, SCREEN_ADDRESS)) 
  {
    Serial.println(F("SSD1306 allocation failed"));
    return;
  }
  screenInit();
  screenHandler.init(&screenList);
}

void screenLoop()
{
  screenHandler.loop();
  
}

boolean screenInit(){
  display.clearDisplay();
  display.setTextSize(1);             // Normal 1:1 pixel scale
  display.setTextColor(SSD1306_WHITE);        // Draw white text
  display.setCursor(0,16);             // Start at top-left corner
  display.println("Force gauge");
  display.display();
}


boolean screenForce() {
  
  display.clearDisplay();
  
  display.setTextSize(2);
  display.setTextColor(SSD1306_WHITE);
  display.setCursor(1,1);
  display.println(config.lastValue);
  
  display.setTextSize(1);
  display.setCursor(1,36);
  display.print("Min: ");
  display.print(minForce, 2);
  display.setCursor(1,46);
  display.print("Max: ");
  display.print(maxForce, 2);

  display.setCursor(1,56);
  display.print("Battery: ");
  int sensorValue = analogRead(BATTERY_VOLTAGE);
  float voltage = sensorValue * BATTERY_SCALER; //convert the value to a true voltage.
  display.print(voltage, 2);
  display.print("V");
  display.display();  
  return true;
}

boolean screenTabata() {
  
  
  display.clearDisplay();
  display.setTextSize(1);
  display.setTextColor(SSD1306_WHITE);
  display.setCursor(10,0);
  display.println("Tabata");
  display.display();  
  return true;
}

boolean screenSettings() {
  display.clearDisplay();
  display.setTextSize(1);
  display.setTextColor(SSD1306_WHITE);
  display.setCursor(10,0);
  display.println("Settings");
  display.display();  
  return true;
}

boolean screenShutdown()
{
  display.clearDisplay();
  display.setTextSize(1);
  display.setTextColor(SSD1306_WHITE);
  display.setCursor(10,10);
  display.println("Shutting down..");
  display.display();  
}
