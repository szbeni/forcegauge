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

static float batteryVoltage = 4.1;
const static float battery_min = 3.0;
const static float battery_max = 4.15;

float readBatteryVoltage()
{
  int sensorValue = analogRead(BATTERY_VOLTAGE);
  batteryVoltage = sensorValue * BATTERY_SCALER; // convert the value to a true voltage.
  return batteryVoltage;
}

int round5(int n)
{
  return (n / 5 + (n % 5 > 2)) * 5;
}

static float getBatteryPercentage(float voltage)
{
  int percent = ((voltage - battery_min) / (battery_max - battery_min)) * 100.0;
  if (percent < 0.0f)
    percent = 0.0f;
  else if (percent > 100.0f)
    percent = 100.0f;
  config.lastBatteryPercent = (float)(round5(percent));
  return config.lastBatteryPercent;
}

void drawBattery(int x = 114, int y = 1, float percent = -1.0f)
{
  if (percent < 0.0f)
    percent = getBatteryPercentage(batteryVoltage);
  else if (percent > 100.0f)
    percent = getBatteryPercentage(batteryVoltage);
  

  int width = 12;
  int height = 7;
  int width_fill = (percent / 100.0) * width;
  display.drawRect(x, y, width, height, WHITE);
  display.fillRect(x, y, width_fill, height, WHITE);
  display.drawPixel(x + width + 1, y + 2, WHITE);
  display.drawPixel(x + width + 1, y + 3, WHITE);
  display.drawPixel(x + width + 1, y + 4, WHITE);
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
  drawBattery();
  display.setTextSize(3);
  display.setTextColor(SSD1306_WHITE);
  display.setCursor(1, 21);
  float val = config.lastValue;
  if (val >= 0.0f)
    display.print(" ");
  float absval = fabs(val);
  int round = 2;
  if (fabs(val) >= 1000.0f)
  {
    round = 1;
    if (fabs(val) >= 10000.0f)
      round = 0;
  }
  display.print(val, round);

  display.setTextSize(1);
  display.setCursor(1, 56);
  display.print("Min:");
  display.print(minForce, 1);
  display.setCursor(70, 56);
  display.print("Max:");
  display.print(maxForce, 1);
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
    if (menuItem > 4)
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
      config.smartConfigEnable = false;
      saveConfig(&config);
    }
    else if (lastPress == B3_SHORT)
    {
      config.smartConfigEnable = true;
      saveConfig(&config);
    }
  }

  if (menuItem == 4)
  {
    if (lastPress == B1_SHORT)
    {
      config.bluetoothEnable -= 1;
      if (config.bluetoothEnable < 0)
        config.bluetoothEnable = 2;
      saveConfig(&config);
    }
    else if (lastPress == B3_SHORT)
    {
      config.bluetoothEnable +=1;
      if (config.bluetoothEnable > 2)
        config.bluetoothEnable = 2;

      saveConfig(&config);
    }
  }

  display.clearDisplay();
  drawBattery();
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
  display.print("Smart Config: ");
  display.println(config.smartConfigEnable ? "X" : "O");
  display.setCursor(5, 46);
  display.print("Bluetooth: ");
  if (config.bluetoothEnable == 0)
    display.println("Off");
  else if (config.bluetoothEnable == 1)
    display.println("Tindeq");
  else if (config.bluetoothEnable == 2)
    display.println("Climbro");
  else
    display.println("Unknown");
  
  
  


  display.setCursor(5, 56);
  display.print("FW Version: ");
  display.println(version);

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
    if (menuItem > 2)
      menuItem = 0;
  }

  if (menuItem == 1)
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

  if (menuItem == 2)
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
  drawBattery();
  if (menuItem > 0)
  {
    display.setCursor(0, 16 + (menuItem - 1) * 20);
    display.print(">");
  }
  display.setTextSize(1);
  display.setTextColor(SSD1306_WHITE);
  display.setCursor(10, 0);
  display.println("WiFi Info");

  display.setTextSize(1);

  display.setCursor(5, 16);
  if (config.wifiAPEnable)
  {

    display.print(config.APssid);
    display.print(" (");
    display.print(WiFi.softAPgetStationNum());
    display.print(")");
    display.setCursor(0, 26);
    display.print(WiFi.softAPIP());
  }
  else
  {
    display.print("WiFi Hotspot Off");
  }

  display.setCursor(5, 36);
  if (WiFi.SSID() != "")
  {
    display.print(WiFi.SSID());
    display.setCursor(0, 56);
    display.print(WiFi.localIP());
  }
  else
  {
    display.print("WiFi not connected");
  }
  display.display();

  return true;
}

boolean screenShutdown()
{
  display.clearDisplay();
  drawBattery();
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
  unsigned long lastBatteryRead = 0;
  while (1)
  {
    buzzerLoop();
    buttonsLoop();
    if (millis() - lastRefresh >= 50)
    {
      lastRefresh = millis();
      screenLoop();
    }
    if (millis() - lastBatteryRead >= 1000)
    {
      lastBatteryRead = millis();
      readBatteryVoltage();
      // Testing indicator
      // batteryVoltage -= 0.05;
      // if (batteryVoltage < 3.0)
      //   batteryVoltage = 4.2;
    }
    delay(50);
  }

  // Should never get here
  vTaskDelete(NULL);
}
