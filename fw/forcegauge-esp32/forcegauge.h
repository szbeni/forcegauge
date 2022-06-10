#pragma once

#include <WiFi.h>
#include <WiFiClient.h>
#include <WebServer.h>
#include <ESPmDNS.h>
#include <WebSockets.h>
#include <WebSocketsServer.h>
#include <Update.h>
#include <DNSServer.h>

#include <RingBuf.h>
#include <SPIFFS.h>
#include <FS.h>
#include "hx711_custom.h"
#include "screen_handler.h"
#include "tabataHandler.h"
#include "tabata.h"
#include "workout.h"

#define BUTTON1_PIN 10
#define BUTTON2_PIN 2
#define BUTTON3_PIN 9

#define R1 390.0f // 390k
#define R2 100.0f // 100k
// ESP8266 1.5V ref ESP32-C3 1.1V
#define BATTERY_SCALER (((R1 + R2) / R2) / 1023.0f) * (1.1 / 1.5)

#define BATTERY_VOLTAGE A1
#define BUZZER_PIN 0
#define POWER_PIN 5
#define DOUT 4
#define CLK 3

#define CONFIG_BUFFER_SIZE 2048
#define SSID_CONFIG_NUM 3

#define TABATA_FILE "/tabatas.json"
#define TABATA_JSON_BUFFER_SIZE 8192
DynamicJsonDocument tabataJSON(TABATA_JSON_BUFFER_SIZE);
TabataHandler tabataHandler(tabataJSON, TABATA_FILE);

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
  long offset;
  float scale;
  long time;
  float lastValue;
  float filterCoeff;
  long lastRawValue;
  bool buzzerEnable;
  bool wifiAPEnable;
  bool bluetoothEnable;
} configStruct;

typedef struct
{
  long t;
  long v;
} dataStruct;

typedef enum bType
{
  NONE = 0,
  B1_SHORT,
  B1_LONG,
  B1_HOLD,
  B2_SHORT,
  B2_LONG,
  B2_HOLD,
  B3_SHORT,
  B3_LONG,
  B3_HOLD
} bType;

typedef struct
{
  int freq;
  unsigned long duration;
} buzzStruct;