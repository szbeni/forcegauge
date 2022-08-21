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

# Platform esp32:esp32@2.0.4 already installed
# Downloading Adafruit BusIO@1.13.2...
# Adafruit BusIO@1.13.2 downloaded                                                                                                               
# Installing Adafruit BusIO@1.13.2...
# Replacing Adafruit_BusIO@1.12.0 with Adafruit BusIO@1.13.2...
# Installed Adafruit BusIO@1.13.2
# Downloading Adafruit GFX Library@1.11.3...
# Adafruit GFX Library@1.11.3 already downloaded
# Installing Adafruit GFX Library@1.11.3...
# Already installed Adafruit GFX Library@1.11.3
# Downloading Adafruit BusIO@1.13.2...
# Adafruit BusIO@1.13.2 already downloaded
# Installing Adafruit BusIO@1.13.2...
# Already installed Adafruit BusIO@1.13.2
# Downloading Adafruit SSD1306@2.5.7...
# Adafruit SSD1306@2.5.7 downloaded                                                                                                              
# Installing Adafruit SSD1306@2.5.7...
# Replacing Adafruit_SSD1306@2.5.6 with Adafruit SSD1306@2.5.7...
# Installed Adafruit SSD1306@2.5.7
# Downloading Adafruit GFX Library@1.11.3...
# Adafruit GFX Library@1.11.3 already downloaded
# Installing Adafruit GFX Library@1.11.3...
# Already installed Adafruit GFX Library@1.11.3
# Downloading ArduinoJson@6.19.4...
# ArduinoJson@6.19.4 already downloaded
# Installing ArduinoJson@6.19.4...
# Already installed ArduinoJson@6.19.4
# Downloading RingBuffer@1.0.3...
# RingBuffer@1.0.3 already downloaded
# Installing RingBuffer@1.0.3...
# Already installed RingBuffer@1.0.3


arduino-cli lib install "Adafruit GFX Library" "Adafruit SSD1306" "ArduinoJson" "RingBuffer" $CONFIG_FILE
arduino-cli lib install --git-url https://github.com/Links2004/arduinoWebSockets $CONFIG_FILE

# Compile
arduino-cli compile -b esp32:esp32:esp32c3 --output-dir=$ARDUINO_OUTPUT_DIR $CONFIG_FILE $BUILD_PROPERTIES

PACKAGES_DIR=`arduino-cli core list -v | grep "Loading hardware from" | awk '{print $5}'`
MKSPIFFS_VER=`ls $PACKAGES_DIR/esp32/tools/mkspiffs/`
MKSPIFF="$PACKAGES_DIR/esp32/tools/mkspiffs/$MKSPIFFS_VER/mkspiffs"
echo "Making spiffs files"
$MKSPIFF -c ./data --size 0x090000 --page 256 --block 4096 -- ./build/forcegauge-esp32.info.spiffs.bin

