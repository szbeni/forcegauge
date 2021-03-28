#!/usr/bin/python3

from zeroconf import Zeroconf
from requests import request
 
class Listener:
 
    def add_service(self, zeroconf, serviceType, name):
 
        info = zeroconf.get_service_info(serviceType, name)
 
        print("Address: " + str(info.parsed_addresses()))
        print("Port: " + str(info.port))
        print("Service Name: " + info.name)
        print("Server: " + info.server)
        print("Properties: " + str(info.properties))
 
        address = "http://" + info.parsed_addresses()[0]+"/"
 
        print("\n\nSending request...")
        response = request("GET", address)
        print(response.text)

zconf = Zeroconf()
serviceListener = Listener()
zconf.add_service_listener("_http._tcp.local.", serviceListener)

input("Press enter to close... \n")
zconf.close()