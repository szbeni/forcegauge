#include <HTTPClient.h>
#include <Update.h>

//#define HOST "https://github.com/szbeni/forcegauge/releases/latest/download/forcegauge-esp32.ino.bin"
#define HOST "https://github.com/szbeni/forcegauge/releases/download/v1.0.6/forcegauge-esp32.ino.partitions.bin"

HTTPClient client;

int totalLength;
int currentLength = 0;
bool tryupdate = false;
uint8_t buff[128];

void webupdateTask(void *parameter)
{
    while (1)
    {
        if (tryupdate)
        {
            Serial.print("Webupdate task, tryupdate");
            client.setFollowRedirects(HTTPC_STRICT_FOLLOW_REDIRECTS);
            client.begin(HOST);
            int resp = client.GET();
            Serial.print("Response: ");
            Serial.println(resp);
            Serial.println(client.getLocation());
            client.end();

            if (resp == 200)
            {

                // get length of document (is -1 when Server sends no Content-Length header)
                totalLength = client.getSize();
                // transfer to local variable
                int len = totalLength;
                // this is required to start firmware update process
                Update.begin(UPDATE_SIZE_UNKNOWN);
                Serial.printf("FW Size: %u\n", totalLength);
                // get tcp stream
                WiFiClient *stream = client.getStreamPtr();
                // read all data from server
                Serial.println("Updating firmware...");
                while (client.connected() && (len > 0 || len == -1))
                {
                    // get available data size
                    size_t size = stream->available();
                    if (size)
                    {
                        // read up to 128 byte
                        int c = stream->readBytes(buff, ((size > sizeof(buff)) ? sizeof(buff) : size));
                        // pass to function
                        updateFirmware(buff, c);
                        if (len > 0)
                        {
                            len -= c;
                        }
                    }
                    delay(10);
                }
            }
            else
            {
                Serial.print("Failed to update");
                tryupdate = false;
            }
        }
        delay(1000);
    }
}

void updateFirmware(uint8_t *data, size_t len)
{
    Update.write(data, len);
    currentLength += len;
    // Print dots while waiting for update to finish
    Serial.print('.');
    // if current length of written firmware is not equal to total firmware size, repeat
    if (currentLength != totalLength)
        return;
    Update.end(true);
    Serial.printf("\nUpdate Success, Total Size: %u\nRebooting...\n", currentLength);
    // Restart ESP32 to see changes
    ESP.restart();
}

void handleUpdateWebOTA()
{
    tryupdate = true;
    server.send(404, "text/plain", "Firmware update is not possible at the moment.");
    return;
    if (tryupdate == true)
    {
        server.send(404, "text/plain", "Firmware update is already in progress.");
        return;
    }
    bool failed = true;
    client.setFollowRedirects(HTTPC_DISABLE_FOLLOW_REDIRECTS);
    //  Connect to external web server
    client.begin(HOST);
    // Get file, just to check if each reachable
    int resp = client.GET();
    Serial.print("Response: ");
    Serial.println(resp);

    // We are expecting 302 with the firmware version in the link name
    // With response like: https://github.com/szbeni/forcegauge/releases/download/v1.0.6/forcegauge-esp32.ino.bin
    if (resp == 302)
    {
        String url = client.getLocation();
        int versionStartIndex = url.indexOf("/download/v");
        if (versionStartIndex != -1)
        {
            int versionEndIndex = url.indexOf("/", versionStartIndex + 11);
            if (versionEndIndex != -1)
            {
                String version = url.substring(versionStartIndex + 11, versionEndIndex);
                Serial.print(version);
                if (version.equals(VERSION))
                {
                    server.send(404, "text/plain", "Firmware is up to date.");
                    client.end();
                    return;
                }
                else
                {
                    // Redirect to the actual firmware
                    failed = false;
                }
            }
        }
    }
    if (failed)
    {
        server.send(404, "text/plain", "Cannot connect to remote address.");
        client.end();
        return;
    }
    else
    {
        server.send(204, "text/plain", "Update in progess");
        client.end();
        tryupdate = 1;
    }
}
