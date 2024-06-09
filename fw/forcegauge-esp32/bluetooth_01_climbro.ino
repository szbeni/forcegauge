#include <NimBLEDevice.h>

#define CLIMBRO_SERVICE_UUID                 "49535343-fe7d-4ae5-8fa9-9fafd205e455"
#define CLIMBRO_NOTIFY_CHARACTERISTIC_UUID   "49535343-1e4d-4bd9-ba61-23c647249616"
#define CLIMBRO_WRITE_CHARACTERISTIC_UUID    "49535343-8841-43f4-a8d4-ecbe34729bb3"

#define  CLIMBRO_SENS_DATA 245
#define  CLIMBRO_BAT_DATA 240

const long batteryReportIntervalMs = 10000; //10 sec

class ClimbroCharacteristicCallbacks : public NimBLECharacteristicCallbacks {
    void onWrite(NimBLECharacteristic* pCharacteristic) {
        std::string value = pCharacteristic->getValue();
        Serial.print("Received value: ");
        Serial.println(value.c_str());

        if (value.length() > 0) {
            uint8_t cmd = value[0];
            handleCommand(cmd);
        }
    }

    void handleCommand(uint8_t cmd) {
        switch (cmd) {
            default:
                Serial.print("Unknown command received: ");
                Serial.println(cmd);
                break;
        }
    }
};

void bluetoothTaskClimbro(void *parameter)
{

    NimBLEDevice::init("CLIMBRO");
    pServer = NimBLEDevice::createServer();
    pServer->setCallbacks(new MyServerCallbacks());

    NimBLEService* pService = pServer->createService(NimBLEUUID(CLIMBRO_SERVICE_UUID));

    pNotifyCharacteristic = pService->createCharacteristic(
        NimBLEUUID(CLIMBRO_NOTIFY_CHARACTERISTIC_UUID),
        NIMBLE_PROPERTY::NOTIFY
    );

    pWriteCharacteristic = pService->createCharacteristic(
        NimBLEUUID(CLIMBRO_WRITE_CHARACTERISTIC_UUID),
        NIMBLE_PROPERTY::WRITE
    );
    pWriteCharacteristic->setCallbacks(new ClimbroCharacteristicCallbacks());

    pService->start();

    NimBLEAdvertising* pAdvertising = NimBLEDevice::getAdvertising();
    pAdvertising->setScanResponse(true);
    pAdvertising->start();

    Serial.println("Waiting for a client connection...");

    long previousMillis = 0;
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
            long currentMillis = millis();
            if (currentMillis - previousMillis >= batteryReportIntervalMs) {
                previousMillis = currentMillis;

                //old type device:  ((UnsignedByte - 155.0d) * 1.2987012987012987d));
                //new type device:  ((UnsignedByte - 112.0d) * 0.847457627118644d));
                uint8_t bat_data = (config.lastBatteryPercent / 0.847457627118644 + 112);
                uint8_t payload[2];
                payload[0] = CLIMBRO_BAT_DATA; 
                payload[1] = bat_data;
                pNotifyCharacteristic->setValue(payload, sizeof(payload));
                pNotifyCharacteristic->notify();
            }

            dataStruct data;
            while (bluetoothBuffer.lockedPop(data))
            {
                //Can only measure from 0 to 255kg.
                float kg = (data.v - config.offset) * config.scale;
                if (kg < 0) 
                    kg *= -1;

                int kgi = round(kg);
                uint8_t weight = kgi;
                uint8_t payload[2];
                payload[0] = CLIMBRO_SENS_DATA; // weight_measure
                payload[1] = weight; 

                pNotifyCharacteristic->setValue(payload, sizeof(payload));
                pNotifyCharacteristic->notify();
            }
        }
        delay(5);
    }    
}
