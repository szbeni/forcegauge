#define TABATA_MAX_NUM 20
#define TABATA_BUFFER_SIZE 512
DynamicJsonDocument tabataJSON(TABATA_BUFFER_SIZE);
char tabatas[TABATA_MAX_NUM][32] = {};
const char *tabatas_dir = "/tabatas";

int tabataCntr = 0;

bool workoutRunning = false;
Tabata *activeTabata;
Workout *activeWorkout;

bool loadTabataList()
{
    File root = SPIFFS.open(tabatas_dir);
    File file = root.openNextFile();
    if (!file)
        return false;

    Serial.println("Tabatas: ");
    while (file)
    {
        Serial.println(file.name());
        strncpy(tabatas[tabataCntr], file.name(), 32);
        tabataCntr++;
        if (tabataCntr >= TABATA_MAX_NUM)
            break;
        file = root.openNextFile();
    }
    return true;
}

bool openTabata(char *filename)
{
    String filenameFull = tabatas_dir;
    filenameFull += "/";
    filenameFull += filename;
    bool retval = false;
    if (SPIFFS.exists(filenameFull.c_str()))
    {
        File file = SPIFFS.open(filenameFull.c_str(), "r");
        DeserializationError error = deserializeJson(tabataJSON, file);
        if (error)
        {
            Serial.print(F("deserializeJson() failed: "));
            Serial.println(error.f_str());
        }
        else
        {
            retval = true;
        }
        file.close();
    }
    return retval;
}

void startTabata()
{
    loadTabataList();
}

void playWorkoutSound(Workout::WorkoutSound sound)
{
    if (sound == Workout::soundCountdownPip)
        buzz(600, 100);
    else if (sound == Workout::soundStartSet)
        buzz(1200, 400);
    else if (sound == Workout::soundStartRep)
        buzz(1200, 400);
    else if (sound == Workout::soundStartRest)
        buzz(500, 400);
    else if (sound == Workout::soundStartBreak)
        buzz(500, 400);
}

void startWorkout(char *filename)
{
    Serial.print("Start workout: ");
    Serial.println(filename);

    if (workoutRunning == true)
        return;
    if (openTabata(filename))
    {
        activeTabata = new Tabata(tabataJSON);
        activeWorkout = new Workout(*activeTabata);
        activeWorkout->registerOnSounds(playWorkoutSound);
        activeWorkout->start();
        workoutRunning = true;
    }
    else
    {
        Serial.print("Failed to open file:");
    }
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
        if (menuItem > tabataCntr)
            menuItem = 0;
    }
    if (lastPress == B3_SHORT)
    {
        if (menuItem > 0)
            startWorkout(tabatas[menuItem - 1]);
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

    for (int i = 0; i < tabataCntr; i++)
    {
        display.setCursor(5, 16 + i * 10);
        String s(tabatas[i]);
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
    display.setTextSize(1);
    display.setTextColor(SSD1306_WHITE);
    display.setCursor(20, 0);
    display.println("Workout");
    display.setCursor(15, 16);
    display.println(activeWorkout->stepName(activeWorkout->_step));

    display.setCursor(5, 26);
    display.println(activeWorkout->_timeLeft);

    display.setCursor(5, 46);
    display.print("set: ");
    display.println(activeWorkout->_set);

    display.setCursor(5, 56);
    display.print("rep: ");
    display.println(activeWorkout->_rep);
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