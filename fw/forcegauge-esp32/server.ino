#define FILESYSTEM SPIFFS
#define DBG_OUTPUT_PORT Serial

WebServer server(80);
WebSocketsServer webSocket(81);
File fsUploadFile;
DNSServer dnsServer;
IPAddress apIP(192,168,4,1); 
const byte DNS_PORT = 53;


bool exists(String path){
  bool yes = false;
  File file = FILESYSTEM.open(path, "r");
  if(!file.isDirectory()){
    yes = true;
  }
  file.close();
  return yes;
}

bool handleFileRead(String path) {
  DBG_OUTPUT_PORT.println("handleFileRead: " + path);
  
  if (path.endsWith("/")) {
    path += "index.htm";
  }
  if (path.endsWith(configFilename))
    saveConfig(&config);        
    
  String contentType = getContentType(path);
  String pathWithGz = path + ".gz";
  if (exists(pathWithGz) || exists(path)) {
    if (exists(pathWithGz)) {
      path += ".gz";
    }
    File file = FILESYSTEM.open(path, "r");
    server.streamFile(file, contentType);
    file.close();
    return true;
  }
  return false;
}

void handleFileUpload() {
  if (server.uri() != "/edit") {
    return;
  }
  HTTPUpload& upload = server.upload();
  if (upload.status == UPLOAD_FILE_START) {
    String filename = upload.filename;
    if (!filename.startsWith("/")) {
      filename = "/" + filename;
    }
    DBG_OUTPUT_PORT.print("handleFileUpload Name: "); DBG_OUTPUT_PORT.println(filename);
    fsUploadFile = FILESYSTEM.open(filename, "w");
    filename = String();
  } else if (upload.status == UPLOAD_FILE_WRITE) {
    //DBG_OUTPUT_PORT.print("handleFileUpload Data: "); DBG_OUTPUT_PORT.println(upload.currentSize);
    if (fsUploadFile) {
      fsUploadFile.write(upload.buf, upload.currentSize);
    }
  } else if (upload.status == UPLOAD_FILE_END) {
    if (fsUploadFile) {
      fsUploadFile.close();
    }
    DBG_OUTPUT_PORT.print("handleFileUpload Size: "); DBG_OUTPUT_PORT.println(upload.totalSize);
  }
}

void handleFileDelete() {
  if (server.args() == 0) {
    return server.send(500, "text/plain", "BAD ARGS");
  }
  String path = server.arg(0);
  DBG_OUTPUT_PORT.println("handleFileDelete: " + path);
  if (path == "/") {
    return server.send(500, "text/plain", "BAD PATH");
  }
  if (!exists(path)) {
    return server.send(404, "text/plain", "FileNotFound");
  }
  FILESYSTEM.remove(path);
  server.send(200, "text/plain", "");
  path = String();
}

void handleFileCreate() {
  if (server.args() == 0) {
    return server.send(500, "text/plain", "BAD ARGS");
  }
  String path = server.arg(0);
  DBG_OUTPUT_PORT.println("handleFileCreate: " + path);
  if (path == "/") {
    return server.send(500, "text/plain", "BAD PATH");
  }
  if (exists(path)) {
    return server.send(500, "text/plain", "FILE EXISTS");
  }
  File file = FILESYSTEM.open(path, "w");
  if (file) {
    file.close();
  } else {
    return server.send(500, "text/plain", "CREATE FAILED");
  }
  server.send(200, "text/plain", "");
  path = String();
}

void handleFileList() {
  if (!server.hasArg("dir")) {
    server.send(500, "text/plain", "BAD ARGS");
    return;
  }

  String path = server.arg("dir");
  DBG_OUTPUT_PORT.println("handleFileList: " + path);


  File root = FILESYSTEM.open(path);
  path = String();

  String output = "[";
  if(root.isDirectory()){
      File file = root.openNextFile();
      while(file){
          if (output != "[") {
            output += ',';
          }
          output += "{\"type\":\"";
          output += (file.isDirectory()) ? "dir" : "file";
          output += "\",\"name\":\"";
          output += String(file.path()).substring(1);
          output += "\"}";
          file = root.openNextFile();
      }
  }
  output += "]";
  server.send(200, "text/json", output);
}


