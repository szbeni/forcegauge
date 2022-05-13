#!/bin/bash
set -e
cd "$(dirname "$0")/.."


DATE=$(date --iso-8601=seconds | tr : - | tr T _ | grep -oP '^.*\d\+' | grep -oP '^.*\d')
mkdir -p ./build/$DATE

set ARDUINO_OUTPUT_DIR=./build/$DATE
set ARDUINO_LIBRARY_ENABLE_UNSAFE_INSTALL=true

ESP32_URL=https://raw.githubusercontent.com/espressif/arduino-esp32/gh-pages/package_esp32_index.json
GLOBAL_FLAGS= --additional-urls $ESP32_URL


arduino-cli core update-index $GLOBAL_FLAGS
arduino-cli core install esp32:esp32 --additional-urls $GLOBAL_FLAGS

#Adafruit_BusIO - https://github.com/adafruit/Adafruit_BusIO
#Adafruit GFX Library - https://github.com/adafruit/Adafruit-GFX-Library
#Adafruit SSD1306 - https://github.com/adafruit/Adafruit_SSD1306
#ArduinoJson - https://arduinojson.org/
#RingBuffer - https://github.com/Locoduino/RingBuffer
#arduinoWebSockets - https://github.com/Links2004/arduinoWebSockets

arduino-cli lib install "Adafruit GFX Library" "Adafruit SSD1306" "ArduinoJson" "RingBuffer"
arduino-cli lib install --git-url https://github.com/Links2004/arduinoWebSockets

exec arduino-cli compile -v -b esp32:esp32:esp32c3 --output-dir=$ARDUINO_OUTPUT_DIR
