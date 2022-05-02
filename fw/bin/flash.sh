esptool.py --chip esp8266 --port /dev/ttyUSB0 --baud 600000 --before default_reset --after hard_reset write_flash 0x0 forcegauge.ino.bin 0x200000 forcegauge.spiffs.bin
