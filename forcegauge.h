#pragma once
#include <ESP8266WiFi.h>
#include <ESP8266WiFiMulti.h>
#include <ESP8266WebServer.h>
#include <ESP8266mDNS.h>
#include <WebSocketsServer.h>
#include <RingBuf.h>
#include <FS.h>
#include <HX711.h>

#define DOUT  D5
#define CLK  D6

typedef struct
{
  char mdnsName[32];

  char APssid[32];
  char APpasswd[32];

  char ssid1[32];
  char passwd1[32];

  long offset;
  float scale;
  long time;

} configStruct;

typedef struct
{
  long t;
  long v;
} dataStruct;
