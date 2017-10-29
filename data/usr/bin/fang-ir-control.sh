#!/bin/sh
# This script has been adapted from the C implementation of snx_ir_ctl
# (ir_ctl.c) from the Sonix SDK.  Previous versions of fang-ir-control.sh
# initialised the GPIO differently and did not affect the
# IR Cut Drive Control B (IR_CUT_N_PIN) at all.

# GPIO reference at
# https://gist.github.com/davidjb/f0529d8d64ca5d873fe700577bc43dac

##########
#Constants
##########
OFF=0
ON=1
INPUT=0
OUTPUT=1

# GPIO MS1 Pin 2 (Output) - IR CUT Drive Control Output A
#     gpio_ms1 -n 2 -m 1 -v {0,1}
IR_CUT_P_PIN=2

# GPIO AUD Pin 0 (Output) - Infrared Lamp Control (eg IR LEDs)
#     gpio_aud write 1 0 {0,1}
LED_PIN=0

# GPIO AUD Pin 1 (Output) - IR CUT Drive Control Output B
#     gpio_aud write 1 1 {0,1}
IR_CUT_N_PIN=1

# GPIO AUD Pin 2 (Output) - Day / Night mode Detection Port
#     gpio_aud read 2
IR_CUT_DAYNIGHT_PIN=2


echo "IR script started"

# From spi_gpio_init
gpio_ms1    -m $OUTPUT -n $IR_CUT_P_PIN      -v $OFF  #Init IR cut drive control A
gpio_aud write $OUTPUT    $IR_CUT_N_PIN         $OFF  #Init IR cut drive control B
gpio_aud write $OUTPUT    $IR_CUT_DAYNIGHT_PIN  $ON   #Init day/night detector high first
usleep 30000
gpio_aud write $INPUT     $IR_CUT_DAYNIGHT_PIN  $OFF
gpio_aud write $OUTPUT    $LED_PIN              $OFF   #Disable LEDs initially

# Loop to check the day/night status
IR_ON=0

while :
do
    DAY=$(gpio_aud read "$IR_CUT_DAYNIGHT_PIN")
    if [ "$DAY" -eq 1 ]
    then
        if [ $IR_ON -eq 1 ]
        then
            echo 0x40 > /proc/isp/filter/saturation
            gpio_ms1    -m $OUTPUT -n $IR_CUT_P_PIN -v $OFF
            gpio_aud write $OUTPUT    $IR_CUT_N_PIN    $ON
            gpio_aud write $OUTPUT    $LED_PIN         $OFF
            usleep 120000
            gpio_ms1    -m $OUTPUT -n $IR_CUT_P_PIN -v $OFF
            gpio_aud write $OUTPUT    $IR_CUT_N_PIN    $OFF

            IR_ON=0
        fi
    else
        if [ $IR_ON -eq 0 ]
        then
            echo 0x0 > /proc/isp/filter/saturation
            gpio_ms1    -m $OUTPUT -n $IR_CUT_P_PIN -v $ON
            gpio_aud write $OUTPUT    $IR_CUT_N_PIN    $OFF
            gpio_aud write $OUTPUT    $LED_PIN         $ON
            usleep 120000
            gpio_ms1    -m $OUTPUT -n $IR_CUT_P_PIN -v $OFF
            gpio_aud write $OUTPUT    $IR_CUT_N_PIN    $OFF

            IR_ON=1
        fi
    fi
    sleep 3
done
