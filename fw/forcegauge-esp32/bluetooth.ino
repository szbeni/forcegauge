// /*
//     Video: https://www.youtube.com/watch?v=oCMOYS71NIU
//     Based on Neil Kolban example for IDF: https://github.com/nkolban/esp32-snippets/blob/master/cpp_utils/tests/BLE%20Tests/SampleNotify.cpp
//     Ported to Arduino ESP32 by Evandro Copercini

//    Create a BLE server that, once we receive a connection, will send periodic notifications.
//    The service advertises itself as: 6E400001-B5A3-F393-E0A9-E50E24DCCA9E
//    Has a characteristic of: 6E400002-B5A3-F393-E0A9-E50E24DCCA9E - used for receiving data with "WRITE"
//    Has a characteristic of: 6E400003-B5A3-F393-E0A9-E50E24DCCA9E - used to send data with  "NOTIFY"

//    The design of creating the BLE server is:
//    1. Create a BLE Server
//    2. Create a BLE Service
//    3. Create a BLE Characteristic on the Service
//    4. Create a BLE Descriptor on the characteristic
//    5. Start the service.
//    6. Start advertising.

//    In this example rxValue is the data received (only accessible inside that function).
//    And txValue is the data to be sent, in this example just a byte incremented every second.
// */
// #include <BLEDevice.h>
// #include <BLEServer.h>
// #include <BLEUtils.h>
// #include <BLE2902.h>

// BLEServer *pServer = NULL;
// BLECharacteristic *pTxCharacteristic;
// bool deviceConnected = false;
// bool oldDeviceConnected = false;
// uint8_t txValue = 0;

// // See the following for generating UUIDs:
// // https://www.uuidgenerator.net/

// #define SERVICE_UUID "6E400001-B5A3-F393-E0A9-E50E24DCCA9E" // UART service UUID
// #define CHARACTERISTIC_UUID_RX "6E400002-B5A3-F393-E0A9-E50E24DCCA9E"
// #define CHARACTERISTIC_UUID_TX "6E400003-B5A3-F393-E0A9-E50E24DCCA9E"

// void bluetoothBroadcastData()
// {
//   // No connected clients
//   if (!deviceConnected)
//     return;

//   // Nothing to send
//   if (bluetoothBuffer.isEmpty())
//     return;

//   //  String jsonObj = "{\"data\": [";

//   //  bool first = true;
//   //  while (bluetoothBuffer.lockedPop(data))
//   //  {
//   //    if (first)
//   //    {
//   //      first = false;
//   //    }
//   //    else
//   //    {
//   //      jsonObj += ",";
//   //    }
//   //    float valueFloat = (data.v - config.offset) * config.scale;
//   //    jsonObj += "{\"time\":\"" + String(data.t) + "\", ";
//   //    jsonObj += "\"raw\":\"" + String(data.v) + "\", ";
//   //    jsonObj += "\"value\":\"" + String(valueFloat) + "\"}";
//   //  }
//   //  jsonObj += "]}\n";

//   String jsonObj;
//   dataStruct data;

//   while (bluetoothBuffer.lockedPop(data))
//   {
//   }

//   jsonObj = "";
//   float valueFloat = (data.v - config.offset) * config.scale;
//   jsonObj.concat(valueFloat);
//   pTxCharacteristic->setValue((uint8_t *)jsonObj.c_str(), jsonObj.length());
//   pTxCharacteristic->notify();
//   delay(2);

//   // pTxCharacteristic->setValue((uint8_t*)jsonObj.c_str(), jsonObj.length());
//   // txValue++;
//   // SerialBT.write((const uint8_t*)jsonObj.c_str(), jsonObj.length());
// }

// class MyServerCallbacks : public BLEServerCallbacks
// {
//   void onConnect(BLEServer *pServer)
//   {
//     deviceConnected = true;
//   };

//   void onDisconnect(BLEServer *pServer)
//   {
//     deviceConnected = false;
//   }
// };

// class MyCallbacks : public BLECharacteristicCallbacks
// {
//   void onWrite(BLECharacteristic *pCharacteristic)
//   {
//     std::string rxValue = pCharacteristic->getValue();

