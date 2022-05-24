#!/bin/bash

SCRIPT=$(readlink -f $0)
SCRIPT_DIR=`dirname $SCRIPT`

cd "$SCRIPT_DIR/.."

#DATE=$(date --iso-8601=seconds | tr : - | tr T _ | grep -oP '^.*\d\+' | grep -oP '^.*\d')
#mkdir -p ./build/$DATE
#ARDUINO_OUTPUT_DIR=./build/$DATE
ARDUINO_OUTPUT_DIR=./build/
CONFIG_FILE="--config-file $SCRIPT_DIR/arduino-cli.yaml"

# # Update boards
# arduino-cli core update-index $CONFIG_FILE
# arduino-cli core install esp32:esp32 $CONFIG_FILE 

# # Install libraries
# #Adafruit_BusIO - https://github.com/adafruit/Adafruit_BusIO
# #Adafruit GFX Library - https://github.com/adafruit/Adafruit-GFX-Library
# #Adafruit SSD1306 - https://github.com/adafruit/Adafruit_SSD1306
# #ArduinoJson - https://arduinojson.org/
# #RingBuffer - https://github.com/Locoduino/RingBuffer
# #arduinoWebSockets - https://github.com/Links2004/arduinoWebSockets

# arduino-cli lib install "Adafruit GFX Library" "Adafruit SSD1306" "ArduinoJson" "RingBuffer" $CONFIG_FILE
# arduino-cli lib install --git-url https://github.com/Links2004/arduinoWebSockets $CONFIG_FILE

# Compile
arduino-cli compile -b esp32:esp32:esp32c3 --output-dir=$ARDUINO_OUTPUT_DIR $CONFIG_FILE


#Upload via serial
# python3 /home/beni/.arduino15/packages/esp32/tools/esptool_py/3.3.0/esptool.py --chip esp32c3 --port /dev/ttyUSB0 --baud 460800 --before default_reset --after hard_reset write_flash -z --flash_mode dio --flash_freq 80m --flash_size 4MB 0x0 ./build/forcegauge-esp32.ino.bootloader.bin 0x8000 ./build/forcegauge-esp32.ino.partitions.bin 0xe000 /home/beni/.arduino15/packages/esp32/hardware/esp32/2.0.3/tools/partitions/boot_app0.bin 0x10000 ./build/forcegauge-esp32.ino.bin 

#Upload via HTTP
#curl -F 'update=@./build/forcegauge-esp32.ino.bin' http://10.1.1.133/update

#
#/home/beni/.arduino15/packages/esp32/tools/mkspiffs/0.2.3/mkspiffs -c ./data --size 0x090000 --page 256 --block 4096 -- ./build/forcegauge-esp32.info.spiffs.bin
#esptool.py --chip esp32c3 --port /dev/ttyUSB0 --baud 460800 write_flash 0x310000 ./build/forcegauge-esp32.info.spiffs.bin
