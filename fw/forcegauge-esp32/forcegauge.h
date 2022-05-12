#pragma once

#include <WiFi.h>
#include <WiFiClient.h>
#include <WebServer.h>
#include <ESPmDNS.h>
#include <WebSockets.h>
#include <WebSocketsServer.h>
#include <Update.h>

#include <RingBuf.h>
#include <SPIFFS.h>
#include <FS.h>
#include "hx711_custom.h"
#include "screen_handler.h"



#define BUTTON1_PIN 10
#define BUTTON2_PIN 2
#define BUTTON3_PIN 9

#define R1 390.0f  //390k
#define R2 100.0f  //100k
#define BATTERY_SCALER (((R1+R2)/R2)/1023.0f)
#define BATTERY_VOLTAGE A1
#define BUZZER_PIN 8
#define POWER_PIN 5
#define DOUT  4
#define CLK  3

#define CONFIG_BUFFER_SIZE 2048



typedef struct
{
  const char *name;
  const char *APssid;
  const char *APpasswd;
  const char *ssid1;
  const char *passwd1;
  const char *ssid2;
  const char *passwd2;
//  const char *ssid3;
//  const char *passwd3;
  long offset;
  float scale;
  long time;
  float lastValue;
  float filterCoeff;
} configStruct;

typedef struct
{
  long t;
  long v;
} dataStruct;
