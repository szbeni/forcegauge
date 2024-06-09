#include <NimBLEDevice.h>

NimBLEServer* pServer = nullptr;
NimBLECharacteristic* pNotifyCharacteristic = nullptr;
NimBLECharacteristic* pWriteCharacteristic = nullptr;
bool deviceConnected = false;
bool oldDeviceConnected = false;
bool startMeasurement = false;
long startMeasurementTime = 0;

#define TINDEQ_SERVICE_UUID                 "7e4e1701-1ea6-40c9-9dcc-13d34ffead57"
#define TINDEQ_NOTIFY_CHARACTERISTIC_UUID   "7e4e1702-1ea6-40c9-9dcc-13d34ffead57"
#define TINDEQ_WRITE_CHARACTERISTIC_UUID    "7e4e1703-1ea6-40c9-9dcc-13d34ffead57"


const uint8_t SCAN_RESPONSE_DATA[] = {
    17,
    0x07,
    0x57, 0xad, 0xfe, 0x4f, 0xd3, 0x13, 0xcc, 0x9d, 0xc9, 0x40, 0xa6, 0x1e, 0x01, 0x17, 0x4e, 0x7e
};

std::vector<uint8_t> advertising_data(const char* name) {
    std::vector<uint8_t> advertising_data;
    advertising_data.push_back(2);
    advertising_data.push_back(0x01); //BLE_GAP_AD_TYPE_FLAGS
    advertising_data.push_back(0x02 | 0x04); //BLE_GAP_ADV_FLAG_LE_GENERAL_DISC_MODE | BLE_GAP_ADV_FLAG_BR_EDR_NOT_SUPPORTED
    size_t name_len = strlen(name);
    advertising_data.push_back(name_len + 1);
    advertising_data.push_back(0x09); //BLE_GAP_AD_TYPE_COMPLETE_LOCAL_NAME
    advertising_data.insert(advertising_data.end(), name, name + name_len);
    return advertising_data;
}

class MyServerCallbacks : public NimBLEServerCallbacks {
    void onConnect(NimBLEServer* pServer) {
        deviceConnected = true;
        Serial.println("Client connected");
    }

    void onDisconnect(NimBLEServer* pServer) {
        deviceConnected = false;
        Serial.println("Client disconnected");
    }
};

class TindeqCharacteristicCallbacks : public NimBLECharacteristicCallbacks {
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
            case 0x64: // TARE_SCALE
                Serial.println("TARE_SCALE command received");
                config.offset = config.lastRawValue;
                // Handle tare scale logic
                break;
            case 0x65: // START_WEIGHT_MEAS
                Serial.println("START_WEIGHT_MEAS command received");
                startMeasurementTime = millis();
                startMeasurement = true;
                break;
            case 0x66: // STOP_WEIGHT_MEAS
                Serial.println("STOP_WEIGHT_MEAS command received");
                startMeasurement = false;
                break;

            case 0x6B: // GET_APP_VERSION
                Serial.println("GET_APP_VERSION command received");
                notifyResponse("1.2.3.4");
                break;

            case 0x6F: // GET_BATT_VLTG
                Serial.println("GET_BATT_VLTG command received");
                notifyBatteryLevel();
                break;
            case 0x70: // GET_BATT_VLTG
                Serial.println("GetProgressorID command received");
                notifyResponse("42");
                break;

            default:
                Serial.print("Unknown command received: ");
                Serial.println(cmd);
                break;
        }
    }

    void notifyResponse(const char* response) {
        uint8_t payload[2 + strlen(response)];
        payload[0] = 0; // cmd_resp
        payload[1] = strlen(response);
        memcpy(&payload[2], response, strlen(response));
        pNotifyCharacteristic->setValue(payload, sizeof(payload));
        pNotifyCharacteristic->notify();
    }

    void notifyBatteryLevel() {
        float voltage = readBatteryVoltage() * 1000;
        uint32_t batteryLevel = voltage; // level in mV
        uint8_t payload[6];
        payload[0] = 0; // cmd_resp
        payload[1] = sizeof(batteryLevel); // Size of the battery level data
        memcpy(&payload[2], &batteryLevel, sizeof(batteryLevel));
        pNotifyCharacteristic->setValue(payload, sizeof(payload));
        pNotifyCharacteristic->notify();
    }
};

void bluetoothTaskTindeq(void *parameter)
{

    NimBLEDevice::init("Progressor_1234");
    pServer = NimBLEDevice::createServer();
    pServer->setCallbacks(new MyServerCallbacks());

    NimBLEService* pService = pServer->createService(NimBLEUUID(TINDEQ_SERVICE_UUID));

    pNotifyCharacteristic = pService->createCharacteristic(
        NimBLEUUID(TINDEQ_NOTIFY_CHARACTERISTIC_UUID),
        NIMBLE_PROPERTY::NOTIFY
    );

    pWriteCharacteristic = pService->createCharacteristic(
        NimBLEUUID(TINDEQ_WRITE_CHARACTERISTIC_UUID),
        NIMBLE_PROPERTY::WRITE
    );
    pWriteCharacteristic->setCallbacks(new TindeqCharacteristicCallbacks());

    pService->start();

    NimBLEAdvertisementData oAdvertisementData;
    NimBLEAdvertisementData oScanResponseData;

    oScanResponseData.addData(std::string((const char*)SCAN_RESPONSE_DATA, sizeof(SCAN_RESPONSE_DATA)));

    std::vector<uint8_t> adv_data = advertising_data("Progressor_1234");
    oAdvertisementData.addData(std::string((const char*)adv_data.data(), adv_data.size()));

    NimBLEAdvertising* pAdvertising = NimBLEDevice::getAdvertising();
    pAdvertising->setScanResponse(true);
    pAdvertising->setAdvertisementData(oAdvertisementData);
    pAdvertising->setScanResponseData(oScanResponseData);
    pAdvertising->start();

    Serial.println("Waiting for a client connection...");

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

        if (startMeasurement && deviceConnected) {
            dataStruct data;
            while (bluetoothBuffer.lockedPop(data))
            {
                if (data.t > startMeasurementTime)
                {
                    float weight = (data.v - config.offset) * config.scale;
                    uint32_t useconds = (data.t - startMeasurementTime) * 1000;
                    uint8_t payload[10];
                    payload[0] = 1; // weight_measure
                    payload[1] = 8; // size of the payload (4 bytes float + 4 bytes uint32)
                    memcpy(&payload[2], &weight, sizeof(float));
                    memcpy(&payload[6], &useconds, sizeof(uint32_t));
                    pNotifyCharacteristic->setValue(payload, sizeof(payload));
                    pNotifyCharacteristic->notify();
                }
            }
        }
        delay(5);
    }
    
}
