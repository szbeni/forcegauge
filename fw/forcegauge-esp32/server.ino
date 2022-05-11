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

  // Dns server start
  dnsServer.start(53, "*", WiFi.softAPIP());

  //Add MDNS name
  MDNS.addService("http","tcp",80);

  if(!MDNS.begin("forcegauge")) {
     Serial.println("Error starting mDNS");
  }

  //OTA
  AsyncElegantOTA.begin(&server);    // Start AsyncElegantOTA

  
  // Handlers
  // There was a bug with AsyncWebServer, someone fixed it, so applied only the mem corruption patch
  // https://github.com/me-no-dev/ESPAsyncWebServer/compare/master...Depau:mem-corruption
  
  
  //Websocket
  ws.onEvent(onWsEvent);
  server.addHandler(&ws);

  // Does work with this too as the bug is patched
  // server.serveStatic("/", SPIFFS, "/").setCacheControl("max-age=600");

  server.on("/configure.html",  HTTP_POST, handleConfigUpdate); // config update
  server.on("/edit.html", HTTP_POST, [](AsyncWebServerRequest * request) {
    request->send(200);
  }, onUpload);

  server.on("/files", [](AsyncWebServerRequest * request) {
    String msg("Files:\n");
    File root = SPIFFS.open("/");
    File file = root.openNextFile();
    while (file) {
      msg += file.name();
      msg += "\n";
      file = root.openNextFile();
    }
    request->send(200, "text/plain", msg);
  });
  server.on("/generate_204", handleLoginPage);
  server.on("/getData", handleGetData);
  server.on("/about", handleAbout);

  server.onNotFound(handleGetFile);
  server.onFileUpload(onUpload);

  server.begin();
  

  Serial.println("HTTP server started");
}
