#define CHN 0

bool buzzing = false;
unsigned long buzzerStopTime = 0;
RingBuf<buzzStruct, 16> buzzBuffer;

void buzz(unsigned int freq, unsigned long duration)
{
  if (config.buzzerEnable)
  {
    buzzStruct b;
    b.freq = freq;
    b.duration = duration;
    buzzBuffer.lockedPush(b);
  }
}

void nextBuzz()
{
  if (buzzing)
    return;
  if (!buzzBuffer.isEmpty())
  {
    buzzStruct b;
    buzzBuffer.lockedPop(b);
    if (b.freq > 0)
    {
      ledcWriteTone(CHN, b.freq);
      ledcWrite(CHN, 127);
    }
    else
    {
      ledcWrite(CHN, 0);
    }
    buzzerStopTime = millis() + b.duration;
    buzzing = true;
  }
}

void startBuzzer()
{
  ledcAttachChannel(BUZZER_PIN, 2000, 8, CHN);
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
  nextBuzz();
}
