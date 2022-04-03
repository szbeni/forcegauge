#include "software_i2c.h"

void i2c_scan_task(void *params)
{
    while (1)
    {
        i2c_master_scan();
        vTaskDelay(10000 / portTICK_RATE_MS);
    }

    vTaskDelete(NULL);
}

void software_i2c_test_init(void)
{
    xTaskCreate(&i2c_scan_task, "I2C scan", 2048, NULL, 6, NULL);
}