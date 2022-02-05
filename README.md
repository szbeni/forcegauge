# Force Gauge with ESP8266

- ESP8266 based Force Gauge - Aiming to help rock climbing specific training (finger excercises)
- Real time plotting via wifi Webapp/Android app

# Hardware main parts:
 - ESP8266 MCU
 - 3 buttons
 - OLED screen 0.96" SSD1306
 - Battery with charger
 - USB UART connection
 - HX711 ADC - Load cell
 

<img src="https://raw.githubusercontent.com/szbeni/forcegauge/main/photos/prototype_01.jpg" width="200">

## PCB version v0.1 3D kicad render:

<img src="https://raw.githubusercontent.com/szbeni/forcegauge/main/photos/pcb_render_01.png" width="200">
<img src="https://raw.githubusercontent.com/szbeni/forcegauge/main/photos/pcb_render_02.png" width="200">

## Interactive BOM

- [Interactive BOM](https://htmlpreview.github.io/?https://github.com/szbeni/forcegauge/blob/main/hw/forcegauge/bom/ibom.html)


## Firmware:
- Arudino IDE

## Flutter based app (Tested on Android):
- Real time plotting
- Built in tabata timer (Based on https://github.com/insin/tabata_timer)
- Record history of traning 

<p float="left">
<img src="https://raw.githubusercontent.com/szbeni/forcegauge/main/photos/flutter_app_01.png" width="200">
<img src="https://raw.githubusercontent.com/szbeni/forcegauge/main/photos/flutter_app_02.png" width="200">
<img src="https://raw.githubusercontent.com/szbeni/forcegauge/main/photos/flutter_app_03.png" width="200">
<img src="https://raw.githubusercontent.com/szbeni/forcegauge/main/photos/flutter_app_04.gif" width="200">
</p>

## Webapp:
- Simple webapp served from the ESP8266 HTTP server
<img src="https://raw.githubusercontent.com/szbeni/forcegauge/main/photos/webapp_01.jpg" width="600">

