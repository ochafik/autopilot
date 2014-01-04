#!/bin/bash

WIFI_DEV=wlan0
#WIFI_SSID=`getConfig ${WIFI_DEV}_ssid`
#WIFI_PASSWORD=`getConfig ${WIFI_DEV}_password`

function up() {
    local DEV=$1
    [[ -e "/dev/$DEV" ]] && ifup $DEV
}

function getLocalIP() {
    local ETH=$1
    [[ -n "$ETH" ]] || fail "No interface"
    /sbin/ifconfig "$ETH" | grep "inet " | perl -p -e 's/^.*?inet (?:addr:)?(.*?) .*$/\1/'
}

function getExternalIP() {
    ( upnpc -s | grep ExternalIPAddress | perl -p -e 's/[^=]+= //' ) || fail "Failed to get external IP address"
}

# function isIP() {
#    local IP="$1"
#    [[ "$LOCAL_IP" =~ [0-9]+\.[0-9]+\.[0-9]+\.[0-9]+ ]] && [ "$LOCAL_IP" != "0.0.0.0" ]
# }
