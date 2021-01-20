#!/usr/bin/python3

import websockets
import asyncio
import random
import json
import time
import math


def new_data(t, raw, value):
    t = t * 1000
    randomData = {'data': [{'time': t, 'raw': raw, 'value': value}]}
    return json.dumps(randomData)


def random_data(t):
    t = t * 1000
    raw = random.random() * 10000
    value = random.random() * 100 - 50
    randomData = {'data': [{'time': t, 'raw': raw, 'value': value}]}
    return json.dumps(randomData)


def initial_data():
    init_data = {"scale": 0.0001, "offset": 2000}
    return json.dumps(init_data)


async def device(websocket, path):
    print("Connected from",  websocket.remote_address)
    print("Path: ", path)
    start_time = time.time()
    await websocket.send(initial_data())
    while True:
        now = time.time()
        t = now-start_time
        value = math.sin(t*10)*100 + random.random() * 10
        d = new_data(t, value, value)
        await websocket.send(d)
        await asyncio.sleep(0.01)

bind_address = "0.0.0.0"
port = 9998
print("Test Device Started at ws://{}:{}".format(bind_address,port))
start_server = websockets.serve(device, bind_address, port)
asyncio.get_event_loop().run_until_complete(start_server)
asyncio.get_event_loop().run_forever()
