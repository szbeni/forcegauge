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

arduino-cli lib install "Adafruit GFX Library" "Adafruit SSD1306" "ArduinoJson" "RingBuffer" $CONFIG_FILE
arduino-cli lib install --git-url https://github.com/Links2004/arduinoWebSockets $CONFIG_FILE

# Compile
arduino-cli compile -v -b esp32:esp32:esp32c3 --output-dir=$ARDUINO_OUTPUT_DIR $CONFIG_FILE $BUILD_PROPERTIES

PACKAGES_DIR=`arduino-cli core list -v | grep "Loading hardware from" | awk '{print $5}'`
MKSPIFFS_VER=`ls $PACKAGES_DIR/esp32/tools/mkspiffs/`
MKSPIFF="$PACKAGES_DIR/esp32/tools/mkspiffs/$MKSPIFFS_VER/mkspiffs"
echo "Making spiffs files"
$MKSPIFF -c ./data --start 0x090000 --page 256 --block 4096 -- ./build/forcegauge-esp32.info.spiffs.bin

