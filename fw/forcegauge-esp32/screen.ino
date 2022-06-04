#include <Wire.h>
#include <Adafruit_GFX.h>
#include <Adafruit_SSD1306.h>

#define SCREEN_WIDTH 128 // OLED display width, in pixels
#define SCREEN_HEIGHT 64 // OLED display height, in pixels

#define OLED_RESET -1       // Reset pin # (or -1 if sharing Arduino reset pin)
#define SCREEN_ADDRESS 0x3C ///< See datasheet for Address; 0x3D for 128x64, 0x3C for 128x32

Adafruit_SSD1306 display(SCREEN_WIDTH, SCREEN_HEIGHT, &Wire, OLED_RESET);

boolean screenInit();
boolean screenForce();
boolean screenTabata();
boolean screenSettings();
boolean screenShutdown();
boolean screenWifi();

ScreenItem screenItemShutdown = {"Shutdown", screenShutdown};

ScreenItem screenItems[] = {
    {"Force", screenForce},
    {"Tabata", screenTabata},
    {"Settings", screenSettings},
    {"WiFi", screenWifi},

};

ScreenList screenList(screenItems, 4);

void startScreen()
{
  Wire.begin(18, 19);
  if (!display.begin(SSD1306_SWITCHCAPVCC, SCREEN_ADDRESS, true, false))
  {
    Serial.println(F("SSD1306 allocation failed"));
    return;
  }
  display.display();
  screenHandler.init(&screenList);
}

void screenLoop()
{
  screenHandler.loop();
}

bType buttonHandler(bool defaultActions = true)
{
  bType lastPress = getLastPress();
  if (defaultActions)
  {
    if (lastPress == B1_SHORT)
      screenHandler.prevScreen();
    else if (lastPress == B3_SHORT)
      screenHandler.nextScreen();
  }
  return lastPress;
}

boolean screenInit()
{
  display.clearDisplay();
  display.setTextSize(1);              // Normal 1:1 pixel scale
  display.setTextColor(SSD1306_WHITE); // Draw white text
  display.setCursor(0, 16);            // Start at top-left corner
  display.println("Force gauge");
  display.display();
  return true;
}

boolean screenForce()
{
  bType lastPress = buttonHandler();

  if (lastPress == B1_LONG || lastPress == B1_HOLD)
  {
    Serial.println("Reset offset");
    config.offset = config.lastRawValue;
  }
  else if (lastPress == B2_SHORT)
  {
    maxForce = 0;
    minForce = 0;
  }

  display.clearDisplay();

  display.setTextSize(2);
  display.setTextColor(SSD1306_WHITE);
  display.setCursor(1, 1);
  display.println(config.lastValue);

  display.setTextSize(1);
  display.setCursor(1, 36);
  display.print("Min: ");
  display.print(minForce, 2);
  display.setCursor(1, 46);
  display.print("Max: ");
  display.print(maxForce, 2);

  display.setCursor(1, 56);
  display.print("Battery: ");
  int sensorValue = analogRead(BATTERY_VOLTAGE);
  float voltage = sensorValue * BATTERY_SCALER; // convert the value to a true voltage.
  display.print(voltage, 2);
  display.print("V");
  display.display();
  return true;
}

boolean screenSettings()
{
  static int menuItem = 0;
  bType lastPress = buttonHandler(menuItem == 0);

  if (lastPress == B2_SHORT)
  {
    menuItem++;
    if (menuItem > 3)
      menuItem = 0;
  }

  if (menuItem == 1)
  {
    if (lastPress == B1_SHORT)
    {
      config.buzzerEnable = false;
      saveConfig(&config);
    }
    else if (lastPress == B3_SHORT)
    {
      config.buzzerEnable = true;
      saveConfig(&config);
    }
  }

  if (menuItem == 2)
  {
    if (lastPress == B1_SHORT)
    {
      config.wifiAPEnable = false;
      saveConfig(&config);
    }
    else if (lastPress == B3_SHORT)
    {
      config.wifiAPEnable = true;
      saveConfig(&config);
    }
  }

  if (menuItem == 3)
  {
    if (lastPress == B1_SHORT)
    {
      config.bluetoothEnable = false;
    }
    else if (lastPress == B3_SHORT)
    {
      config.bluetoothEnable = true;
      saveConfig(&config);
    }
  }

  display.clearDisplay();
  if (menuItem > 0)
  {
    display.setCursor(0, 6 + menuItem * 10);
    display.print(">");
  }
  display.setTextSize(1);
  display.setTextColor(SSD1306_WHITE);
  display.setCursor(10, 0);
  display.println("Settings");
  display.setCursor(5, 16);
  display.print("Buzzer: ");
  display.println(config.buzzerEnable ? "X" : "O");
  display.setCursor(5, 26);
  display.print("Wifi Ap: ");
  display.println(config.wifiAPEnable ? "X" : "O");
  display.setCursor(5, 36);
  display.print("Bluetooth: ");
  display.println(config.bluetoothEnable ? "X" : "O");
  display.display();
  return true;
}

boolean screenWifi()
{
  static int menuItem = 0;
  bType lastPress = buttonHandler(menuItem == 0);

  if (lastPress == B2_SHORT)
  {
    menuItem++;
    if (menuItem > 1)
      menuItem = 0;
  }

  if (menuItem == 1)
  {
    if (lastPress == B1_SHORT)
    {
      WiFi.disconnect(false, true);
    }
    else if (lastPress == B3_SHORT)
    {
      WiFi.disconnect(false, true);
    }
  }

  display.clearDisplay();
  if (menuItem > 0)
  {
    display.setCursor(0, 46 + (menuItem - 1) * 10);
    display.print(">");
  }
  display.setTextSize(1);
  display.setTextColor(SSD1306_WHITE);
  display.setCursor(10, 0);
  display.println("WiFi Info");

  display.setTextSize(1);
  display.setCursor(5, 16);
  display.print(config.APssid);
  display.print(" (");
  display.print(WiFi.softAPgetStationNum());
  display.print(")");
  display.setCursor(0, 26);
  display.print(WiFi.softAPIP());

  display.setCursor(5, 46);
  display.print("");
  display.print(WiFi.SSID());
  display.setCursor(0, 56);
  display.print("");
  display.print(WiFi.localIP());
  display.display();

  return true;
}

boolean screenShutdown()
{
  display.clearDisplay();
  display.setTextSize(1);
  display.setTextColor(SSD1306_WHITE);
  display.setCursor(10, 10);
  display.println("Shutting down..");
  display.display();
  return true;
}

void screenTask(void *parameter)
{
  Serial.print("screenTask: priority = ");
  Serial.println(uxTaskPriorityGet(NULL));

  Serial.println("Screen Task Started");
  unsigned long lastRefresh = millis();
  while (1)
  {
    buzzerLoop();
    buttonsLoop();
    if (millis() - lastRefresh >= 50)
    {
      lastRefresh = millis();
      screenLoop();
    }
    delay(50);
  }

  // Should never get here
  vTaskDelete(NULL);
}