String getContentType(String filename) {
  if (server.hasArg("download")) {
    return "application/octet-stream";
  } else if (filename.endsWith(".htm")) {
    return "text/html";
  } else if (filename.endsWith(".html")) {
    return "text/html";
  } else if (filename.endsWith(".css")) {
    return "text/css";
  } else if (filename.endsWith(".js")) {
    return "application/javascript";
  } else if (filename.endsWith(".png")) {
    return "image/png";
  } else if (filename.endsWith(".gif")) {
    return "image/gif";
  } else if (filename.endsWith(".jpg")) {
    return "image/jpeg";
  } else if (filename.endsWith(".ico")) {
    return "image/x-icon";
  } else if (filename.endsWith(".xml")) {
    return "text/xml";
  } else if (filename.endsWith(".pdf")) {
    return "application/x-pdf";
  } else if (filename.endsWith(".zip")) {
    return "application/x-zip";
  } else if (filename.endsWith(".gz")) {
    return "application/x-gzip";
  }
  return "text/plain";
}

void handleGetData() {
  String jsonObj = "{\"data\": [";
  dataStruct data;
  bool first = true;
  while (dataBuffer.lockedPop(data))
  {
    if (first)
    {
      first = false;
    }
    else
    {
      jsonObj += ",";
    }
    float valueFloat = (data.v - config.offset) * config.scale;
    jsonObj += "{\"time\":\"" + String(data.t) + "\", ";
    jsonObj += "\"value\":\"" + String(valueFloat) + "\"}";
  }
  jsonObj += "]}";
  server.send(200, "application/json", jsonObj);
}

void handleConfigUpdate()
{
  for (int i = 0; i < server.args(); i++) {
    if (configJSON.containsKey(server.argName(i)))
    {
      configJSON[server.argName(i)] = server.arg(i);
    }
  }
  copyConfig(&config);
  saveConfig(&config);

  handleFileRead("/configure.htm");
}


bool loggedIn = false;
void handleLoginPage()
{
  Serial.println("Login page");
  Serial.println(loggedIn);
  if (loggedIn == false)
  {
    if (server.method() == HTTP_POST)
    {
      server.send(204, "text/plain", "Logged in");
      //handleConfigUpdate();
      loggedIn = true;
    }
    else
    {
      //Serve configure
      handleFileRead("./login.htm");
    }
  }
  else
  {
    server.send(204);
  }
}


void handleAbout()
{
  String response = "type:forcegauge\n";
  response += "name:" + String(config.name) + "\n";
  response += "version:" + String(version)  + "\n";
  server.send(200, "text/plane", response);
}


void webSocketEvent(uint8_t num, WStype_t type, uint8_t * payload, size_t length) {
    String msg = "";
    switch(type) {
        case WStype_DISCONNECTED:
            DBG_OUTPUT_PORT.printf("[%u] Disconnected!\n", num);
            break;
        case WStype_CONNECTED:
            {
                IPAddress ip = webSocket.remoteIP(num);
                DBG_OUTPUT_PORT.printf("[%u] Connected from %d.%d.%d.%d url: %s\n", num, ip[0], ip[1], ip[2], ip[3], payload);

        // send message to client
        // webSocket.sendTXT(num, "Connected");
            }
            break;
        case WStype_TEXT:
            //DBG_OUTPUT_PORT.printf("[%u] get Text: %s\n", num, payload);
            for (size_t i = 0; i < length; i++) {
              msg += (char) payload[i];
            }
            handleWSMessage(msg);
            // send message to client
            // webSocket.sendTXT(num, "message here");

            // send data to all connected clients
            // webSocket.broadcastTXT("message here");
            break;
        case WStype_BIN:
            DBG_OUTPUT_PORT.printf("[%u] get binary length: %u\n", num, length);
            //hexdump(payload, length);

            // send message to client
            // webSocket.sendBIN(num, payload, length);
            break;
    case WStype_ERROR:      
    case WStype_FRAGMENT_TEXT_START:
    case WStype_FRAGMENT_BIN_START:
    case WStype_FRAGMENT:
    case WStype_FRAGMENT_FIN:
      break;
    }

}

//void webSocketBroadcastData()
//{
//  if (ws.count())
//  {
//    String jsonObj = "{\"data\": [";
//    jsonObj += "{\"time\":\"" + String(data->t) + "\", ";
//    jsonObj += "\"raw\":\"" + String(data->v) + "\", ";
//    jsonObj += "\"value\":\"" + String(config.lastValue) + "\"}";
//    jsonObj += "]}";
//    ws.textAll(jsonObj);
//  }
//}

