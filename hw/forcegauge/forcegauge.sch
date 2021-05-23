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
P 4150 -1800
F 0 "U?" H 4150 -1035 50  0000 C CNN
F 1 "ESP-12E" H 4150 -1126 50  0000 C CNN
F 2 "" H 4150 -1800 50  0001 C CNN
F 3 "http://l0l.org.uk/2014/12/esp8266-modules-hardware-guide-gotta-catch-em-all/" H 4150 -1800 50  0001 C CNN
	1    4150 -1800
	1    0    0    -1  
$EndComp
$Comp
L Connector:USB_B_Micro J?
U 1 1 60A428C7
P 900 4450
F 0 "J?" H 957 4917 50  0000 C CNN
F 1 "USB_B_Micro" H 957 4826 50  0000 C CNN
F 2 "" H 1050 4400 50  0001 C CNN
F 3 "~" H 1050 4400 50  0001 C CNN
	1    900  4450
	1    0    0    -1  
$EndComp
$Comp
L Interface_USB:CH330N U?
U 1 1 60A41733
P 1750 -1400
F 0 "U?" H 1750 -919 50  0000 C CNN
F 1 "CH330N" H 1750 -1010 50  0000 C CNN
F 2 "Package_SO:SOIC-8_3.9x4.9mm_P1.27mm" H 1600 -650 50  0001 C CNN
F 3 "http://www.wch.cn/downloads/file/240.html" H 1650 -1200 50  0001 C CNN
	1    1750 -1400
	1    0    0    -1  
$EndComp
$Comp
L MISC:TP4056 U?
U 1 1 60A42653
P 2300 5850
F 0 "U?" H 2775 6147 60  0000 C CNN
F 1 "TP4056" H 2775 6041 60  0000 C CNN
F 2 "" H 2300 5850 60  0001 C CNN
F 3 "" H 2300 5850 60  0001 C CNN
	1    2300 5850
	1    0    0    -1  
$EndComp
$Comp
L MISC:MT3608 U?
U 1 1 60A42CAB
P 2050 2500
F 0 "U?" H 2050 2915 50  0000 C CNN
F 1 "MT3608" H 2050 2824 50  0000 C CNN
F 2 "" H 2050 2500 50  0001 C CNN
F 3 "" H 2050 2500 50  0001 C CNN
	1    2050 2500
	1    0    0    -1  
$EndComp
$Comp
L MISC:FS312F-G U?
U 1 1 60A476C7
P 6400 5100
F 0 "U?" H 6400 5517 50  0000 C CNN
F 1 "FS312F-G" H 6400 5426 50  0000 C CNN
F 2 "Package_SON:WSON-6_1.5x1.5mm_P0.5mm" H 6400 5450 50  0001 C CNN
F 3 "http://www.ti.com/lit/ds/symlink/bq2970.pdf" H 6150 5400 50  0001 C CNN
F 4 "http://hmsemi.com/downfile/DW01A.PDF" H 6400 5100 50  0001 C CNN "Alternative"
	1    6400 5100
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR?
U 1 1 60AADF41
P 2000 6200
F 0 "#PWR?" H 2000 5950 50  0001 C CNN
F 1 "GND" H 2005 6027 50  0000 C CNN
F 2 "" H 2000 6200 50  0001 C CNN
F 3 "" H 2000 6200 50  0001 C CNN
	1    2000 6200
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR?
U 1 1 60AB2EC6
P 900 5050
F 0 "#PWR?" H 900 4800 50  0001 C CNN
F 1 "GND" H 905 4877 50  0000 C CNN
F 2 "" H 900 5050 50  0001 C CNN
F 3 "" H 900 5050 50  0001 C CNN
	1    900  5050
	1    0    0    -1  
$EndComp
Wire Wire Line
	900  5050 900  4900
Wire Wire Line
	800  4850 800  4900
Wire Wire Line
	800  4900 900  4900
Connection ~ 900  4900
Wire Wire Line
	900  4900 900  4850
