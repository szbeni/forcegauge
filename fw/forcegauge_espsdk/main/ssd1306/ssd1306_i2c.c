#include <string.h>

#include "freertos/FreeRTOS.h"
#include "freertos/task.h"

#include "ssd1306/software_i2c.h"
#include "driver/i2c.h"
#include "esp_log.h"

#include "ssd1306.h"

#define tag "SSD1306"

#define CONFIG_OFFSETX 0

#define I2C_MASTER_FREQ_HZ 400000 /*!< I2C master clock frequency. no higher than 1MHz for now */

void i2c_master_init(SSD1306_t *dev, int16_t sda, int16_t scl, int16_t reset)
{
	sw_i2c_init(sda, scl);

	if (reset >= 0)
	{
		// gpio_pad_select_gpio(reset);
		// gpio_reset_pin(reset);
		gpio_set_direction(reset, GPIO_MODE_OUTPUT);
		gpio_set_level(reset, 0);
		vTaskDelay(50 / portTICK_PERIOD_MS);
		gpio_set_level(reset, 1);
	}
	dev->_address = I2CAddress;
	dev->_flip = false;
}

void i2c_init(SSD1306_t *dev, int width, int height)
{
	dev->_width = width;
	dev->_height = height;
	dev->_pages = 8;
	if (dev->_height == 32)
		dev->_pages = 4;

	sw_i2c_master_start();
	sw_i2c_master_write_byte((dev->_address << 1) | I2C_MASTER_WRITE);
	sw_i2c_master_write_byte(OLED_CONTROL_BYTE_CMD_STREAM);
	sw_i2c_master_write_byte(OLED_CMD_DISPLAY_OFF);	  // AE
	sw_i2c_master_write_byte(OLED_CMD_SET_MUX_RATIO); // A8
	if (dev->_height == 64)
		sw_i2c_master_write_byte(0x3F);
	if (dev->_height == 32)
		sw_i2c_master_write_byte(0x1F);
	sw_i2c_master_write_byte(OLED_CMD_SET_DISPLAY_OFFSET); // D3
	sw_i2c_master_write_byte(0x00);
	sw_i2c_master_write_byte(OLED_CONTROL_BYTE_DATA_STREAM); // 40
	// sw_i2c_master_write_byte( OLED_CMD_SET_SEGMENT_REMAP);		// A1
	if (dev->_flip)
	{
		sw_i2c_master_write_byte(OLED_CMD_SET_SEGMENT_REMAP_0); // A0
	}
	else
	{
		sw_i2c_master_write_byte(OLED_CMD_SET_SEGMENT_REMAP_1); // A1
	}
	sw_i2c_master_write_byte(OLED_CMD_SET_COM_SCAN_MODE);	// C8
	sw_i2c_master_write_byte(OLED_CMD_SET_DISPLAY_CLK_DIV); // D5
	sw_i2c_master_write_byte(0x80);
	sw_i2c_master_write_byte(OLED_CMD_SET_COM_PIN_MAP); // DA
	if (dev->_height == 64)
		sw_i2c_master_write_byte(0x12);
	if (dev->_height == 32)
		sw_i2c_master_write_byte(0x02);
	sw_i2c_master_write_byte(OLED_CMD_SET_CONTRAST); // 81
	sw_i2c_master_write_byte(0xFF);
	sw_i2c_master_write_byte(OLED_CMD_DISPLAY_RAM);		  // A4
	sw_i2c_master_write_byte(OLED_CMD_SET_VCOMH_DESELCT); // DB
	sw_i2c_master_write_byte(0x40);
	sw_i2c_master_write_byte(OLED_CMD_SET_MEMORY_ADDR_MODE); // 20
	// sw_i2c_master_write_byte( OLED_CMD_SET_HORI_ADDR_MODE);	// 00
	sw_i2c_master_write_byte(OLED_CMD_SET_PAGE_ADDR_MODE); // 02
	// Set Lower Column Start Address for Page Addressing Mode
	sw_i2c_master_write_byte(0x00);
	// Set Higher Column Start Address for Page Addressing Mode
	sw_i2c_master_write_byte(0x10);
	sw_i2c_master_write_byte(OLED_CMD_SET_CHARGE_PUMP); // 8D
	sw_i2c_master_write_byte(0x14);
	sw_i2c_master_write_byte(OLED_CMD_DEACTIVE_SCROLL); // 2E
	sw_i2c_master_write_byte(OLED_CMD_DISPLAY_NORMAL);	// A6
	sw_i2c_master_write_byte(OLED_CMD_DISPLAY_ON);		// AF

	sw_i2c_master_stop();
}

void i2c_display_image(SSD1306_t *dev, int page, int seg, uint8_t *images, int width)
{

	if (page >= dev->_pages)
		return;
	if (seg >= dev->_width)
		return;

	int _seg = seg + CONFIG_OFFSETX;
	uint8_t columLow = _seg & 0x0F;
	uint8_t columHigh = (_seg >> 4) & 0x0F;

	int _page = page;
	if (dev->_flip)
	{
		_page = (dev->_pages - page) - 1;
	}

	sw_i2c_master_start();
	sw_i2c_master_write_byte((dev->_address << 1) | I2C_MASTER_WRITE);

	sw_i2c_master_write_byte(OLED_CONTROL_BYTE_CMD_STREAM);
	// Set Lower Column Start Address for Page Addressing Mode
	sw_i2c_master_write_byte((0x00 + columLow));
	// Set Higher Column Start Address for Page Addressing Mode
	sw_i2c_master_write_byte((0x10 + columHigh));
	// Set Page Start Address for Page Addressing Mode
	sw_i2c_master_write_byte(0xB0 | _page);

	sw_i2c_master_stop();

	sw_i2c_master_start();
	sw_i2c_master_write_byte((dev->_address << 1) | I2C_MASTER_WRITE);

	sw_i2c_master_write_byte(OLED_CONTROL_BYTE_DATA_STREAM);
	sw_i2c_master_write(images, width);

	sw_i2c_master_stop();
}

