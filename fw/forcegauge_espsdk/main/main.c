/*  WiFi softAP Example

   This example code is in the Public Domain (or CC0 licensed, at your option.)

   Unless required by applicable law or agreed to in writing, this
   software is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
   CONDITIONS OF ANY KIND, either express or implied.
*/
#include <string.h>
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "freertos/event_groups.h"

#include "esp_system.h"
#include "esp_wifi.h"
#include "esp_event.h"

#include "esp_log.h"
#include "nvs_flash.h"

#include "lwip/err.h"
#include "lwip/sys.h"
#include "mytask.h"
#include "ssd1306.h"

/* The examples use WiFi configuration that you can set via project configuration menu.

   If you'd rather not, just change the below entries to strings with
   the config you want - ie #define EXAMPLE_WIFI_SSID "mywifissid"
*/
#define EXAMPLE_ESP_WIFI_SSID CONFIG_ESP_WIFI_SSID
#define EXAMPLE_ESP_WIFI_PASS CONFIG_ESP_WIFI_PASSWORD
#define EXAMPLE_MAX_STA_CONN CONFIG_ESP_MAX_STA_CONN

static EventGroupHandle_t s_wifi_event_group;

#define WIFI_CONNECTED_BIT BIT0
#define WIFI_FAIL_BIT BIT1

static const char *TAG = "wifi softAP";
static int s_retry_num = 0;
static int wifi_sta_connected = 0;

static void wifi_event_handler(void *arg, esp_event_base_t event_base,
                               int32_t event_id, void *event_data)
{
    if (event_id == WIFI_EVENT_AP_STACONNECTED)
    {
        wifi_event_ap_staconnected_t *event = (wifi_event_ap_staconnected_t *)event_data;
        ESP_LOGI(TAG, "station " MACSTR " join, AID=%d",
                 MAC2STR(event->mac), event->aid);
    }
    else if (event_id == WIFI_EVENT_AP_STADISCONNECTED)
    {
        wifi_event_ap_stadisconnected_t *event = (wifi_event_ap_stadisconnected_t *)event_data;
        ESP_LOGI(TAG, "station " MACSTR " leave, AID=%d",
                 MAC2STR(event->mac), event->aid);
    }

    if (event_base == WIFI_EVENT && event_id == WIFI_EVENT_STA_START)
    {
        esp_wifi_connect();
    }
    else if (event_base == WIFI_EVENT && (event_id == WIFI_EVENT_STA_DISCONNECTED || event_id == WIFI_EVENT_STA_STOP))
    {
        // if (s_retry_num < EXAMPLE_ESP_MAXIMUM_RETRY)
        //{
        // esp_wifi_connect();
        // s_retry_num++;
        // ESP_LOGI(TAG, "retry to connect to the AP");
        //}
        // else
        // {
        // }
        ESP_LOGI(TAG, "connect to the AP fail");
        wifi_sta_connected = 0;
        // xEventGroupSetBits(s_wifi_event_group, WIFI_FAIL_BIT);
    }
    else if (event_base == IP_EVENT && event_id == IP_EVENT_STA_GOT_IP)
    {
        ip_event_got_ip_t *event = (ip_event_got_ip_t *)event_data;
        ESP_LOGI(TAG, "got ip:%s", ip4addr_ntoa(&event->ip_info.ip));
        s_retry_num = 0;
        wifi_sta_connected = 1;
        // xEventGroupSetBits(s_wifi_event_group, WIFI_CONNECTED_BIT);
    }
}

#define MAX_STA_LEN 3
static wifi_config_t wifi_sta_configs[MAX_STA_LEN];

void wifi_init_softap()
{
    s_wifi_event_group = xEventGroupCreate();

    tcpip_adapter_init();
    ESP_ERROR_CHECK(esp_event_loop_create_default());

    wifi_init_config_t cfg = WIFI_INIT_CONFIG_DEFAULT();
    ESP_ERROR_CHECK(esp_wifi_init(&cfg));

    ESP_ERROR_CHECK(esp_event_handler_register(WIFI_EVENT, ESP_EVENT_ANY_ID, &wifi_event_handler, NULL));

    wifi_config_t wifi_ap_config = {
        .ap = {
            .ssid = EXAMPLE_ESP_WIFI_SSID,
            .ssid_len = strlen(EXAMPLE_ESP_WIFI_SSID),
            .password = EXAMPLE_ESP_WIFI_PASS,
            .max_connection = EXAMPLE_MAX_STA_CONN,
            .authmode = WIFI_AUTH_WPA_WPA2_PSK},
    };

    if (strlen(EXAMPLE_ESP_WIFI_PASS) == 0)
    {
        wifi_ap_config.ap.authmode = WIFI_AUTH_OPEN;
    }

    for (uint16_t i = 0; i < MAX_STA_LEN; i++)
        wifi_sta_configs[i].sta.ssid[0] = 0;

    // Sample configs
    strcpy((char *)wifi_sta_configs[0].sta.ssid, "Beni's phone");
    strcpy((char *)wifi_sta_configs[0].sta.password, "fafafa1234567890");
    strcpy((char *)wifi_sta_configs[1].sta.ssid, "ABWifi");
    strcpy((char *)wifi_sta_configs[1].sta.password, "Secret_12345");

    ESP_ERROR_CHECK(esp_wifi_set_mode(WIFI_MODE_APSTA));
    ESP_ERROR_CHECK(esp_wifi_set_config(ESP_IF_WIFI_AP, &wifi_ap_config));

    ESP_ERROR_CHECK(esp_wifi_start());
    ESP_LOGI(TAG, "wifi_init_softap finished. SSID:%s password:%s",
             EXAMPLE_ESP_WIFI_SSID, EXAMPLE_ESP_WIFI_PASS);

    uint8_t sta_num = 0;
    while (1)
    {
        if (wifi_sta_connected == 0)
        {
            // skip empty entries
            if (wifi_sta_configs[sta_num].sta.ssid[0] != 0)
            {
                ESP_LOGI(TAG, "Trying to connect to: %s", (char *)&wifi_sta_configs[sta_num].sta.ssid);
                ESP_ERROR_CHECK(esp_wifi_set_config(ESP_IF_WIFI_STA, &wifi_sta_configs[sta_num]));
                wifi_sta_connected = 1;
                esp_wifi_connect();
            }

            if (++sta_num >= MAX_STA_LEN)
                sta_num = 0;
        }
        vTaskDelay(pdMS_TO_TICKS(100));
    }
}

void app_main()
{
    ESP_ERROR_CHECK(nvs_flash_init());

    ESP_LOGI(TAG, "ESP_WIFI_MODE_AP");
    mytask_init();
    ssd1306_start();

    wifi_init_softap();
}