$Comp
L power:VBUS #PWR?
U 1 1 60AB6DE2
P 1450 4150
F 0 "#PWR?" H 1450 4000 50  0001 C CNN
F 1 "VBUS" H 1465 4323 50  0000 C CNN
F 2 "" H 1450 4150 50  0001 C CNN
F 3 "" H 1450 4150 50  0001 C CNN
	1    1450 4150
	1    0    0    -1  
$EndComp
Wire Wire Line
	1450 4150 1450 4250
Wire Wire Line
	1450 4250 1200 4250
$Comp
L power:VBUS #PWR?
U 1 1 60AB89A4
P 1900 5600
F 0 "#PWR?" H 1900 5450 50  0001 C CNN
F 1 "VBUS" H 1915 5773 50  0000 C CNN
F 2 "" H 1900 5600 50  0001 C CNN
F 3 "" H 1900 5600 50  0001 C CNN
	1    1900 5600
	1    0    0    -1  
$EndComp
$Comp
L Device:C C?
U 1 1 60AB9475
P 1900 4650
F 0 "C?" H 2015 4696 50  0000 L CNN
F 1 "10uF" H 2015 4605 50  0000 L CNN
F 2 "Capacitor_SMD:C_0603_1608Metric" H 1938 4500 50  0001 C CNN
F 3 "~" H 1900 4650 50  0001 C CNN
	1    1900 4650
	1    0    0    -1  
$EndComp
$Comp
L power:VBUS #PWR?
U 1 1 60AB9CE6
P 1900 4250
F 0 "#PWR?" H 1900 4100 50  0001 C CNN
F 1 "VBUS" H 1915 4423 50  0000 C CNN
F 2 "" H 1900 4250 50  0001 C CNN
F 3 "" H 1900 4250 50  0001 C CNN
	1    1900 4250
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR?
U 1 1 60ABA2A4
P 1900 5000
F 0 "#PWR?" H 1900 4750 50  0001 C CNN
F 1 "GND" H 1905 4827 50  0000 C CNN
F 2 "" H 1900 5000 50  0001 C CNN
F 3 "" H 1900 5000 50  0001 C CNN
	1    1900 5000
	1    0    0    -1  
$EndComp
Wire Wire Line
	1900 5000 1900 4900
$Comp
L Device:C C?
U 1 1 60ABD8AB
P 2300 4650
F 0 "C?" H 2415 4696 50  0000 L CNN
F 1 "100nF" H 2415 4605 50  0000 L CNN
F 2 "Capacitor_SMD:C_0603_1608Metric" H 2338 4500 50  0001 C CNN
F 3 "~" H 2300 4650 50  0001 C CNN
	1    2300 4650
	1    0    0    -1  
$EndComp
Wire Wire Line
	1900 4250 1900 4350
Wire Wire Line
	1900 4350 2300 4350
Wire Wire Line
	2300 4350 2300 4500
Connection ~ 1900 4350
Wire Wire Line
	1900 4350 1900 4500
Wire Wire Line
	2300 4800 2300 4900
Wire Wire Line
	2300 4900 1900 4900
Connection ~ 1900 4900
Wire Wire Line
	1900 4900 1900 4800
$Comp
L Device:R R?
U 1 1 60AC5A04
P 1650 5900
F 0 "R?" V 1443 5900 50  0000 C CNN
F 1 "2k" V 1534 5900 50  0000 C CNN
F 2 "Resistor_SMD:R_0603_1608Metric" V 1580 5900 50  0001 C CNN
F 3 "~" H 1650 5900 50  0001 C CNN
	1    1650 5900
	0    1    1    0   
$EndComp
Wire Wire Line
	2000 5800 2000 6000
Wire Wire Line
	2000 5800 2150 5800
Wire Wire Line
	2000 6000 2150 6000
Connection ~ 2000 6000
Wire Wire Line
	2000 6000 2000 6200
Wire Wire Line
	1800 5900 2150 5900
Wire Wire Line
	1900 5600 1900 6100
Wire Wire Line
	1900 6100 2150 6100
