#define CHN 0
unsigned long buzzerStopTime = 0;
bool buzzing = 0;

void buzz(unsigned int freq, unsigned long duration)
{
  Serial.println("buzz");
  if (config.buzzerEnable)
  {
    ledcWriteTone(CHN, freq);
    ledcWrite(CHN, 127);
  }

  buzzerStopTime = millis() + duration;
  buzzing = 1;
}

void startBuzzer()
{
  ledcSetup(CHN, 2000, 8);
  ledcAttachPin(BUZZER_PIN, CHN);
  ledcWrite(CHN, 0);
}

void buzzerLoop()
{
  if (buzzing)
  {
    if (millis() >= buzzerStopTime)
    {
      Serial.println("buzz stop");
      buzzing = 0;
      ledcWrite(CHN, 0);
    }
  }
}
