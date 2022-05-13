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


void WiFiEvent(WiFiEvent_t event)
{
    Serial.printf("[WiFi-event] event: %d\n", event);

    switch (event) {
        case ARDUINO_EVENT_WIFI_READY: 
            Serial.println("WiFi interface ready");
            break;
        case ARDUINO_EVENT_WIFI_SCAN_DONE:
            Serial.println("Completed scan for access points");
            break;
        case ARDUINO_EVENT_WIFI_STA_START:
            Serial.println("WiFi client started");
            break;
        case ARDUINO_EVENT_WIFI_STA_STOP:
            Serial.println("WiFi clients stopped");
            break;
        case ARDUINO_EVENT_WIFI_STA_CONNECTED:
            Serial.println("Connected to access point");
            break;
        case ARDUINO_EVENT_WIFI_STA_DISCONNECTED:
            Serial.println("Disconnected from WiFi access point");
            break;
        case ARDUINO_EVENT_WIFI_STA_AUTHMODE_CHANGE:
            Serial.println("Authentication mode of access point has changed");
            break;
        case ARDUINO_EVENT_WIFI_STA_GOT_IP:
            Serial.print("Obtained IP address: ");
            Serial.println(WiFi.localIP());
            break;
        case ARDUINO_EVENT_WIFI_STA_LOST_IP:
            Serial.println("Lost IP address and IP address is reset to 0");
            break;
        case ARDUINO_EVENT_WPS_ER_SUCCESS:
            Serial.println("WiFi Protected Setup (WPS): succeeded in enrollee mode");
            break;
        case ARDUINO_EVENT_WPS_ER_FAILED:
            Serial.println("WiFi Protected Setup (WPS): failed in enrollee mode");
            break;
        case ARDUINO_EVENT_WPS_ER_TIMEOUT:
            Serial.println("WiFi Protected Setup (WPS): timeout in enrollee mode");
            break;
        case ARDUINO_EVENT_WPS_ER_PIN:
            Serial.println("WiFi Protected Setup (WPS): pin code in enrollee mode");
            break;
        case ARDUINO_EVENT_WIFI_AP_START:
            Serial.println("WiFi access point started");
            break;
        case ARDUINO_EVENT_WIFI_AP_STOP:
            Serial.println("WiFi access point  stopped");
            break;
        case ARDUINO_EVENT_WIFI_AP_STACONNECTED:
            Serial.println("Client connected");
            break;
        case ARDUINO_EVENT_WIFI_AP_STADISCONNECTED:
            Serial.println("Client disconnected");
            break;
        case ARDUINO_EVENT_WIFI_AP_STAIPASSIGNED:
            Serial.println("Assigned IP address to client");
            break;
        case ARDUINO_EVENT_WIFI_AP_PROBEREQRECVED:
            Serial.println("Received probe request");
            break;
        case ARDUINO_EVENT_WIFI_AP_GOT_IP6:
            Serial.println("AP IPv6 is preferred");
            break;
        case ARDUINO_EVENT_WIFI_STA_GOT_IP6:
            Serial.println("STA IPv6 is preferred");
            break;
        case ARDUINO_EVENT_ETH_GOT_IP6:
            Serial.println("Ethernet IPv6 is preferred");
            break;
        case ARDUINO_EVENT_ETH_START:
            Serial.println("Ethernet started");
            break;
        case ARDUINO_EVENT_ETH_STOP:
            Serial.println("Ethernet stopped");
            break;
        case ARDUINO_EVENT_ETH_CONNECTED:
            Serial.println("Ethernet connected");
            break;
        case ARDUINO_EVENT_ETH_DISCONNECTED:
            Serial.println("Ethernet disconnected");
            break;
        case ARDUINO_EVENT_ETH_GOT_IP:
            Serial.println("Obtained IP address");
            break;
        default: break;
    }}

void startWifi() 
{
  WiFi.onEvent(WiFiEvent);
  WiFi.mode(WIFI_AP_STA);
  WiFi.softAP(config.APssid, config.APpasswd);
  WiFi.softAPConfig(apIP, apIP, IPAddress(255, 255, 255, 0));
//  WiFi.begin();
  
//  bool connectedFlag = false;
//  int cntr = 0;
//  while(!connectedFlag)
//  {
//     connectedFlag = checkWifiConnection(config.ssid1, config.passwd1);
//     delay(500);
//     Serial.print(".");
//     if (++cntr > 15)
//       break;
//  }
//  if(connectedFlag)
//  {
//      Serial.print("\nConnected: ");
//      Serial.println(config.ssid1);
//      Serial.print("IP: ");
//      Serial.println(WiFi.localIP());
//  }
//  else
//  {
//      Serial.print("\nFailed to connect: ");
//      Serial.println(config.ssid1);
//  }

//  while (WiFi.status() != WL_CONNECTED) {
//    delay(500);
//    Serial.println("Connecting to WiFi..");
//  }
}


bool checkSSIDAvailable(int n, const char* ssid)
{
  String tmp(ssid);
  for (int i = 0; i < n; ++i) {
    if (tmp == WiFi.SSID(i))
    {
      return true;
    }
  }
  return false;
}

void printAvailableNetworks(int n)
{
    if (n == 0) {
        Serial.println("no networks found");
    } else {
      Serial.print(n);
      Serial.println(" networks found");
      for (int i = 0; i < n; ++i) {
        // Print SSID and RSSI for each network found
        Serial.print(i + 1);
        Serial.print(": ");
        Serial.print(WiFi.SSID(i));
        Serial.print(" (");
        Serial.print(WiFi.RSSI(i));
        Serial.print(")");
        Serial.println((WiFi.encryptionType(i) == WIFI_AUTH_OPEN)?" ":"*");
      }
    }
    Serial.println("");
}


void wifiTask(void * parameter)
{
  while(1)
  {
    if (WiFi.status() != WL_CONNECTED) {
        Serial.println("Scan start");
        // WiFi.scanNetworks will return the number of networks found
        int n = WiFi.scanNetworks();
        
        Serial.println("scan done");
        
        //Debug print available networks
        printAvailableNetworks(n);

        //Check if any of avaible network is interesting for us
        bool onlineAny = false;
        for (int i=0;i< SSID_CONFIG_NUM; i++)
        {
          if (checkSSIDAvailable(n, getConfigSSID(i)))
          {
            Serial.print("Connecting to WiFi network: ");
            Serial.println(getConfigSSID(i));
            WiFi.begin(getConfigSSID(i), getConfigPasswd(i));
            onlineAny = true;
            break;
          }
          else
          {
            Serial.print("WiFi network not available: ");
            Serial.println(getConfigSSID(i));
          }
        }
        //No avilable network found, disconnect.
        if (onlineAny == false)
        {
          Serial.println("No configured WiFi network is available at the moment.");
          WiFi.disconnect(false, true);
        }
    }    
    delay(10000);
  }
}

 