$Comp
L power:GND #PWR?
U 1 1 60AD98D1
P 1400 6200
F 0 "#PWR?" H 1400 5950 50  0001 C CNN
F 1 "GND" H 1405 6027 50  0000 C CNN
F 2 "" H 1400 6200 50  0001 C CNN
F 3 "" H 1400 6200 50  0001 C CNN
	1    1400 6200
	1    0    0    -1  
$EndComp
Wire Wire Line
	1500 5900 1400 5900
Wire Wire Line
	1400 5900 1400 6200
Text Notes 700  6100 0    50   ~ 0
Charging current:\n3k     -  400mA\n2k     -  580mA\n1.6k   -  690mA
Text GLabel 1350 4450 2    50   Input ~ 0
D+
Wire Wire Line
	1350 4450 1200 4450
Text GLabel 1350 4550 2    50   Input ~ 0
D-
Wire Wire Line
	1350 4550 1200 4550
Text GLabel 8050 5450 2    50   Input ~ 0
BAT-
Text GLabel 8050 5100 2    50   Input ~ 0
BAT+
$Comp
L Device:R R?
U 1 1 60B0A59E
P 7750 5100
F 0 "R?" V 7543 5100 50  0000 C CNN
F 1 "100" V 7634 5100 50  0000 C CNN
F 2 "Resistor_SMD:R_0603_1608Metric" V 7680 5100 50  0001 C CNN
F 3 "~" H 7750 5100 50  0001 C CNN
	1    7750 5100
	0    1    1    0   
$EndComp
Wire Wire Line
	7600 5100 7450 5100
$Comp
L Device:C C?
U 1 1 60B0C4EF
P 7450 5250
F 0 "C?" H 7565 5296 50  0000 L CNN
F 1 "100nF" H 7565 5205 50  0000 L CNN
F 2 "Capacitor_SMD:C_0603_1608Metric" H 7488 5100 50  0001 C CNN
F 3 "~" H 7450 5250 50  0001 C CNN
	1    7450 5250
	1    0    0    -1  
$EndComp
Wire Wire Line
	8050 5100 8000 5100
$Comp
L Device:R R?
U 1 1 60B14BE6
P 5750 5100
F 0 "R?" V 5650 5100 50  0000 C CNN
F 1 "2k" V 5850 5100 50  0000 C CNN
F 2 "Resistor_SMD:R_0603_1608Metric" V 5680 5100 50  0001 C CNN
F 3 "~" H 5750 5100 50  0001 C CNN
	1    5750 5100
	0    1    1    0   
$EndComp
Wire Wire Line
	5900 5100 6000 5100
Wire Wire Line
	6400 5850 6200 5850
$Comp
L power:GND #PWR?
U 1 1 60B20F93
P 5700 6000
F 0 "#PWR?" H 5700 5750 50  0001 C CNN
F 1 "GND" H 5705 5827 50  0000 C CNN
F 2 "" H 5700 6000 50  0001 C CNN
F 3 "" H 5700 6000 50  0001 C CNN
	1    5700 6000
	1    0    0    -1  
$EndComp
Wire Wire Line
	6000 5250 6000 5550
Wire Wire Line
	5550 5100 5550 5450
Wire Wire Line
	5550 5100 5600 5100
Wire Wire Line
	6000 4950 5200 4950
Wire Wire Line
	5200 4950 5200 6300
Wire Wire Line
	5200 6300 6600 6300
Wire Wire Line
	6600 6300 6600 6150
Wire Wire Line
	5700 6000 5700 5850
Wire Wire Line
	5700 5850 5800 5850
Wire Wire Line
	7450 5450 8050 5450
Wire Wire Line
	7450 5450 7450 5400
Connection ~ 7450 5450
Wire Wire Line
	5550 5450 7250 5450
Wire Wire Line
	7250 4950 7250 5450
Wire Wire Line
	6800 4950 7250 4950
Connection ~ 7250 5450
Wire Wire Line
	7250 5450 7450 5450
Wire Wire Line
	7450 5850 7450 5450
Wire Wire Line
	6800 5850 7450 5850
