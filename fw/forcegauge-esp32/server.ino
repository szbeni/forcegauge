#include <AsyncTCP.h>
#include <ESPAsyncWebServer.h>
#include <AsyncElegantOTA.h>
#include <ESPmDNS.h>
#include <DNSServer.h>

  
AsyncWebServer server(80);
AsyncWebSocket ws("/ws");
AsyncEventSource events("/events");
DNSServer dnsServer;



void startWebSocket() { // Start a WebSocket server
}



void startServer()
{

  //Add MDNS name
  MDNS.addService("http","tcp",80);

  if(!MDNS.begin("forcegauge")) {
     Serial.println("Error starting mDNS");
  }

  // Websocket server
//  webSocket.begin();                          // start the websocket server
//  webSocket.onEvent(webSocketEvent);          // if there's an incomming websocket message, go to function 'webSocketEvent'
//  Serial.println("WebSocket server started.");


  //OTA
  AsyncElegantOTA.begin(&server);    // Start AsyncElegantOTA

  //Default handler
//  server.on("/", HTTP_GET, [](AsyncWebServerRequest *request) {
//    request->send(200, "text/plain", "Hi! This is a sample response.");
//  });

//  server.serveStatic("/", SPIFFS, "/").setDefaultFile("index.htm");
//
//  server.onNotFound([](AsyncWebServerRequest *request){
//    Serial.printf("NOT_FOUND: ");
//    if(request->method() == HTTP_GET)
//      Serial.printf("GET");
//    else if(request->method() == HTTP_POST)
//      Serial.printf("POST");
//    else if(request->method() == HTTP_DELETE)
//      Serial.printf("DELETE");
//    else if(request->method() == HTTP_PUT)
//      Serial.printf("PUT");
//    else if(request->method() == HTTP_PATCH)
//      Serial.printf("PATCH");
//    else if(request->method() == HTTP_HEAD)
//      Serial.printf("HEAD");
//    else if(request->method() == HTTP_OPTIONS)
//      Serial.printf("OPTIONS");
//    else
//      Serial.printf("UNKNOWN");
//    Serial.printf(" http://%s%s\n", request->host().c_str(), request->url().c_str());
//
//    if(request->contentLength()){
//      Serial.printf("_CONTENT_TYPE: %s\n", request->contentType().c_str());
//      Serial.printf("_CONTENT_LENGTH: %u\n", request->contentLength());
//    }
//
//    int headers = request->headers();
//    int i;
//    for(i=0;i<headers;i++){
//      AsyncWebHeader* h = request->getHeader(i);
//      Serial.printf("_HEADER[%s]: %s\n", h->name().c_str(), h->value().c_str());
//    }
//
//    int params = request->params();
//    for(i=0;i<params;i++){
//      AsyncWebParameter* p = request->getParam(i);
//      if(p->isFile()){
//        Serial.printf("_FILE[%s]: %s, size: %u\n", p->name().c_str(), p->value().c_str(), p->size());
//      } else if(p->isPost()){
//        Serial.printf("_POST[%s]: %s\n", p->name().c_str(), p->value().c_str());
//      } else {
//        Serial.printf("_GET[%s]: %s\n", p->name().c_str(), p->value().c_str());
//      }
//    }
//
//    request->send(404);
//  });
//  
//
//  server.on("/getData", handleGetData);
    server.onNotFound([](AsyncWebServerRequest *request) {
    //if (!handleFileRead(server.uri()))                  // send it if it exists
        request->send(404, "text/plain", "404: Not Found"); 
      
    });

    server.on("/about", handleAbout);
//  server.on("/edit.html",  HTTP_POST, []() {  // If a POST request is sent to the /edit.html address,
//    server.send(200, "text/plain", "");
//  }, handleFileUpload);                       // go to 'handleFileUpload'
//
//  server.on("/configure.html",  HTTP_POST, handleConfigUpdate); // config update
//  server.on("/generate_204", handleLoginPage);
// 
//  server.onNotFound([]() {                              // If the client requests any URI
//    if (!handleFileRead(server.uri()))                  // send it if it exists
//        server.send(404, "text/plain", "404: Not Found"); // otherwise, respond with a 404 (Not Found) error, shouldt get here if there is an index
//      
//  });

  server.begin();
  

  Serial.println("HTTP server started");
}