void webSocketBroadcastScaleOffset()
{ 
  //No connected clients
  if (webSocket.connectedClients() == 0) 
    return;
  String data = "{\"scale\":" + String(config.scale, 10) + ", \"offset\":" + String(config.offset) + "}";    
  webSocket.broadcastTXT(data);
}

void handleWSMessage(String& data)
{
  if (data.startsWith("offset:"))
  {
    String val = getValue(data, ':', 1);
    config.offset = val.toInt();
    Serial.print("Set offset: ");
    Serial.print(config.offset);
    Serial.println("");
    webSocketBroadcastScaleOffset();
  }
  else if (data.startsWith("scale:"))
  {
    String val = getValue(data, ':', 1);
    config.scale = val.toFloat();
    Serial.print("Set scale: ");
    Serial.print(config.scale, 10);
    Serial.println("");
    webSocketBroadcastScaleOffset();
  }
  else if (data.startsWith("time:"))
  {
    String val = getValue(data, ':', 1);
    config.time = atol(val.c_str()) - millis();
    Serial.print("Set time: ");
    Serial.print(config.time);
    Serial.println("");
  }
}

void webSocketBroadcastData() {
  //Nothing to send
  if(dataBuffer.isEmpty())
    return;
  //No connected clients
  if (webSocket.connectedClients() == 0) 
    return;
    
  String jsonObj = "{\"data\": [";
  dataStruct data;
  bool first = true;
  while (dataBuffer.lockedPop(data))
  {
    if (first)
    {
      first = false;
    }
    else
    {
      jsonObj += ",";
    }
    float valueFloat = (data.v - config.offset) * config.scale;
    jsonObj += "{\"time\":\"" + String(data.t) + "\", ";
    jsonObj += "\"raw\":\"" + String(data.v) + "\", ";
    jsonObj += "\"value\":\"" + String(valueFloat) + "\"}";
  }
  jsonObj += "]}";
  
  webSocket.broadcastTXT(jsonObj);
}


const char* firmwareUpdateHtml = "<form method='POST' action='/update' enctype='multipart/form-data'><input type='file' name='update'><input type='submit' value='Update'></form>";
void handleUpdateFinish()
{
  server.sendHeader("Connection", "close");
  server.send(200, "text/plain", (Update.hasError()) ? "FAIL" : "OK");
  ESP.restart();
}

void handleUpdateStart()
{
  HTTPUpload& upload = server.upload();
  if (upload.status == UPLOAD_FILE_START) {
    Serial.setDebugOutput(true);
    Serial.printf("Update: %s\n", upload.filename.c_str());
    if (!Update.begin()) { //start with max available size
      Update.printError(Serial);
    }
  } else if (upload.status == UPLOAD_FILE_WRITE) {
    if (Update.write(upload.buf, upload.currentSize) != upload.currentSize) {
      Update.printError(Serial);
    }
  } else if (upload.status == UPLOAD_FILE_END) {
    if (Update.end(true)) { //true to set the size to the current progress
      Serial.printf("Update Success: %u\nRebooting...\n", upload.totalSize);
    } else {
      Update.printError(Serial);
    }
    Serial.setDebugOutput(false);
  } else {
    Serial.printf("Update Failed Unexpectedly (likely broken connection): status=%d\n", upload.status);
  }
}

// check if this string is an IP address
boolean isIp(String str) {
  for (size_t i = 0; i < str.length(); i++) {
    int c = str.charAt(i);
    if (c != '.' && (c < '0' || c > '9')) {
      return false;
    }
  }
  return true;
}

String toStringIp(IPAddress ip) {
  String res = "";
  for (int i = 0; i < 3; i++) {
    res += String((ip >> (8 * i)) & 0xFF) + ".";
  }
  res += String(((ip >> 8 * 3)) & 0xFF);
  return res;
}

boolean captivePortal() {
  if (!isIp(server.hostHeader())) {
    Serial.println("Request redirected to captive portal");
    server.sendHeader("Location", String("http://") + toStringIp(server.client().localIP()), true);
    server.send(302, "text/plain", "");   
    server.client().stop(); 
    return true;
  }
  return false;
}

void handleRoot() {
  if (captivePortal()) { 
    return;
  }
  server.sendHeader("Cache-Control", "no-cache, no-store, must-revalidate");
  server.sendHeader("Pragma", "no-cache");
  server.sendHeader("Expires", "-1");

  String p;
  p += F(
            "<html><head></head><body>"
            "<h1>Connected!</h1>");
  p += F("</body></html>");

  server.send(200, "text/html", p);

}


