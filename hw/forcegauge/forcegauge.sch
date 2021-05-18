EESchema Schematic File Version 4
EELAYER 30 0
EELAYER END
$Descr A4 11693 8268
encoding utf-8
Sheet 1 1
Title ""
Date ""
Rev ""
Comp ""
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
$Comp
L ESP8266:ESP-12E U?
U 1 1 60A40AA9
P 5350 3150
F 0 "U?" H 5350 3915 50  0000 C CNN
F 1 "ESP-12E" H 5350 3824 50  0000 C CNN
F 2 "" H 5350 3150 50  0001 C CNN
F 3 "http://l0l.org.uk/2014/12/esp8266-modules-hardware-guide-gotta-catch-em-all/" H 5350 3150 50  0001 C CNN
	1    5350 3150
	1    0    0    -1  
$EndComp
$Comp
L Connector:USB_B_Micro J?
U 1 1 60A428C7
P 1950 3150
F 0 "J?" H 2007 3617 50  0000 C CNN
F 1 "USB_B_Micro" H 2007 3526 50  0000 C CNN
F 2 "" H 2100 3100 50  0001 C CNN
F 3 "~" H 2100 3100 50  0001 C CNN
	1    1950 3150
	1    0    0    -1  
$EndComp
$Comp
L Interface_USB:CH330N U?
U 1 1 60A41733
P 2300 1500
F 0 "U?" H 2300 1981 50  0000 C CNN
F 1 "CH330N" H 2300 1890 50  0000 C CNN
F 2 "Package_SO:SOIC-8_3.9x4.9mm_P1.27mm" H 2150 2250 50  0001 C CNN
F 3 "http://www.wch.cn/downloads/file/240.html" H 2200 1700 50  0001 C CNN
	1    2300 1500
	1    0    0    -1  
$EndComp
$Comp
L MISC:TP4056 U?
U 1 1 60A42653
P 3700 1200
F 0 "U?" H 4175 1497 60  0000 C CNN
F 1 "TP4056" H 4175 1391 60  0000 C CNN
F 2 "" H 3700 1200 60  0001 C CNN
F 3 "" H 3700 1200 60  0001 C CNN
	1    3700 1200
	1    0    0    -1  
$EndComp
$Comp
L MISC:MT3608 U?
U 1 1 60A42CAB
P 6950 1200
F 0 "U?" H 6950 1615 50  0000 C CNN
F 1 "MT3608" H 6950 1524 50  0000 C CNN
F 2 "" H 6950 1200 50  0001 C CNN
F 3 "" H 6950 1200 50  0001 C CNN
	1    6950 1200
	1    0    0    -1  
$EndComp
$Comp
L MISC:FS312F-G U?
U 1 1 60A476C7
P 8950 1300
F 0 "U?" H 8950 1717 50  0000 C CNN
F 1 "FS312F-G" H 8950 1626 50  0000 C CNN
F 2 "Package_SON:WSON-6_1.5x1.5mm_P0.5mm" H 8950 1650 50  0001 C CNN
F 3 "http://www.ti.com/lit/ds/symlink/bq2970.pdf" H 8700 1600 50  0001 C CNN
	1    8950 1300
	1    0    0    -1  
$EndComp
$EndSCHEMATC
