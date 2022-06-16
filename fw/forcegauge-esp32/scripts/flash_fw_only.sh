#!/bin/bash

sudo python3 /home/beni/.arduino15/packages/esp32/tools/esptool_py/3.3.0/esptool.py \
--chip esp32c3 \
--port /dev/ttyUSB0 \
--baud 960000 \
--before default_reset \
--after hard_reset write_flash \
-z --flash_mode dio \
--flash_freq 80m \
--flash_size 4MB \
0x10000 ./build/forcegauge-esp32.ino.bin 
