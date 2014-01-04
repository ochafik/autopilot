#!/bin/bash

source `dirname $0`/common.sh

checkRoot

#sudo ifup eth0

DEV=wlan0
WIFI_SSID=`get_config ${DEV}_ssid`
WIFI_PASSWORD=`get_config ${DEV}_password`

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
