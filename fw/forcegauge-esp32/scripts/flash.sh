#!/bin/bash

sudo python3 /home/beni/.arduino15/packages/esp32/tools/esptool_py/3.3.0/esptool.py \
--chip esp32c3 \
--port /dev/ttyUSB14 \
--baud 460800 \
--before default_reset \
--after hard_reset write_flash \
-z --flash_mode dio \
--flash_freq 80m \
--flash_size 4MB \
0x0 ./build/forcegauge-esp32.ino.bootloader.bin \
0x8000 ./build/forcegauge-esp32.ino.partitions.bin \
0xe000 /home/beni/.arduino15/packages/esp32/hardware/esp32/2.0.3/tools/partitions/boot_app0.bin \
0x10000 ./build/forcegauge-esp32.ino.bin \
0x310000 ./build/forcegauge-esp32.info.spiffs.bin
