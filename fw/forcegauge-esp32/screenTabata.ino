

bool workoutRunning = false;
Tabata *activeTabata;
Workout *activeWorkout;

void startTabata()
{
    tabataHandler.begin();
}

void playWorkoutSound(Workout::WorkoutSound sound)
{
    if (sound == Workout::soundCountdownPip)
    {
        buzz(600, 100);
    }

    else if (sound == Workout::soundStartSet || sound == Workout::soundStartRep)
    {
        buzz(1200, 50);
        buzz(0, 50);
        buzz(1200, 50);
        buzz(0, 50);
        buzz(1200, 50);
    }
    else if (sound == Workout::soundStartRest || sound == Workout::soundStartBreak)
    {
        buzz(500, 30);
        buzz(0, 20);
        buzz(500, 30);
        buzz(0, 20);
        buzz(500, 30);
    }
}

void startWorkout(int tabataID)
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
    activeWorkout = new Workout(*activeTabata);
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
    static int menuItem = 0;
    bType lastPress = buttonHandler(menuItem == 0);

    if (lastPress == B2_SHORT)
    {
        menuItem++;
        if (menuItem > tabataHandler.getTabataCount())
            menuItem = 0;
    }
    if (lastPress == B3_SHORT)
    {
        if (menuItem > 0)
            startWorkout(menuItem - 1);
    }

    display.clearDisplay();
    if (menuItem > 0)
    {
        display.setCursor(0, 6 + menuItem * 10);
        display.print(">");
    }
    display.setTextSize(1);
    display.setTextColor(SSD1306_WHITE);
    display.setCursor(15, 0);
    display.println("Tabata");

    for (int i = 0; i < tabataHandler.getTabataCount(); i++)
    {
        display.setCursor(5, 16 + i * 10);
        String s(tabataHandler.getTabataName(i));
        s.replace(".json", "");
        display.println(s);
    }
    display.display();
}

void screenWorkout()
{
    // Run workout
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

boolean screenTabata()
{
    if (workoutRunning == false)
        screenTabataList();
    else
        screenWorkout();

    return true;
}