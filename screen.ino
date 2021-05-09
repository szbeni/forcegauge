#include <Wire.h>
#include <Adafruit_GFX.h>
#include <Adafruit_SSD1306.h>

#define SCREEN_WIDTH 128 // OLED display width, in pixels
#define SCREEN_HEIGHT 64 // OLED display height, in pixels

#define OLED_RESET     -1 // Reset pin # (or -1 if sharing Arduino reset pin)
#define SCREEN_ADDRESS 0x3C ///< See datasheet for Address; 0x3D for 128x64, 0x3C for 128x32
Adafruit_SSD1306 display(SCREEN_WIDTH, SCREEN_HEIGHT, &Wire, OLED_RESET);

static bool screen_initialized = false;

void startScreen() {
  // SSD1306_SWITCHCAPVCC = generate display voltage from 3.3V internally
  if(!display.begin(SSD1306_SWITCHCAPVCC, SCREEN_ADDRESS)) {
    Serial.println(F("SSD1306 allocation failed"));
    screen_initialized = false;
    return;
  }
  screen_initialized = true;
  displayStartup();    // Draw 'stylized' characters
}

void displayStartup(void) {
  if(!screen_initialized) return;
  
  display.clearDisplay();
  display.setTextSize(1);             // Normal 1:1 pixel scale
  display.setTextColor(SSD1306_WHITE);        // Draw white text
  display.setCursor(0,16);             // Start at top-left corner
  display.println(config.name);
  display.println(version);

  
  display.display();
  delay(2000);

}

void screenUpdate()
{
    if(!screen_initialized) return;
    display.clearDisplay();
    display.setTextSize(3);
    display.setTextColor(SSD1306_WHITE);
    display.setCursor(10,10);
    display.println(config.lastValue);
    display.setTextSize(1);
    display.setCursor(10,50);
    display.print("Battery: ");
    int sensorValue = analogRead(BATTERY_VOLTAGE);
    float voltage = sensorValue * BATTERY_SCALER; //convert the value to a true voltage.
    display.print(voltage, 2);
    display.print("V");

    display.display();  
}

void displayShutdown()
{
    if(!screen_initialized) return;
    display.clearDisplay();
    display.setTextSize(1);
    display.setTextColor(SSD1306_WHITE);
    display.setCursor(10,10);
    display.println("Shutting down..");
    display.display();  
    screen_initialized = false;
}