Connection ~ 7450 5100
Wire Wire Line
	3600 5800 3400 5800
Text GLabel 3650 6100 2    50   Input ~ 0
BAT+
Wire Wire Line
	3400 6100 3650 6100
$Comp
L Device:LED D?
U 1 1 60B3A478
P 3900 5750
F 0 "D?" V 3939 5633 50  0000 R CNN
F 1 "LED" V 3848 5633 50  0000 R CNN
F 2 "Diode_SMD:D_0603_1608Metric" H 3900 5750 50  0001 C CNN
F 3 "~" H 3900 5750 50  0001 C CNN
	1    3900 5750
	0    -1   -1   0   
$EndComp
Wire Wire Line
	3900 5900 3400 5900
$Comp
L Device:R R?
U 1 1 60B3FEE0
P 3900 5350
F 0 "R?" H 3830 5304 50  0000 R CNN
F 1 "1k" H 3830 5395 50  0000 R CNN
F 2 "Resistor_SMD:R_0603_1608Metric" V 3830 5350 50  0001 C CNN
F 3 "~" H 3900 5350 50  0001 C CNN
	1    3900 5350
	-1   0    0    1   
$EndComp
Wire Wire Line
	3900 5500 3900 5600
$Comp
L power:VBUS #PWR?
U 1 1 60B44853
P 3900 5050
F 0 "#PWR?" H 3900 4900 50  0001 C CNN
F 1 "VBUS" H 3915 5223 50  0000 C CNN
F 2 "" H 3900 5050 50  0001 C CNN
F 3 "" H 3900 5050 50  0001 C CNN
	1    3900 5050
	1    0    0    -1  
$EndComp
Wire Wire Line
	3900 5050 3900 5150
Wire Wire Line
	3600 5150 3600 5800
Connection ~ 3900 5150
Wire Wire Line
	3900 5150 3900 5200
$Comp
L Device:LED D?
U 1 1 60B46E0C
P 4200 5750
F 0 "D?" V 4239 5633 50  0000 R CNN
F 1 "LED" V 4148 5633 50  0000 R CNN
F 2 "Diode_SMD:D_0603_1608Metric" H 4200 5750 50  0001 C CNN
F 3 "~" H 4200 5750 50  0001 C CNN
	1    4200 5750
	0    -1   -1   0   
$EndComp
Wire Wire Line
	4200 6000 4200 5900
$Comp
L Device:R R?
U 1 1 60B47EFE
P 4200 5350
F 0 "R?" H 4130 5304 50  0000 R CNN
F 1 "1k" H 4130 5395 50  0000 R CNN
F 2 "Resistor_SMD:R_0603_1608Metric" V 4130 5350 50  0001 C CNN
F 3 "~" H 4200 5350 50  0001 C CNN
	1    4200 5350
	-1   0    0    1   
$EndComp
Wire Wire Line
	4200 5500 4200 5600
Wire Wire Line
	4200 5200 4200 5150
Wire Wire Line
	4200 5150 3900 5150
Wire Wire Line
	3400 6000 4200 6000
Wire Wire Line
	3600 5150 3900 5150
$Comp
L Switch:SW_Push SW?
U 1 1 60B6667C
P 5950 3100
F 0 "SW?" H 5950 3385 50  0000 C CNN
F 1 "SW_Push" H 5950 3294 50  0000 C CNN
F 2 "Button_Switch_THT:SW_PUSH_6mm" H 5950 3300 50  0001 C CNN
F 3 "~" H 5950 3300 50  0001 C CNN
	1    5950 3100
	1    0    0    -1  
$EndComp
$Comp
L Switch:SW_Push SW?
U 1 1 60B6942B
P 8750 1600
F 0 "SW?" H 8750 1885 50  0000 C CNN
F 1 "SW_Push" H 8750 1794 50  0000 C CNN
F 2 "Button_Switch_THT:SW_PUSH_6mm" H 8750 1800 50  0001 C CNN
F 3 "~" H 8750 1800 50  0001 C CNN
	1    8750 1600
	1    0    0    -1  
