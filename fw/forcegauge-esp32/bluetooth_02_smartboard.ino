#include <NimBLEDevice.h>

#define SMARTBOARD_SERVICE_UUID                 "0000403d-0000-1000-8000-00805f9b34fb"
#define SMARTBOARD_NOTIFY_CHARACTERISTIC_UUID   "00001583-0000-1000-8000-00805f9b34fb"
#define SMARTBOARD_WRITE_CHARACTERISTIC_UUID    "00002a29-0000-1000-8000-00805f9b34fb"
//20 ms -> 50Hz
#define SMARTBOARD_INTERVAL_MS  20     

const uint8_t SMARTBOARD_SCAN_RESPONSE_DATA[] = {
    17,
    0x07,
    0xfb, 0x34, 0x9b, 0x5f, 0x80, 0x00, 0x00, 0x80, 0x00, 0x10, 0x00, 0x00, 0x3d, 0x40, 0x00, 0x00
};


class SmartBoardCharacteristicCallbacks : public NimBLECharacteristicCallbacks {
    void onWrite(NimBLECharacteristic* pCharacteristic) {
        std::string value = pCharacteristic->getValue();
        Serial.print("Received value: ");
        Serial.println(value.c_str());

        // if (value.length() > 0) {
        //     uint8_t cmd = value[0];
        //     handleCommand(cmd);
        // }
    }
};


void bluetoothTaskSmartBoard(void *parameter)
{
    NimBLEDevice::init("SMARTBOARD PRO");
    pServer = NimBLEDevice::createServer();
    pServer->setCallbacks(new MyServerCallbacks());

    NimBLEService* pService = pServer->createService(NimBLEUUID(SMARTBOARD_SERVICE_UUID));

    pNotifyCharacteristic = pService->createCharacteristic(
        NimBLEUUID(SMARTBOARD_NOTIFY_CHARACTERISTIC_UUID),
        NIMBLE_PROPERTY::NOTIFY
    );

    pWriteCharacteristic = pService->createCharacteristic(
        NimBLEUUID(SMARTBOARD_WRITE_CHARACTERISTIC_UUID),
        NIMBLE_PROPERTY::WRITE
    );
    pWriteCharacteristic->setCallbacks(new SmartBoardCharacteristicCallbacks());

    pService->start();

    NimBLEAdvertisementData oAdvertisementData;
    NimBLEAdvertisementData oScanResponseData;

    oScanResponseData.addData(std::string((const char*)SMARTBOARD_SCAN_RESPONSE_DATA, sizeof(SMARTBOARD_SCAN_RESPONSE_DATA)));

    std::vector<uint8_t> adv_data = advertising_data("SMARTBOARD PRO");
    oAdvertisementData.addData(std::string((const char*)adv_data.data(), adv_data.size()));

    NimBLEAdvertising* pAdvertising = NimBLEDevice::getAdvertising();
    pAdvertising->setScanResponse(true);
    pAdvertising->setAdvertisementData(oAdvertisementData);
    pAdvertising->setScanResponseData(oScanResponseData);
    pAdvertising->start();

    Serial.println("Waiting for a client connection...");

    
    long currentMillis = millis();
    long previousMillis = 0;
    
    dataStruct data;

    while(1)
    {
       // Handle device connection/disconnection
        if (deviceConnected && !oldDeviceConnected) {
            oldDeviceConnected = deviceConnected;
        }
        if (!deviceConnected && oldDeviceConnected) {
            delay(500); // Give the BLE stack the chance to clean up
            pServer->startAdvertising(); // Restart advertising
            oldDeviceConnected = deviceConnected;
        }

        if (deviceConnected) {
            currentMillis = millis();
            if (currentMillis - previousMillis >= SMARTBOARD_INTERVAL_MS) 
            {
                previousMillis = currentMillis;
                while (bluetoothBuffer.lockedPop(data)){};
                float weight = (data.v - config.offset) * config.scale;
                int16_t w = (int16_t)(weight * 10.0);
                uint8_t payload[2];
                memcpy(&payload[0], &w, sizeof(int16_t));
                pNotifyCharacteristic->setValue(payload, sizeof(payload));
                pNotifyCharacteristic->notify();
            }
        }
        delay(5);
    }
    
}
