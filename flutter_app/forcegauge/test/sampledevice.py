#!/usr/bin/python3

import websockets
import asyncio
import random
import json
import time


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
        await websocket.send(random_data(now-start_time))
        await asyncio.sleep(0.01)

start_server = websockets.serve(device, "localhost", 9998)
asyncio.get_event_loop().run_until_complete(start_server)
asyncio.get_event_loop().run_forever()