$EndComp
$Comp
L Switch:SW_Push SW?
U 1 1 60B698D0
P 8750 2050
F 0 "SW?" H 8750 2335 50  0000 C CNN
F 1 "SW_Push" H 8750 2244 50  0000 C CNN
F 2 "Button_Switch_THT:SW_PUSH_6mm" H 8750 2250 50  0001 C CNN
F 3 "~" H 8750 2250 50  0001 C CNN
	1    8750 2050
	1    0    0    -1  
$EndComp
$Comp
L Device:C C?
U 1 1 60B7B609
P 850 2650
F 0 "C?" H 650 2700 50  0000 L CNN
F 1 "22uF" H 550 2600 50  0000 L CNN
F 2 "Capacitor_SMD:C_1812_4532Metric" H 888 2500 50  0001 C CNN
F 3 "~" H 850 2650 50  0001 C CNN
	1    850  2650
	1    0    0    -1  
$EndComp
Wire Wire Line
	850  2350 850  2500
$Comp
L power:GND #PWR?
U 1 1 60B815D9
P 1450 3150
F 0 "#PWR?" H 1450 2900 50  0001 C CNN
F 1 "GND" H 1455 2977 50  0000 C CNN
F 2 "" H 1450 3150 50  0001 C CNN
F 3 "" H 1450 3150 50  0001 C CNN
	1    1450 3150
	1    0    0    -1  
$EndComp
Wire Wire Line
	850  3000 850  2800
$Comp
L Device:R R?
U 1 1 60B8765D
P 3100 2300
F 0 "R?" H 3030 2254 50  0000 R CNN
F 1 "7.5k" H 3030 2345 50  0000 R CNN
F 2 "Resistor_SMD:R_0603_1608Metric" V 3030 2300 50  0001 C CNN
F 3 "~" H 3100 2300 50  0001 C CNN
	1    3100 2300
	-1   0    0    1   
$EndComp
$Comp
L Device:L L?
U 1 1 60B88038
P 2100 1850
F 0 "L?" V 2290 1850 50  0000 C CNN
F 1 "22uH" V 2199 1850 50  0000 C CNN
F 2 "" H 2100 1850 50  0001 C CNN
F 3 "~" H 2100 1850 50  0001 C CNN
	1    2100 1850
	0    -1   -1   0   
$EndComp
Wire Wire Line
	850  1850 850  2350
Connection ~ 850  2350
Wire Wire Line
	2250 1850 2650 1850
$Comp
L Device:R R?
U 1 1 60B8FA72
P 3100 2850
F 0 "R?" H 3030 2804 50  0000 R CNN
F 1 "1k" H 3030 2895 50  0000 R CNN
F 2 "Resistor_SMD:R_0603_1608Metric" V 3030 2850 50  0001 C CNN
F 3 "~" H 3100 2850 50  0001 C CNN
	1    3100 2850
	-1   0    0    1   
$EndComp
Wire Wire Line
	3100 2650 3100 2700
Wire Wire Line
	3100 2650 2650 2650
Wire Wire Line
	3100 2650 3100 2450
Connection ~ 3100 2650
Wire Wire Line
	3100 2150 3100 1850
Wire Wire Line
	3100 3000 3100 3050
$Comp
L power:GND #PWR?
U 1 1 60B989C2
P 3100 3100
F 0 "#PWR?" H 3100 2850 50  0001 C CNN
F 1 "GND" H 3105 2927 50  0000 C CNN
F 2 "" H 3100 3100 50  0001 C CNN
F 3 "" H 3100 3100 50  0001 C CNN
	1    3100 3100
	1    0    0    -1  
$EndComp
Wire Wire Line
	2650 1850 2650 2350
$Comp
L Device:D_Schottky D?
U 1 1 60B889ED
P 2850 1850
F 0 "D?" H 2850 1634 50  0000 C CNN
F 1 "D_Schottky" H 2850 1725 50  0000 C CNN
F 2 "Diode_SMD:D_SMA" H 2850 1850 50  0001 C CNN
F 3 "~" H 2850 1850 50  0001 C CNN
	1    2850 1850
	-1   0    0    1   