bool checkWifiConnection(const char* ssid, const char* passwd)
{

  static unsigned long previous_time = 0;
  unsigned long current_time = millis();
  
  if (ssid == "") 
    return false;
  
  if (WiFi.status() == WL_CONNECTED)
  {
     if (String(WiFi.SSID()) == String(ssid)) 
     {
        return true;
     }
  }

  if ((current_time - previous_time >= 10000) || ( previous_time == 0))
  {
    previous_time = current_time;
    Serial.print("\nConnecting to WIFI network: ");
    Serial.println(ssid);
    WiFi.begin(ssid, passwd);
  }
  return false;
}


void WiFiStationConnected(WiFiEvent_t event, WiFiEventInfo_t info)
{
    Serial.println("Connected to AP!");
}

void wifiTask( void * parameter )
{
  
  Serial.print("WiFiTask: priority = ");
  Serial.println(uxTaskPriorityGet(NULL));

  WiFi.onEvent(WiFiEvent);
  WiFi.mode(WIFI_AP_STA);
  WiFi.softAP(config.APssid, config.APpasswd);
  WiFi.softAPConfig(apIP, apIP, IPAddress(255, 255, 255, 0));

  bool connectedFlag = false;
  int cntr = 0;
  while(!connectedFlag)
  {
     connectedFlag = checkWifiConnection(config.ssid1, config.passwd1);
     delay(500);
     Serial.print(".");
     if (++cntr > 15)
       break;
  }
  if(connectedFlag)
  {
      Serial.print("\nConnected: ");
      Serial.println(config.ssid1);
      Serial.print("IP: ");
      Serial.println(WiFi.localIP());
  }
  else
  {
      Serial.print("\nFailed to connect: ");
      Serial.println(config.ssid1);
  }


  dnsServer.start(DNS_PORT, "*", apIP);



  MDNS.addService("http","tcp",80);
  MDNS.begin(config.name);
  DBG_OUTPUT_PORT.print("Open http://");
  DBG_OUTPUT_PORT.print(config.name);
  DBG_OUTPUT_PORT.println(".local/");


  //SERVER INIT
  server.on("/list", HTTP_GET, handleFileList);
  server.on("/edit", HTTP_GET, []() {
    if (!handleFileRead("/edit.htm")) {
      server.send(404, "text/plain", "FileNotFound");
    }
  });
  server.on("/edit", HTTP_PUT, handleFileCreate);
  server.on("/edit", HTTP_DELETE, handleFileDelete);
  server.on("/edit", HTTP_POST, []() {
    server.send(200, "text/plain", "");
  }, handleFileUpload);

  //server.on("/", handleRoot);
  server.on("/generate_204", handleRoot);
  server.on("/gen_204", handleRoot);
  server.on("/configure.htm",  HTTP_POST, handleConfigUpdate);
  server.on("/getData", handleGetData);
  server.on("/about", handleAbout);
  
  server.on("/update", HTTP_GET, []() {
      server.sendHeader("Connection", "close");
      server.send(200, "text/html", firmwareUpdateHtml);
    });
  server.on("/update", HTTP_POST, handleUpdateFinish, handleUpdateStart);
  server.onNotFound([]() {
    if (!handleFileRead(server.uri())) {
      if (captivePortal()) { 
        return;
      }
      server.send(404, "text/plain", "FileNotFound");
    }
  });

  //get heap status, analog input value and all GPIO statuses in one json call
  server.on("/all", HTTP_GET, []() {
    String json = "{";
    json += "\"heap\":" + String(ESP.getFreeHeap());
    json += ", \"analog\":" + String(analogRead(A1));
    json += ", \"gpio\":" + String((uint32_t)(0));
    json += "}";
    server.send(200, "text/json", json);
    json = String();
  });
  server.begin();
  DBG_OUTPUT_PORT.println("HTTP server started");

  // Websocket server start
  webSocket.begin();
  webSocket.onEvent(webSocketEvent);
  
  unsigned long previous_time = 0;
  while(1){
    checkWifiConnection(config.ssid1, config.passwd1);
    dnsServer.processNextRequest();
    server.handleClient();
    webSocket.loop();
    webSocketBroadcastData();
    delay(2);
  }
  
  //Should never get here
  vTaskDelete( NULL );
}
