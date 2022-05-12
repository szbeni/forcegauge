// 
//void WiFiStationConnected(WiFiEvent_t event, WiFiEventInfo_t info){
//  Serial.println("Station connected");
//
//  Serial.print("ESP32 IP as soft AP: ");
//  Serial.println(WiFi.softAPIP());
// 
//  Serial.print("ESP32 IP on the WiFi network: ");
//  Serial.println(WiFi.localIP());
//}
//
//void startWiFi() {
// 
//  Serial.begin(115200);
//   
//  WiFi.mode(WIFI_MODE_APSTA);
// 
//  WiFi.softAP(config.APssid, config.APpasswd);
//  WiFi.begin(config.ssid1, config.passwd1);
//  WiFi.onEvent(WiFiStationConnected, ARDUINO_EVENT_WIFI_AP_STACONNECTED);
//  WiFi.onEvent(WiFiStationConnected, ARDUINO_EVENT_WIFI_STA_CONNECTED);
//
////  while (WiFi.status() != WL_CONNECTED) {
////    delay(500);
////    Serial.println("Connecting to WiFi..");
////  }
//}
// 