$EndComp
Wire Wire Line
	2650 1850 2700 1850
Connection ~ 2650 1850
Wire Wire Line
	3000 1850 3100 1850
$Comp
L Device:C C?
U 1 1 60BA63EF
P 3550 2550
F 0 "C?" H 3665 2596 50  0000 L CNN
F 1 "22uF" H 3665 2505 50  0000 L CNN
F 2 "Capacitor_SMD:C_1812_4532Metric" H 3588 2400 50  0001 C CNN
F 3 "~" H 3550 2550 50  0001 C CNN
	1    3550 2550
	1    0    0    -1  
$EndComp
Wire Wire Line
	3100 1850 3550 1850
Wire Wire Line
	3550 1850 3550 2400
Connection ~ 3100 1850
Wire Wire Line
	3550 2700 3550 3050
Wire Wire Line
	3550 3050 3100 3050
Connection ~ 3100 3050
Wire Wire Line
	3100 3050 3100 3100
$Comp
L Transistor_FET:FDS6892A Q?
U 1 1 60BB1B25
P 6600 5950
F 0 "Q?" V 6942 5950 50  0000 C CNN
F 1 "FDS6892A" V 6851 5950 50  0000 C CNN
F 2 "Package_SO:SOIC-8_3.9x4.9mm_P1.27mm" H 6800 5875 50  0001 L CIN
F 3 "http://www.fairchildsemi.com/ds/FD/FDS6892A.pdf" H 6600 5950 50  0001 L CNN
	1    6600 5950
	0    -1   -1   0   
$EndComp
$Comp
L Transistor_FET:FDS6892A Q?
U 2 1 60BB2879
P 6000 5750
F 0 "Q?" V 6249 5750 50  0000 C CNN
F 1 "FDS6892A" V 6340 5750 50  0000 C CNN
F 2 "Package_SO:SOIC-8_3.9x4.9mm_P1.27mm" H 6200 5675 50  0001 L CIN
F 3 "http://www.fairchildsemi.com/ds/FD/FDS6892A.pdf" H 6000 5750 50  0001 L CNN
	2    6000 5750
	0    1    1    0   
$EndComp
$Comp
L power:VCC #PWR?
U 1 1 60BE1E35
P 8000 4800
F 0 "#PWR?" H 8000 4650 50  0001 C CNN
F 1 "VCC" H 8017 4973 50  0000 C CNN
F 2 "" H 8000 4800 50  0001 C CNN
F 3 "" H 8000 4800 50  0001 C CNN
	1    8000 4800
	1    0    0    -1  
$EndComp
$Comp
L power:VCC #PWR?
U 1 1 60BE4DF0
P 850 1600
F 0 "#PWR?" H 850 1450 50  0001 C CNN
F 1 "VCC" H 867 1773 50  0000 C CNN
F 2 "" H 850 1600 50  0001 C CNN
F 3 "" H 850 1600 50  0001 C CNN
	1    850  1600
	1    0    0    -1  
$EndComp
Wire Wire Line
	850  1600 850  1850
Connection ~ 850  1850
Text GLabel 1150 2500 0    50   Input ~ 0
5V_EN
$Comp
L power:VCC #PWR?
U 1 1 60BEDD03
P 4800 1900
F 0 "#PWR?" H 4800 1750 50  0001 C CNN
F 1 "VCC" H 4817 2073 50  0000 C CNN
F 2 "" H 4800 1900 50  0001 C CNN
F 3 "" H 4800 1900 50  0001 C CNN
	1    4800 1900
	1    0    0    -1  
$EndComp
Wire Wire Line
	8000 4800 8000 5100
Connection ~ 8000 5100
Wire Wire Line
	8000 5100 7900 5100
Wire Wire Line
	6800 5100 7450 5100
$Comp
L Device:R R?
U 1 1 60BF4EA6
P 4800 2450
F 0 "R?" H 4730 2404 50  0000 R CNN
F 1 "100k" H 4730 2495 50  0000 R CNN
F 2 "Resistor_SMD:R_0603_1608Metric" V 4730 2450 50  0001 C CNN
F 3 "~" H 4800 2450 50  0001 C CNN
	1    4800 2450
	-1   0    0    1   
