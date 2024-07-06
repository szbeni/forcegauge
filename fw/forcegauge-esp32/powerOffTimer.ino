static const float threshold = 1.0; // Change this to your desired threshold value
static const int numReadings = 50;   // Number of readings to calculate the average
static float readings[numReadings];  // Array to store sensor readings
static int readIndex = 0;            // Index of the current reading
static float total = 0;              // Sum of the readings
static float average = 0;            // Average of the readings
static unsigned long powerOffTimer = 0;
static unsigned long lastReportTime = 0;
void autoPowerOffInit(void)
{
  autoPowerOffReset();
  for (int i = 0; i < numReadings; i++)
  {
    readings[i] = 0;
  }
}

void autoPowerOffReset(void)
{
    powerOffTimer = millis();
}

void autoPowerOffLoop(void)
{
  if (config.autoPowerOffEnable == false)
  {
    autoPowerOffReset();
    return;
  }

  float currentValue = config.lastValue;
  // Subtract the last reading from the total
  total = total - readings[readIndex];
  readings[readIndex] = currentValue;
  total = total + readings[readIndex];
  // Update the readIndex and wrap around if necessary
  readIndex = (readIndex + 1) % numReadings;

  // Calculate the average
  average = total / numReadings;

  if (fabs(currentValue - average) > threshold)
  {
      autoPowerOffReset();
  }

  // Do not power off when bluetooth is connected
  if (deviceConnected )
  {
     autoPowerOffReset();
  }
  // Can switch off when Wifi is connected.. TODO check if websocket is open..
  // if( WiFi.SSID() != "")
  // {
  //   autoPowerOffReset();
  // }

  // 5 mins auto power off
  if (millis() - powerOffTimer > 300000)
  {
    //Serial.println("Auto Power off");
    digitalWrite(POWER_PIN, LOW); 
  }

  if (millis() - lastReportTime > 1000)
  {
    lastReportTime = millis();
    Serial.println("\nPoweroff timer:");
    Serial.println(powerOffTimer);
    Serial.println(millis() - powerOffTimer);
  }
}