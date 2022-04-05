#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "esp_log.h"

#include "ssd1306.h"
#include "font8x8_basic.h"

#define SCL_PIN 5
#define SDA_PIN 4
#define RESET_PIN -1

/*
 You have to set this config value with menuconfig
 CONFIG_INTERFACE

 for i2c
 CONFIG_MODEL
 CONFIG_SDA_GPIO
 CONFIG_SCL_GPIO
 CONFIG_RESET_GPIO

 for SPI
 CONFIG_CS_GPIO
 CONFIG_DC_GPIO
 CONFIG_RESET_GPIO
*/

#define tag "SSD1306"

void ssd1306_test_task(void *arg)
{
	SSD1306_t dev;
	int center, top, bottom;
	char lineChar[20];

	ESP_LOGI(tag, "INTERFACE is i2c");
	ESP_LOGI(tag, "CONFIG_SDA_GPIO=%d", SDA_PIN);
	ESP_LOGI(tag, "CONFIG_SCL_GPIO=%d", SCL_PIN);
	ESP_LOGI(tag, "CONFIG_RESET_GPIO=%d", RESET_PIN);
	i2c_master_init(&dev, SDA_PIN, SCL_PIN, RESET_PIN);

	// dev._flip = true;
	// ESP_LOGW(tag, "Flip upside down");

	ESP_LOGI(tag, "Panel is 128x64");
	ssd1306_init(&dev, 128, 64);

	ssd1306_clear_screen(&dev, false);
	ssd1306_contrast(&dev, 0xff);

	top = 2;
	center = 3;
	bottom = 8;
	int cntr = 0;
	char buff[64];
	uint32_t now = xTaskGetTickCount();
	uint32_t lastUpdate = xTaskGetTickCount();

	while (1)
	{
		now = xTaskGetTickCount();
		int diff = now - lastUpdate;
		if (diff >= pdMS_TO_TICKS(50))
		{
			lastUpdate = now;
			cntr++;
			sprintf(buff, "Cntr: %d\n", cntr);
			ssd1306_display_text(&dev, 0, buff, strlen(buff), false);
			ssd1306_display_text(&dev, 1, buff, strlen(buff), false);
			ssd1306_display_text(&dev, 2, buff, strlen(buff), false);
			ssd1306_display_text(&dev, 3, buff, strlen(buff), false);
			ssd1306_display_text(&dev, 4, buff, strlen(buff), false);
			ssd1306_display_text(&dev, 5, buff, strlen(buff), false);
			ssd1306_display_text(&dev, 6, buff, strlen(buff), false);
			ssd1306_display_text(&dev, 7, buff, strlen(buff), false);
		}
		vTaskDelay(pdMS_TO_TICKS(1));
	}

	ssd1306_display_text(&dev, 0, "SSD1306 128x64", 14, false);
	ssd1306_display_text(&dev, 0, "SSD1306 128x64", 14, false);
	ssd1306_display_text(&dev, 1, "ABCDEFGHIJKLMNOP", 16, false);
	ssd1306_display_text(&dev, 2, "abcdefghijklmnop", 16, false);
	ssd1306_display_text(&dev, 3, "Hello World!!", 13, false);
	ssd1306_clear_line(&dev, 4, true);
	ssd1306_clear_line(&dev, 5, true);
	ssd1306_clear_line(&dev, 6, true);
	ssd1306_clear_line(&dev, 7, true);
	ssd1306_display_text(&dev, 4, "SSD1306 128x64", 14, true);
	ssd1306_display_text(&dev, 5, "ABCDEFGHIJKLMNOP", 16, true);
	ssd1306_display_text(&dev, 6, "abcdefghijklmnop", 16, true);
	ssd1306_display_text(&dev, 7, "Hello World!!", 13, true);

	vTaskDelay(3000 / portTICK_PERIOD_MS);

	// Display Count Down
	uint8_t image[24];
	memset(image, 0, sizeof(image));
	ssd1306_display_image(&dev, top, (6 * 8 - 1), image, sizeof(image));
	ssd1306_display_image(&dev, top + 1, (6 * 8 - 1), image, sizeof(image));
	ssd1306_display_image(&dev, top + 2, (6 * 8 - 1), image, sizeof(image));
	for (int font = 0x39; font > 0x30; font--)
	{
		memset(image, 0, sizeof(image));
		ssd1306_display_image(&dev, top + 1, (7 * 8 - 1), image, 8);
		memcpy(image, font8x8_basic_tr[font], 8);
		if (dev._flip)
			ssd1306_flip(image, 8);
		ssd1306_display_image(&dev, top + 1, (7 * 8 - 1), image, 8);
		vTaskDelay(1000 / portTICK_PERIOD_MS);
	}

	// Scroll Up
	ssd1306_clear_screen(&dev, false);
	ssd1306_contrast(&dev, 0xff);
	ssd1306_display_text(&dev, 0, "---Scroll  UP---", 16, true);
	// ssd1306_software_scroll(&dev, 7, 1);
	ssd1306_software_scroll(&dev, (dev._pages - 1), 1);
	for (int line = 0; line < bottom + 10; line++)
	{
		lineChar[0] = 0x01;
		sprintf(&lineChar[1], " Line %02d", line);
		ssd1306_scroll_text(&dev, lineChar, strlen(lineChar), false);
		vTaskDelay(500 / portTICK_PERIOD_MS);
	}
	vTaskDelay(3000 / portTICK_PERIOD_MS);

	// Scroll Down
	ssd1306_clear_screen(&dev, false);
	ssd1306_contrast(&dev, 0xff);
	ssd1306_display_text(&dev, 0, "--Scroll  DOWN--", 16, true);
	// ssd1306_software_scroll(&dev, 1, 7);
	ssd1306_software_scroll(&dev, 1, (dev._pages - 1));
	for (int line = 0; line < bottom + 10; line++)
	{
		lineChar[0] = 0x02;
		sprintf(&lineChar[1], " Line %02d", line);
		ssd1306_scroll_text(&dev, lineChar, strlen(lineChar), false);
		vTaskDelay(500 / portTICK_PERIOD_MS);
	}
	vTaskDelay(3000 / portTICK_PERIOD_MS);

	// Page Down
	ssd1306_clear_screen(&dev, false);
	ssd1306_contrast(&dev, 0xff);
	ssd1306_display_text(&dev, 0, "---Page	DOWN---", 16, true);
	ssd1306_software_scroll(&dev, 1, (dev._pages - 1));
	for (int line = 0; line < bottom + 10; line++)
	{
		// if ( (line % 7) == 0) ssd1306_scroll_clear(&dev);
		if ((line % (dev._pages - 1)) == 0)
			ssd1306_scroll_clear(&dev);
		lineChar[0] = 0x02;
		sprintf(&lineChar[1], " Line %02d", line);
		ssd1306_scroll_text(&dev, lineChar, strlen(lineChar), false);
		vTaskDelay(500 / portTICK_PERIOD_MS);
	}
	vTaskDelay(3000 / portTICK_PERIOD_MS);

	// Horizontal Scroll
	ssd1306_clear_screen(&dev, false);
	ssd1306_contrast(&dev, 0xff);
	ssd1306_display_text(&dev, center, "Horizontal", 10, false);
	ssd1306_hardware_scroll(&dev, SCROLL_RIGHT);
	vTaskDelay(5000 / portTICK_PERIOD_MS);
	ssd1306_hardware_scroll(&dev, SCROLL_LEFT);
	vTaskDelay(5000 / portTICK_PERIOD_MS);
	ssd1306_hardware_scroll(&dev, SCROLL_STOP);

	// Vertical Scroll
	ssd1306_clear_screen(&dev, false);
	ssd1306_contrast(&dev, 0xff);
	ssd1306_display_text(&dev, center, "Vertical", 8, false);
	ssd1306_hardware_scroll(&dev, SCROLL_DOWN);
	vTaskDelay(5000 / portTICK_PERIOD_MS);
	ssd1306_hardware_scroll(&dev, SCROLL_UP);
	vTaskDelay(5000 / portTICK_PERIOD_MS);
	ssd1306_hardware_scroll(&dev, SCROLL_STOP);

	// Invert
	ssd1306_clear_screen(&dev, true);
	ssd1306_contrast(&dev, 0xff);
	ssd1306_display_text(&dev, center, "  Good Bye!!", 12, true);
	vTaskDelay(5000 / portTICK_PERIOD_MS);

	// Fade Out
	ssd1306_fadeout(&dev);
}

void ssd1306_start(void)
{
	xTaskCreate(&ssd1306_test_task, "ssd1306_test_task", 2048, NULL, 0, NULL);
	// xTaskCreate(&task_ssd1306_contrast, "ssid1306_contrast", 2048, NULL, 6, NULL);
	// xTaskCreate(&task_ssd1306_scroll, "ssid1306_scroll", 2048, NULL, 6, NULL);
}
