#!/bin/bash

read_config_var WIFI_SSID wifi_ssid "Please enter the Wifi name / SSID"
read_config_var WIFI_PASSWORD wifi_password "Please enter the Wifi password"

readonly WPA_SUPPLICANT=/etc/wpa_supplicant/wpa_supplicant.conf
readonly WPA_SUPPLICANT_BOOT=/boot/wpa_supplicant.conf
if [[ ! -f $WPA_SUPPLICANT_BOOT ]]; then
    mv $WPA_SUPPLICANT $WPA_SUPPLICANT_BOOT
    ln -s $WPA_SUPPLICANT_BOOT $WPA_SUPPLICANT
fi
if [[ -n "$WIFI_SSID" ]]; then
    echo "$WIFI_PASSWORD" | wpa_passphrase "$WIFI_SSID" >> $WPA_SUPPLICANT
fi

