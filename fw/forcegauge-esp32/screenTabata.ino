

bool selectTargetForceScreen = false;
bool workoutRunning = false;
float setTargetForce = 0;
int selectedTabata = -1;
Tabata *activeTabata;
Workout *activeWorkout;

void startTabata()
{
    tabataHandler.begin();
}

void playWorkoutSound(Workout::WorkoutSound sound)
{
    Serial.print("Play sound: ");
    Serial.println(sound);

    if (sound == Workout::soundCountdownPip)
    {
        buzz(523, 100);
    }

    else if (sound == Workout::soundStartSet || sound == Workout::soundStartRep)
    {
        buzz(523, 10);
        buzz(0, 10);
        buzz(659, 10);
        buzz(0, 10);
        buzz(784, 10);
    }
    else if (sound == Workout::soundStartRest || sound == Workout::soundStartBreak)
    {
        buzz(784, 10);
        buzz(0, 10);
        buzz(659, 10);
        buzz(0, 10);
        buzz(523, 10);
    }
    else if (sound == Workout::soundEndWorkout)
    {
        buzz(1046, 20);
        buzz(0, 10);
        buzz(1318, 20);
        buzz(0, 10);
        buzz(1567, 20);
        buzz(0, 10);
        buzz(2093, 300);
        buzz(1567, 10);
        buzz(2093, 600);
    }
    else if (sound == Workout::soundTargetReached)
    {
        buzz(1046, 10);
        buzz(0, 10);
        buzz(1174, 10);
        buzz(0, 10);
        buzz(1318, 10);
    }
}

void startWorkout(int tabataID, float targetForce = 0)
{
    if (workoutRunning == true)
        return;

    JsonObject tabataObj = tabataHandler.getTabata(tabataID);
    if (!tabataObj)
    {
        Serial.print("Cannot open tabata witd id: ");
        Serial.println(tabataID);
    }

    activeTabata = new Tabata(tabataObj);
    activeWorkout = new Workout(*activeTabata, targetForce);
    activeWorkout->registerOnSounds(playWorkoutSound);
    activeWorkout->start();

    Serial.print("Starting workout: ");
    Serial.println(activeTabata->getName());

    workoutRunning = true;
}

void stopWorkout()
{
    if (workoutRunning)
    {
        workoutRunning = false;
        delete activeWorkout;
        delete activeTabata;
    }
}

void screenTabataList()
{
    int itemPerScreen = 5;
    static int menuItem = -1;
    bType lastPress = buttonHandler(menuItem == -1);

    if (lastPress == B2_SHORT)
    {
        menuItem++;
        if (menuItem >= tabataHandler.getTabataCount())
            menuItem = -1;
    }
    if (lastPress == B3_SHORT)
    {
        if (menuItem >= 0)
        {
            // Change to set target force screen
            selectedTabata = menuItem;
            selectTargetForceScreen = true;
        }
    }

    display.clearDisplay();
    if (menuItem >= 0)
    {
        display.setCursor(0, 16 + (menuItem % itemPerScreen) * 10);
        display.print(">");
    }
    display.setTextSize(1);
    display.setTextColor(SSD1306_WHITE);
    display.setCursor(15, 0);
    display.println("Tabata");

    int firstItemOnScreen = (menuItem / itemPerScreen) * itemPerScreen;
    for (int i = firstItemOnScreen; i < tabataHandler.getTabataCount(); i++)
    {
        // Only display itemPerScreen number of items
        if (i >= firstItemOnScreen + itemPerScreen)
            break;

        display.setCursor(5, 16 + (i % itemPerScreen) * 10);
        String s(tabataHandler.getTabataName(i));
        display.println(s);
    }
    display.display();
}

void screenWorkout()
{
    // Run workout
    activeWorkout->newForceValue(config.lastValue);

    static unsigned long lastTargetForceWarning = millis();

    if ((millis() - lastTargetForceWarning) > 20)
    {
        if (setTargetForce > 0)
        {
            if (activeWorkout->_step == Workout::stateExercising)
            {
                if (fabsf(config.lastValue) < setTargetForce)
                {
                    buzz(440.00, 10);
                }
            }
        }
    }

    static unsigned long lastTickTime = millis();
    if ((millis() - lastTickTime) > 1000)
    {
        lastTickTime = millis();
        activeWorkout->tick();
    }

    if (activeWorkout->isFinished())
    {
        stopWorkout();
        return;
    }

    bType lastPress = buttonHandler(false);
    if (lastPress == B1_LONG || lastPress == B1_HOLD)
    {
        stopWorkout();
        return;
    }
    else if (lastPress == B1_SHORT)
    {
        activeWorkout->previous();
    }
    else if (lastPress == B2_SHORT)
    {
        if (activeWorkout->isStarted())
        {
            activeWorkout->pause();
        }
        else
        {
            activeWorkout->start();
        }
    }
    else if (lastPress == B3_SHORT)
    {
        activeWorkout->next();
    }

    display.clearDisplay();
    display.setTextColor(SSD1306_WHITE);
    display.setTextSize(2);
    display.setCursor(10, 1);
    display.println(config.lastValue);

    display.setTextSize(1);
    display.setCursor(20, 17);
    display.println(activeWorkout->stepName(activeWorkout->_step));

    display.setTextSize(2);
    display.setCursor(5, 27);
    display.println(activeWorkout->_timeLeft);

    display.setTextSize(1);
    display.setCursor(5, 47);
    display.print("set: ");
    display.print(activeWorkout->_set);
    display.print(" rep: ");
    display.println(activeWorkout->_rep);

    display.setCursor(5, 57);
    display.print("time left: ");
    display.println(activeWorkout->getTimeRemaining());
    display.display();
}

void screenTargetForce()
{

    static int menuItem = 0;
    bType lastPress = buttonHandler(false);

    if (lastPress == B1_SHORT)
    {
        setTargetForce -= 0.5;
    }
    else if (lastPress == B2_SHORT)
    {
        startWorkout(selectedTabata, setTargetForce);
        selectTargetForceScreen = false;
    }
    else if (lastPress == B3_SHORT)
    {
        setTargetForce += 0.5;
    }
    if (setTargetForce < 0)
        setTargetForce = 0;
    else if (setTargetForce > 500)
        setTargetForce = 500;

    display.clearDisplay();
    display.setTextColor(SSD1306_WHITE);
    display.setTextSize(1);
    display.setCursor(20, 10);
    display.print("Set target force");
    display.setTextSize(2);
    display.setCursor(20, 26);
    display.println(setTargetForce);
    display.display();
}

boolean screenTabata()
{
    if (workoutRunning == false)
    {
        if (selectTargetForceScreen == false)
            screenTabataList();
        else
            screenTargetForce();
    }
    else
        screenWorkout();

    return true;
}