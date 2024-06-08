#!/bin/bash

SCRIPT=$(readlink -f $0)
SCRIPT_DIR=`dirname $SCRIPT`

cd "$SCRIPT_DIR/.."

ARDUINO_OUTPUT_DIR=./build/
CONFIG_FILE="--config-file $SCRIPT_DIR/arduino-cli.yaml"

#TODO: This value should be read from partitions.csv
BUILD_PROPERTIES="--build-property upload.maximum_size=1572864"

# Update boards
arduino-cli core update-index $CONFIG_FILE
arduino-cli core install esp32:esp32 $CONFIG_FILE 

# Install libraries
#TODO: should make a versions file..
#Adafruit_BusIO - https://github.com/adafruit/Adafruit_BusIO
#Adafruit GFX Library - https://github.com/adafruit/Adafruit-GFX-Library
#Adafruit SSD1306 - https://github.com/adafruit/Adafruit_SSD1306
#ArduinoJson - https://arduinojson.org/
#RingBuffer - https://github.com/Locoduino/RingBuffer
#arduinoWebSockets - https://github.com/Links2004/arduinoWebSockets

# Used library         Version Path
# WiFi                 2.0.0   /home/beni/.arduino15/packages/esp32/hardware/esp32/3.0.1/libraries/WiFi
# Networking           1.0.0   /home/beni/.arduino15/packages/esp32/hardware/esp32/3.0.1/libraries/Network
# WebServer            2.0.0   /home/beni/.arduino15/packages/esp32/hardware/esp32/3.0.1/libraries/WebServer
# FS                   2.0.0   /home/beni/.arduino15/packages/esp32/hardware/esp32/3.0.1/libraries/FS
# ESPmDNS              2.0.0   /home/beni/.arduino15/packages/esp32/hardware/esp32/3.0.1/libraries/ESPmDNS
# WebSockets           2.4.1   /home/beni/Arduino/libraries/WebSockets
# NetworkClientSecure  2.0.0   /home/beni/.arduino15/packages/esp32/hardware/esp32/3.0.1/libraries/NetworkClientSecure
# Update               2.0.0   /home/beni/.arduino15/packages/esp32/hardware/esp32/3.0.1/libraries/Update
# DNSServer            2.0.0   /home/beni/.arduino15/packages/esp32/hardware/esp32/3.0.1/libraries/DNSServer
# ESP32 Async UDP      2.0.0   /home/beni/.arduino15/packages/esp32/hardware/esp32/3.0.1/libraries/AsyncUDP
# RingBuffer           1.0.5   /home/beni/Arduino/libraries/RingBuffer
# SPIFFS               2.0.0   /home/beni/.arduino15/packages/esp32/hardware/esp32/3.0.1/libraries/SPIFFS
# ArduinoJson          7.0.4   /home/beni/Arduino/libraries/ArduinoJson
# NimBLE-Arduino       1.4.1   /home/beni/Arduino/libraries/NimBLE-Arduino
# Wire                 2.0.0   /home/beni/.arduino15/packages/esp32/hardware/esp32/3.0.1/libraries/Wire
# Adafruit GFX Library 1.11.9  /home/beni/Arduino/libraries/Adafruit_GFX_Library
# Adafruit BusIO       1.16.1  /home/beni/Arduino/libraries/Adafruit_BusIO
# SPI                  2.0.0   /home/beni/.arduino15/packages/esp32/hardware/esp32/3.0.1/libraries/SPI
# Adafruit SSD1306     2.5.10  /home/beni/Arduino/libraries/Adafruit_SSD1306
# HTTPClient           2.0.0   /home/beni/.arduino15/packages/esp32/hardware/esp32/3.0.1/libraries/HTTPClient

# Used platform Version Path
# esp32:esp32   3.0.1   /home/beni/.arduino15/packages/esp32/hardware/esp32/3.0.1


arduino-cli lib install "Adafruit GFX Library" "Adafruit SSD1306" "ArduinoJson" "RingBuffer" "NimBLE-Arduino" $CONFIG_FILE
arduino-cli lib install --git-url https://github.com/Links2004/arduinoWebSockets $CONFIG_FILE

# Compile
#arduino-cli compile -v -b esp32:esp32:esp32c3 --build-cache-path ./build-cache --output-dir=$ARDUINO_OUTPUT_DIR $CONFIG_FILE $BUILD_PROPERTIES
arduino-cli compile -b esp32:esp32:esp32c3 --output-dir=$ARDUINO_OUTPUT_DIR $CONFIG_FILE $BUILD_PROPERTIES

PACKAGES_DIR=`arduino-cli core list -v | grep "Loading hardware from" | awk '{print $5}'`
MKSPIFFS_VER=`ls $PACKAGES_DIR/esp32/tools/mkspiffs/`
MKSPIFF="$PACKAGES_DIR/esp32/tools/mkspiffs/$MKSPIFFS_VER/mkspiffs"
echo "Making spiffs files"
$MKSPIFF -c ./data --size 0x090000 --page 256 --block 4096 -- ./build/forcegauge-esp32.info.spiffs.bin

