#pragma once
#include <ESP8266WiFi.h>
#include <ESP8266WiFiMulti.h>
#include <ESP8266WebServer.h>
#include <ESP8266mDNS.h>
#include <DNSServer.h>
#include <WebSocketsServer.h>
#include <RingBuf.h>
#include <FS.h>
#include "hx711_custom.h"
#include <ArduinoOTA.h>
#include <ArduinoJson.h>
#include "screen_handler.h"


#define BUTTON1_PIN D4
#define BUTTON2_PIN D0
#define BUTTON3_PIN D3

#define R1 390.0f  //390k
#define R2 100.0f  //100k
#define BATTERY_SCALER (((R1+R2)/R2)/1023.0f)
#define BATTERY_VOLTAGE A0
#define BUZZER_PIN D8
#define POWER_PIN D7
#define DOUT  D6
#define CLK  D5

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
