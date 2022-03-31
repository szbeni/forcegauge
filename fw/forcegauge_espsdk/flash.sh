
cd ./build
esptool.py --chip esp8266 -b 460800 write_flash --flash_mode dio --flash_freq 40m --flash_size 2MB 0x8000 partition_table/partition-table.bin 0x0 bootloader/bootloader.bin 0x10000 wifi_softAP.bin

cd ..

make monitor