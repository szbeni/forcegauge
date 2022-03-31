#pragma once

#define BUTTON1_PIN D4
#define BUTTON2_PIN D0
#define BUTTON3_PIN D3

#define R1 390.0f // 390k
#define R2 100.0f // 100k
#define BATTERY_SCALER (((R1 + R2) / R2) / 1023.0f)
#define BATTERY_VOLTAGE A0
#define BUZZER_PIN D8
#define POWER_PIN D7
#define DOUT D6
#define CLK D5

#define CONFIG_BUFFER_SIZE 1024

typedef struct
{
    const char *name;
    const char *APssid;
    const char *APpasswd;
    const char *ssid1;
    const char *passwd1;
    const char *ssid2;
    const char *passwd2;
    const char *ssid3;
    const char *passwd3;
    uint32_t offset;
    float scale;
    uint32_t time;
    float lastValue;
    float filterCoeff;

} configStruct;

typedef struct
{
    int32_t t;
    int32_t v;
} dataStruct;