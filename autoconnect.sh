#!/bin/bash

function up() {
    DEV=$1
    [[ -e "/dev/$DEV" ]] && ifup $DEV
}

function getConfig() {
    NAME="$1"
    cat /boot/config.txt 2>/dev/null | grep "^$NAME=" | head -n 1 | sed 's/^.*=//'
}

#sudo ifup eth0

DEV=wlan0
WIFI_SSID=`getConfig ${DEV}_ssid`
WIFI_PASSWORD=`getConfig ${DEV}_password`

echo "WIFI_SSID=$WIFI_SSID (${DEV}_ssid)"
echo "WIFI_PASSWORD=$WIFI_PASSWORD (${DEV}_password)"

ARGS="-p /var/run/wpa_supplicant -i $DEV"
if [[ -n "$WIFI_SSID" ]]; then
    ID=`wpa_cli list | grep "$WIFI_SSID" | head -n 1 | awk '{ print $1 }'`
    if [[ -n "$ID" ]]; then
        echo "SSID '$WIFI_SSID' found with id $ID"
    else
        echo "SSID '$WIFI_SSID' not found, adding it"
        ID=`wpa_cli add_network | tail -n 1`
        wpa_cli $ARGS set_network $ID ssid "\"$WIFI_SSID\"" || fail "Failed to add wifi with ssid '$WIFI_SSID'."
    fi
    wpa_cli $ARGS set_network $ID psk "\"$WIFI_PASSWORD\"" || fail "Failed to set wifi password."
    wpa_cli $ARGS enable_network $ID || fail "Failed to enable wifi config."
    
    #sudo ifup $DEV
    #sudo iwconfig $DEV essid "$WIFI_SSID"
    #sudo dhclient $DEV
fi