$EndComp
Wire Wire Line
	4800 3100 5250 3100
$Comp
L Device:D D?
U 1 1 60BFC449
P 5250 2850
F 0 "D?" V 5296 2771 50  0000 R CNN
F 1 "D" V 5205 2771 50  0000 R CNN
F 2 "" H 5250 2850 50  0001 C CNN
F 3 "~" H 5250 2850 50  0001 C CNN
	1    5250 2850
	0    -1   -1   0   
$EndComp
Wire Wire Line
	5250 3000 5250 3100
Wire Wire Line
	5750 3100 5450 3100
Connection ~ 5250 3100
$Comp
L Transistor_FET:FDS6892A Q?
U 2 1 60C1583F
P 6750 2800
F 0 "Q?" H 6954 2846 50  0000 L CNN
F 1 "FDS6892A" H 6954 2755 50  0000 L CNN
F 2 "Package_SO:SOIC-8_3.9x4.9mm_P1.27mm" H 6950 2725 50  0001 L CIN
F 3 "http://www.fairchildsemi.com/ds/FD/FDS6892A.pdf" H 6750 2800 50  0001 L CNN
	2    6750 2800
	1    0    0    -1  
$EndComp
Wire Wire Line
	6150 3100 6350 3100
$Comp
L power:GND #PWR?
U 1 1 60C1DBEC
P 6350 3300
F 0 "#PWR?" H 6350 3050 50  0001 C CNN
F 1 "GND" H 6355 3127 50  0000 C CNN
F 2 "" H 6350 3300 50  0001 C CNN
F 3 "" H 6350 3300 50  0001 C CNN
	1    6350 3300
	1    0    0    -1  
$EndComp
Wire Wire Line
	6350 3300 6350 3100
Wire Wire Line
	6350 3100 6850 3100
Wire Wire Line
	6850 3100 6850 3000
Connection ~ 6350 3100
$Comp
L Device:R R?
U 1 1 60C2C118
P 6850 2150
F 0 "R?" H 6780 2104 50  0000 R CNN
F 1 "100k" H 6780 2195 50  0000 R CNN
F 2 "Resistor_SMD:R_0603_1608Metric" V 6780 2150 50  0001 C CNN
F 3 "~" H 6850 2150 50  0001 C CNN
	1    6850 2150
	-1   0    0    1   
$EndComp
Wire Wire Line
	7850 3000 7850 3100
Wire Wire Line
	7850 3100 6850 3100
Connection ~ 6850 3100
$Comp
L power:+3V3 #PWR?
U 1 1 60C440DE
P 6850 1950
F 0 "#PWR?" H 6850 1800 50  0001 C CNN
F 1 "+3V3" H 6865 2123 50  0000 C CNN
F 2 "" H 6850 1950 50  0001 C CNN
F 3 "" H 6850 1950 50  0001 C CNN
	1    6850 1950
	1    0    0    -1  
$EndComp
$Comp
L Device:Q_PMOS_DGS Q?
U 1 1 60C45BA1
P 5850 2100
F 0 "Q?" V 6192 2100 50  0000 C CNN
F 1 "Q_PMOS_DGS" V 6101 2100 50  0000 C CNN
F 2 "Package_TO_SOT_SMD:SOT-323_SC-70" H 6050 2200 50  0001 C CNN
F 3 "https://datasheet.lcsc.com/lcsc/Will-Semicon-WNM2021-3-TR_C239556.pdf" H 5850 2100 50  0001 C CNN
	1    5850 2100
	0    1    -1   0   
$EndComp
$Comp
L Device:R R?
U 1 1 60C468D7
P 5250 2150
F 0 "R?" H 5180 2104 50  0000 R CNN
F 1 "100k" H 5180 2195 50  0000 R CNN
F 2 "Resistor_SMD:R_0603_1608Metric" V 5180 2150 50  0001 C CNN
F 3 "~" H 5250 2150 50  0001 C CNN
	1    5250 2150
	-1   0    0    1   
