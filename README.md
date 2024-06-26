# Force Gauge

- ESP32 based Force Gauge - Aiming to help rock climbing specific training (finger excercises)
- Real time plotting via wifi Webapp/Android app


# Pictures
## Forcegauge with fingerboard
<img src="https://raw.githubusercontent.com/szbeni/forcegauge/main/photos/fingerboard.jpg" width="400">

## First prototypes
<img src="https://raw.githubusercontent.com/szbeni/forcegauge/main/photos/prototypes_02.jpg" width="600">

# Hardware
## Main parts
 - ESP32-C3 MCU
 - 3 buttons
 - OLED screen 0.96" SSD1306
 - Battery with charger
 - USB UART connection
 - HX711 ADC - Load cell
## Schematic ##

- [Schematic](https://github.com/szbeni/forcegauge/blob/main/hw/forcegauge/forcegauge.pdf)
## PCB 

Pictures of the PCB:

<img src="https://raw.githubusercontent.com/szbeni/forcegauge/main/photos/pcb_render_01.png">
<img src="https://raw.githubusercontent.com/szbeni/forcegauge/main/photos/pcb_render_02.png">
<img src="https://raw.githubusercontent.com/szbeni/forcegauge/main/photos/pcb_photo.jpg">

## Interactive BOM

- [Interactive BOM](https://htmlpreview.github.io/?https://github.com/szbeni/forcegauge/blob/main/hw/forcegauge/bom/ibom.html)

# Software

## Firmware
- Arudino IDE - Some lagging issues due to limitations of arduino environment
- Started wokring on firmware with ESP-IDF which supports multitasking
- Added Bluetooth support to come up as a Tindeq Progressor bluetooth device (https://tindeq.com/product/progressor) (CChange Bluetooth and restart device, WIFI wont work when BT is on)
- Added Bluetooth support to come up as a Climbro bluetooth device (https://climbro.com/) (Change Bluetooth settings and restart device, WIFI wont work when BT is on)

## Flutter based app (Tested on Android)
- Available on Google play: https://play.google.com/store/apps/details?id=com.github.szbeni.forcegauge
- Real time plotting
- Built in tabata timer (Based on https://github.com/insin/tabata_timer)
- Record history of traning 

<p float="left">
<img src="https://raw.githubusercontent.com/szbeni/forcegauge/main/photos/flutter_app_01.png" width="200">
<img src="https://raw.githubusercontent.com/szbeni/forcegauge/main/photos/flutter_app_02.png" width="200">
<img src="https://raw.githubusercontent.com/szbeni/forcegauge/main/photos/flutter_app_03.png" width="200">
<img src="https://raw.githubusercontent.com/szbeni/forcegauge/main/photos/flutter_app_04.gif" width="200">
</p>

## Webapp
- Simple webapp served from a HTTP server

<img src="https://raw.githubusercontent.com/szbeni/forcegauge/main/photos/webapp_01.jpg" width="600">