//     if (rxValue.length() > 0)
//     {
//       Serial.println("*********");
//       Serial.print("Received Value: ");
//       for (int i = 0; i < rxValue.length(); i++)
//         Serial.print(rxValue[i]);

//       Serial.println();
//       Serial.println("*********");
//     }
//   }
// };

// void bluetoothTask(void *parameter)
// {

//   Serial.print("bluetoothTask: priority = ");
//   Serial.println(uxTaskPriorityGet(NULL));

//   // Create the BLE Device
//   BLEDevice::init("Forcegauge Service");

//   // Create the BLE Server
//   pServer = BLEDevice::createServer();
//   pServer->setCallbacks(new MyServerCallbacks());

//   // Create the BLE Service
//   BLEService *pService = pServer->createService(SERVICE_UUID);

//   // Create a BLE Characteristic
//   pTxCharacteristic = pService->createCharacteristic(
//       CHARACTERISTIC_UUID_TX,
//       BLECharacteristic::PROPERTY_NOTIFY);

//   pTxCharacteristic->addDescriptor(new BLE2902());

//   BLECharacteristic *pRxCharacteristic = pService->createCharacteristic(
//       CHARACTERISTIC_UUID_RX,
//       BLECharacteristic::PROPERTY_WRITE);

//   pRxCharacteristic->setCallbacks(new MyCallbacks());

//   // Start the service
//   pService->start();

//   // Start advertising
//   pServer->getAdvertising()->start();
//   Serial.println("Bluetooth server started");

//   pService->stop();
//   while (1)
//   {

//     bluetoothBroadcastData();
//     //    if (deviceConnected) {
//     //        pTxCharacteristic->setValue(&txValue, 1);
//     //        pTxCharacteristic->notify();
//     //        txValue++;
//     //        delay(10); // bluetooth stack will go into congestion, if too many packets are sent
//     //      }

//     // disconnecting
//     if (!deviceConnected && oldDeviceConnected)
//     {
//       delay(500);                  // give the bluetooth stack the chance to get things ready
//       pServer->startAdvertising(); // restart advertising
//       Serial.println("start advertising");
//       oldDeviceConnected = deviceConnected;
//     }
//     // connecting
//     if (deviceConnected && !oldDeviceConnected)
//     {
//       // do stuff here on connecting
//       oldDeviceConnected = deviceConnected;
//     }
//     delay(10);
//   }
//   // Should never get here
//   vTaskDelete(NULL);
//}


#include <NimBLEDevice.h>

static NimBLEServer* pServer = nullptr;
static NimBLECharacteristic* pNotifyCharacteristic = nullptr;
static NimBLECharacteristic* pWriteCharacteristic = nullptr;
static bool deviceConnected = false;
static bool oldDeviceConnected = false;
static uint32_t previousMillis = 0;
static const uint32_t interval = 12; // 12ms interval
static bool startMeasurement = false;
static long startMeasurementTime = 0;
static float simulatedWeight = 50.0;

#define SERVICE_UUID                 "7e4e1701-1ea6-40c9-9dcc-13d34ffead57"
#define NOTIFY_CHARACTERISTIC_UUID   "7e4e1702-1ea6-40c9-9dcc-13d34ffead57"
#define WRITE_CHARACTERISTIC_UUID    "7e4e1703-1ea6-40c9-9dcc-13d34ffead57"

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

class MyCharacteristicCallbacks : public NimBLECharacteristicCallbacks {
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

void bluetoothTask(void *parameter)
{

    NimBLEDevice::init("Progressor_1234");
    pServer = NimBLEDevice::createServer();
    pServer->setCallbacks(new MyServerCallbacks());

    NimBLEService* pService = pServer->createService(NimBLEUUID(SERVICE_UUID));

    pNotifyCharacteristic = pService->createCharacteristic(
        NimBLEUUID(NOTIFY_CHARACTERISTIC_UUID),
        NIMBLE_PROPERTY::NOTIFY
    );

    pWriteCharacteristic = pService->createCharacteristic(
        NimBLEUUID(WRITE_CHARACTERISTIC_UUID),
        NIMBLE_PROPERTY::WRITE
    );
    pWriteCharacteristic->setCallbacks(new MyCharacteristicCallbacks());

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





// void bluetoothTask(void *parameter)
// {
//   while (1)
//   {
//     delay(10000);
//   }
// }
