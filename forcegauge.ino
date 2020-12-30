#include <RingBuf.h>
#include <ESP8266WiFi.h>
#include <WiFiClient.h>
#include <ESP8266WebServer.h>
//#include <WiFiManager.h>          //0.16.0
#include <HX711.h>
#include <FS.h>               // Include the SPIFFS library 

#define DOUT  D5
#define CLK  D6
 
HX711 scale(DOUT, CLK);

const char* APssid = "ForceGauge";
const char* APpassword = "password";

typedef struct 
{
  unsigned long t;
  long v;
} data_struct;

//WiFiManager wifiManager;    //Wifi manager
ESP8266WebServer server(80); //Server on port 80  
RingBuf<data_struct, 64> dataBuffer;
long zeroOffset = 0;
const float scaler = 0.000231142;

String getContentType(String filename) { // convert the file extension to the MIME type
  if (filename.endsWith(".html")) return "text/html";
  else if (filename.endsWith(".css")) return "text/css";
  else if (filename.endsWith(".js")) return "application/javascript";
  else if (filename.endsWith(".ico")) return "image/x-icon";
  return "text/plain";
}

bool handleFileRead(String path) { // send the right file to the client (if it exists)
  Serial.println("handleFileRead: " + path);
  if (path.endsWith("/")) path += "index.html";         // If a folder is requested, send the index file
  String contentType = getContentType(path);            // Get the MIME type
  if (SPIFFS.exists(path)) {                            // If the file exists
    File file = SPIFFS.open(path, "r");                 // Open it
    size_t sent = server.streamFile(file, contentType); // And send it to the client  
    file.close();                                       // Then close the file again
    return true;
  }
  Serial.println("\tFile Not Found");
  return false;                                         // If the file doesn't exist, return false
}

void handleGetData() {
  String jsonObj = "{\"data\": [";
  data_struct data;
  bool first = true;
  while(dataBuffer.lockedPop(data))
  {
    if (first)
    {
      first = false;
    }
    else
    {
      jsonObj += ",";
    }
    float valueFloat = (data.v - zeroOffset) * scaler;
    jsonObj += "{\"time\":\"" + String(data.t) + "\", ";
    jsonObj += "\"value\":\"" + String(valueFloat) + "\"}";
  }
  jsonObj += "]}";
  server.send(200, "text/plane", jsonObj);
  yield();
}

void setup() {
  // Start Serial
  Serial.begin(115200);
  
  // Start the SPI Flash Files System
  SPIFFS.begin();
  //wifiManager.autoConnect("ForceGauge", "password");

  //AP mode
  WiFi.mode(WIFI_AP_STA);
  WiFi.softAP(APssid, APpassword);
  WiFi.begin("ABWifi", "Secret_12345");
  //Client Mode
  // Start WIFI
  //WiFi.begin(ssid, password);     //Connect to your WiFi router
  //Serial.println("");  
  // Wait for connection
  //  while (WiFi.status() != WL_CONNECTED) {
  //  delay(500);
  //    Serial.print(".");
  //  }

  //If connection successful show IP address in serial monitor
  Serial.println("");
  Serial.print("Connected to ");
  Serial.println(WiFi.SSID());
  Serial.print("IP address: ");
  Serial.println(WiFi.softAPIP());  //IP address assigned to your ESP

  server.on("/getData", handleGetData);                 //This page is called by java Script AJAX
  
  server.onNotFound([]() {                              // If the client requests any URI
    if (!handleFileRead(server.uri()))                  // send it if it exists
      server.send(404, "text/plain", "404: Not Found"); // otherwise, respond with a 404 (Not Found) error
  });

  server.begin();                  //Start server
  Serial.println("HTTP server started");
  zeroOffset = scale.read_average();
  Serial.print("Zero Offset: ");
  Serial.println(zeroOffset);
}

void loop() {
  server.handleClient();
  if (scale.is_ready())
  {
    data_struct data;
    data.v = scale.read();
    data.t = millis();
    dataBuffer.lockedPush(data);
  }
  yield();
}
