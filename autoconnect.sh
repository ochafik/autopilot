#!/bin/bash

function up() {
    DEV=$1
    [[ -e "/dev/$DEV" ]] && ifup $DEV
}

up eth0
up wlan0