void i2c_contrast(SSD1306_t *dev, int contrast)
{
	int _contrast = contrast;
	if (contrast < 0x0)
		_contrast = 0;
	if (contrast > 0xFF)
		_contrast = 0xFF;

	sw_i2c_master_start();
	sw_i2c_master_write_byte((dev->_address << 1) | I2C_MASTER_WRITE);
	sw_i2c_master_write_byte(OLED_CONTROL_BYTE_CMD_STREAM);
	sw_i2c_master_write_byte(OLED_CMD_SET_CONTRAST); // 81
	sw_i2c_master_write_byte(_contrast);
	sw_i2c_master_stop();
}

void i2c_hardware_scroll(SSD1306_t *dev, ssd1306_scroll_type_t scroll)
{

	sw_i2c_master_start();

	sw_i2c_master_write_byte((dev->_address << 1) | I2C_MASTER_WRITE);
	sw_i2c_master_write_byte(OLED_CONTROL_BYTE_CMD_STREAM);

	if (scroll == SCROLL_RIGHT)
	{
		sw_i2c_master_write_byte(OLED_CMD_HORIZONTAL_RIGHT); // 26
		sw_i2c_master_write_byte(0x00);						 // Dummy byte
		sw_i2c_master_write_byte(0x00);						 // Define start page address
		sw_i2c_master_write_byte(0x07);						 // Frame frequency
		sw_i2c_master_write_byte(0x07);						 // Define end page address
		sw_i2c_master_write_byte(0x00);						 //
		sw_i2c_master_write_byte(0xFF);						 //
		sw_i2c_master_write_byte(OLED_CMD_ACTIVE_SCROLL);	 // 2F
	}

	if (scroll == SCROLL_LEFT)
	{
		sw_i2c_master_write_byte(OLED_CMD_HORIZONTAL_LEFT); // 27
		sw_i2c_master_write_byte(0x00);						// Dummy byte
		sw_i2c_master_write_byte(0x00);						// Define start page address
		sw_i2c_master_write_byte(0x07);						// Frame frequency
		sw_i2c_master_write_byte(0x07);						// Define end page address
		sw_i2c_master_write_byte(0x00);						//
		sw_i2c_master_write_byte(0xFF);						//
		sw_i2c_master_write_byte(OLED_CMD_ACTIVE_SCROLL);	// 2F
	}

	if (scroll == SCROLL_DOWN)
	{
		sw_i2c_master_write_byte(OLED_CMD_CONTINUOUS_SCROLL); // 29
		sw_i2c_master_write_byte(0x00);						  // Dummy byte
		sw_i2c_master_write_byte(0x00);						  // Define start page address
		sw_i2c_master_write_byte(0x07);						  // Frame frequency
		// sw_i2c_master_write_byte( 0x01); // Define end page address
		sw_i2c_master_write_byte(0x00); // Define end page address
		sw_i2c_master_write_byte(0x3F); // Vertical scrolling offset

		sw_i2c_master_write_byte(OLED_CMD_VERTICAL); // A3
		sw_i2c_master_write_byte(0x00);
		if (dev->_height == 64)
			// sw_i2c_master_write_byte( 0x7F);
			sw_i2c_master_write_byte(0x40);
		if (dev->_height == 32)
			sw_i2c_master_write_byte(0x20);
		sw_i2c_master_write_byte(OLED_CMD_ACTIVE_SCROLL); // 2F
	}

	if (scroll == SCROLL_UP)
	{
		sw_i2c_master_write_byte(OLED_CMD_CONTINUOUS_SCROLL); // 29
		sw_i2c_master_write_byte(0x00);						  // Dummy byte
		sw_i2c_master_write_byte(0x00);						  // Define start page address
		sw_i2c_master_write_byte(0x07);						  // Frame frequency
		// sw_i2c_master_write_byte( 0x01); // Define end page address
		sw_i2c_master_write_byte(0x00); // Define end page address
		sw_i2c_master_write_byte(0x01); // Vertical scrolling offset

		sw_i2c_master_write_byte(OLED_CMD_VERTICAL); // A3
		sw_i2c_master_write_byte(0x00);
		if (dev->_height == 64)
			// sw_i2c_master_write_byte( 0x7F);
			sw_i2c_master_write_byte(0x40);
		if (dev->_height == 32)
			sw_i2c_master_write_byte(0x20);
		sw_i2c_master_write_byte(OLED_CMD_ACTIVE_SCROLL); // 2F
	}

	if (scroll == SCROLL_STOP)
	{
		sw_i2c_master_write_byte(OLED_CMD_DEACTIVE_SCROLL); // 2E
	}

	sw_i2c_master_stop();
}