$EndComp
$Comp
L Device:R R?
U 1 1 60C544E2
P 1200 2750
F 0 "R?" H 1150 2700 50  0000 R CNN
F 1 "100k" H 1150 2800 50  0000 R CNN
F 2 "Resistor_SMD:R_0603_1608Metric" V 1130 2750 50  0001 C CNN
F 3 "~" H 1200 2750 50  0001 C CNN
	1    1200 2750
	-1   0    0    1   
$EndComp
Wire Wire Line
	1450 2650 1450 3000
Wire Wire Line
	850  2350 1450 2350
Connection ~ 1450 3000
Wire Wire Line
	1450 3000 1450 3150
Wire Wire Line
	1150 2500 1200 2500
Wire Wire Line
	850  3000 1200 3000
Wire Wire Line
	1200 2900 1200 3000
Connection ~ 1200 3000
Wire Wire Line
	1200 3000 1450 3000
Wire Wire Line
	1200 2600 1200 2500
Connection ~ 1200 2500
Wire Wire Line
	1200 2500 1450 2500
Text GLabel 6200 2000 2    50   Input ~ 0
5V_EN
Wire Wire Line
	4800 1900 4800 2000
Wire Wire Line
	4800 2000 5250 2000
Wire Wire Line
	4800 2300 4800 2000
Connection ~ 4800 2000
Wire Wire Line
	4800 2600 4800 3100
Connection ~ 5250 2000
Wire Wire Line
	5250 2300 5250 2550
Wire Wire Line
	6200 2000 6050 2000
Wire Wire Line
	5250 2000 5650 2000
Wire Wire Line
	5250 2550 5850 2550
Wire Wire Line
	5850 2550 5850 2300
Connection ~ 5250 2550
Wire Wire Line
	5250 2550 5250 2700
Wire Wire Line
	6550 2800 5450 2800
Wire Wire Line
	5450 2800 5450 3100
Connection ~ 5450 3100
Wire Wire Line
	5450 3100 5250 3100
Wire Wire Line
	5850 2550 7850 2550
Wire Wire Line
	7850 2550 7850 2600
Connection ~ 5850 2550
Wire Wire Line
	8150 2800 8250 2800
Text GLabel 8350 2800 2    50   Input ~ 0
PWR_EN
$Comp
L Transistor_FET:FDS6892A Q?
U 1 1 60C16514
P 7950 2800
F 0 "Q?" H 8155 2754 50  0000 L CNN
F 1 "FDS6892A" H 8155 2845 50  0000 L CNN
F 2 "Package_SO:SOIC-8_3.9x4.9mm_P1.27mm" H 8150 2725 50  0001 L CIN
F 3 "http://www.fairchildsemi.com/ds/FD/FDS6892A.pdf" H 7950 2800 50  0001 L CNN
	1    7950 2800
	-1   0    0    1   
$EndComp
Wire Wire Line
	6850 2000 6850 1950
Wire Wire Line
	6850 2300 6850 2350
Wire Wire Line
	6850 2350 7150 2350
Connection ~ 6850 2350
Wire Wire Line
	6850 2350 6850 2600
Text GLabel 7150 2350 2    50   Input ~ 0
BTN_PWR
$Comp
L Device:R R?
U 1 1 60CEBE5F
P 8250 2950
F 0 "R?" H 8180 2904 50  0000 R CNN
F 1 "100k" H 8180 2995 50  0000 R CNN
F 2 "Resistor_SMD:R_0603_1608Metric" V 8180 2950 50  0001 C CNN
F 3 "~" H 8250 2950 50  0001 C CNN
	1    8250 2950
	-1   0    0    1   
$EndComp
Connection ~ 8250 2800
Wire Wire Line
	8250 2800 8350 2800
Wire Wire Line
	7850 3100 8250 3100
Connection ~ 7850 3100
Wire Wire Line
	850  1850 1950 1850
$EndSCHEMATC
