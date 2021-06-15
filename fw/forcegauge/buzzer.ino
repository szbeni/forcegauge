
unsigned long buzzerStopTime = 0;

void buzz(unsigned int freq, unsigned long duration)
{
  tone(BUZZER_PIN, freq);
  buzzerStopTime = millis() + duration;
}

void startBuzzer()
{
    digitalWrite(BUZZER_PIN, HIGH);

}
void buzzerLoop()
{
  if(millis() >= buzzerStopTime)
  {
    digitalWrite(BUZZER_PIN, HIGH);
  }  
}
