#!/bin/sh

case "$1" in
start)
    killall brcm_patchram_plus1
    echo 0 >/sys/class/rfkill/rfkill0/state
    sleep 2
    echo 1 >/sys/class/rfkill/rfkill0/state
    sleep 2
    /usr/bin/brcm_patchram_plus1 --bd_addr_rand --enable_hci --no2bytes --use_baudrate_for_download --tosleep 200000 --baudrate 1500000 --patchram /system/etc/firmware/BCM4345C5.hcd /dev/ttyS8 > /dev/null 2>&1 &
    sleep 2
    hciconfig hci0 up
    ;;
stop)
    killall brcm_patchram_plus1
    ;;
*)
    echo "Usage: $0 {start|stop}"
    exit 1
    ;;
esac
