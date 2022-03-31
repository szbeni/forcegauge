void startWiFi() { // Start a Wi-Fi access point, and try to connect to some given access points. Then wait for either an AP or STA connection
  WiFi.softAPConfig(apIP, apIP, IPAddress(255, 255, 255, 0));
  WiFi.softAP(config.APssid, config.APpasswd);             // Start the access point
  
  Serial.print("Access Point \"");
  Serial.print(config.APssid);
  Serial.println("\" started\r\n");

  wifiMulti.addAP(config.ssid1, config.passwd1);
  wifiMulti.addAP(config.ssid2, config.passwd2);
  wifiMulti.addAP(config.ssid2, config.passwd3);

//This is blocking dont need it
//  Serial.println("Connecting");
//  while (wifiMulti.run() != WL_CONNECTED && WiFi.softAPgetStationNum() < 1) {  // Wait for the Wi-Fi to connect
//    delay(250);
//    Serial.print('.');
//  } 
//  //delay(1000);
//  Serial.println("\r\n");
//  if (WiFi.softAPgetStationNum() == 0) {     // If the ESP is connected to an AP
//    Serial.print("Connected to ");
//    Serial.println(WiFi.SSID());             // Tell us what network we're connected to
//    Serial.print("IP address:\t");
//    Serial.print(WiFi.localIP());            // Send the IP address of the ESP8266 to the computer
//  } else {                                   // If a station is connected to the ESP SoftAP
//    Serial.print("Station connected to ESP8266 AP");
//  }
//  Serial.println("\r\n");
}

bool checkWifiConnected()
{
  if (wifiMulti.run() != WL_CONNECTED && WiFi.softAPgetStationNum() < 1)
  {
    return false;
  }
  Serial.println("\r\n");
  if (WiFi.softAPgetStationNum() == 0) {     // If the ESP is connected to an AP
    Serial.print("Connected to ");
    Serial.println(WiFi.SSID());             // Tell us what network we're connected to
    Serial.print("IP address:\t");
    Serial.print(WiFi.localIP());            // Send the IP address of the ESP8266 to the computer
  } else {                                   // If a station is connected to the ESP SoftAP
    Serial.print("Station connected to ESP8266 AP");
  }
  Serial.println("\r\n");

  return true;
}

void startServer() { // Start a HTTP server with a file read handler and an upload handler
  server.on("/getData", handleGetData);
  server.on("/about", handleAbout);
  server.on("/edit.html",  HTTP_POST, []() {  // If a POST request is sent to the /edit.html address,
    server.send(200, "text/plain", "");
  }, handleFileUpload);                       // go to 'handleFileUpload'

  server.on("/configure.html",  HTTP_POST, handleConfigUpdate); // config update
  server.on("/generate_204", handleLoginPage);
 
  server.onNotFound([]() {                              // If the client requests any URI
    if (!handleFileRead(server.uri()))                  // send it if it exists
        server.send(404, "text/plain", "404: Not Found"); // otherwise, respond with a 404 (Not Found) error, shouldt get here if there is an index
      
  });

  server.begin();                             // start the HTTP server
  Serial.println("HTTP server started.");
}

void startWebSocket() { // Start a WebSocket server
  webSocket.begin();                          // start the websocket server
  webSocket.onEvent(webSocketEvent);          // if there's an incomming websocket message, go to function 'webSocketEvent'
  Serial.println("WebSocket server started.");
}

void startMDNS() { // Start the mDNS responder
   if (!MDNS.begin(config.name)) {
    Serial.println("Error setting up MDNS responder!");
    while (1) {
      delay(1000);
    }
  }  Serial.print(config.name);

  MDNS.addService("http", "tcp", 80);
  // start the multicast domain name server
  Serial.print("mDNS responder started: http://");
  Serial.println(".local");
}

//For captive control
void startDNSServer(){
  dnsServer.start(53, "*", apIP); // in setup after the softAP setup
  
}


void startSPIFFS() { // Start the SPIFFS and list all contents
  SPIFFS.begin();                             // Start the SPI Flash File System (SPIFFS)
  Serial.println("SPIFFS started. Contents:");
  {
    Dir dir = SPIFFS.openDir("/");
    while (dir.next()) {                      // List the file system contents
      String fileName = dir.fileName();
      size_t fileSize = dir.fileSize();
      Serial.printf("\tFS File: %s, size: %s\r\n", fileName.c_str(), formatBytes(fileSize).c_str());
    }
    Serial.printf("\n");
  }
}

void startOTA()
{
    // Port defaults to 8266
  // ArduinoOTA.setPort(8266);

  // Hostname defaults to esp8266-[ChipID]
  ArduinoOTA.setHostname("forcegauge");

  // No authentication by default
  ArduinoOTA.setPassword((const char *)"");

  ArduinoOTA.onStart([]() {
    Serial.println("Start OTA");
  });
  ArduinoOTA.onEnd([]() {
    Serial.println("\nEndv OTA");
  });
  ArduinoOTA.onProgress([](unsigned int progress, unsigned int total) {
    Serial.printf("Progress: %u%%\r", (progress / (total / 100)));
  });
  ArduinoOTA.onError([](ota_error_t error) {
    Serial.printf("Error[%u]: ", error);
    if (error == OTA_AUTH_ERROR) Serial.println("Auth Failed");
    else if (error == OTA_BEGIN_ERROR) Serial.println("Begin Failed");
    else if (error == OTA_CONNECT_ERROR) Serial.println("Connect Failed");
    else if (error == OTA_RECEIVE_ERROR) Serial.println("Receive Failed");
    else if (error == OTA_END_ERROR) Serial.println("End Failed");
  });
  ArduinoOTA.begin();
  
}

void startHX711()
{
  scale.begin(DOUT, CLK);
  Serial.print("Scale: ");
  config.offset = scale.read_average();
  Serial.print("Zero Offset: ");
  Serial.print(config.offset);
  Serial.println("");
  Serial.print("Scale: ");
  Serial.print(config.scale, 8);
  Serial.println("");
}
