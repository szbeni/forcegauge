
#define SHORT_PRESS_TIME 50
#define LONG_PRESS_TIME 300
#define HOLD_TIME 1500

int lastSent = 0;
int currentState[3] = {LOW, LOW, LOW};
int lastState[3] = {LOW, LOW, LOW};
bool holdStateOn[3] = {false, false, false};
unsigned long pressedTime[3] = {0, 0, 0};
unsigned long releasedTime[3] = {0, 0, 0};

bType lastPressGlobal = NONE;

enum bType getLastPress()
{
  bType press = lastPressGlobal;
  lastPressGlobal = NONE;
  return press;
}

void startButtons()
{
  pinMode(BUTTON1_PIN, INPUT_PULLUP);
  pinMode(BUTTON2_PIN, INPUT_PULLUP);
  pinMode(BUTTON3_PIN, INPUT_PULLUP);

  pinMode(POWER_PIN, OUTPUT);
  digitalWrite(POWER_PIN, HIGH);
}

void buttonsLoop()
{

  // read the state of the switch/button:
  currentState[0] = !digitalRead(BUTTON1_PIN);
  currentState[1] = !digitalRead(BUTTON2_PIN);
  currentState[2] = !digitalRead(BUTTON3_PIN);

  if (millis() - lastSent > 200)
  {
    lastSent = millis();
    // Serial.printf("Button %d, %d, %d\n", currentState[0],currentState[1],currentState[2]);
  }

  for (int i = 0; i < 3; i++)
  {

    int pressedState = HIGH;
    int releasedState = LOW;

    if (lastState[i] == releasedState && currentState[i] == pressedState)
    {
      autoPowerOffReset();
      pressedTime[i] = millis();
    }
    else if (lastState[i] == pressedState && currentState[i] == releasedState)
    {
      releasedTime[i] = millis();
      holdStateOn[i] = false;
      long pressDuration = releasedTime[i] - pressedTime[i];
      if (pressDuration > LONG_PRESS_TIME && pressDuration < HOLD_TIME)
      {
        // screenHandler.buttonLongPress(i);
        if (i == 0)
          lastPressGlobal = B1_LONG;
        else if (i == 1)
          lastPressGlobal = B2_LONG;
        else if (i == 2)
          lastPressGlobal = B3_LONG;

        Serial.printf("Button %d long press\n", i);
        buzz(3000, 200);
      }
      else if (pressDuration > SHORT_PRESS_TIME && pressDuration < HOLD_TIME)
      {
        if (i == 0)
          lastPressGlobal = B1_SHORT;
        else if (i == 1)
          lastPressGlobal = B2_SHORT;
        else if (i == 2)
          lastPressGlobal = B3_SHORT;
        // screenHandler.buttonShortPress(i);
        Serial.printf("Button %d short press\n", i);
        buzz(4000, 100);
      }
      else if (pressDuration > HOLD_TIME)
      {
        Serial.printf("Button %d hold release\n", i);
        buzz(1000, 100);
        // screenHandler.buttonHoldOff(i);
      }
      else
      {
        // debounce
      }
    }
    else if (lastState[i] == pressedState && currentState[i] == pressedState)
    {
      if ((millis() - pressedTime[i]) > HOLD_TIME)
      {
        if (i == 0)
          lastPressGlobal = B1_HOLD;
        else if (i == 1)
          lastPressGlobal = B2_HOLD;
        else if (i == 2)
          lastPressGlobal = B3_HOLD;

        if (holdStateOn[i] == false)
        {
          // screenHandler.buttonHoldOn(i);
          holdStateOn[i] = true;
          buzz(2000, 500);
          Serial.printf("Hold Start\n");

          if (i == 1)
          {
            Serial.printf("Power off\n");
            digitalWrite(POWER_PIN, LOW);
            // displayShutdown();
          }
        }
      }
    }

    lastState[i] = currentState[i];
  }
}
