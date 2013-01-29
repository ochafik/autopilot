#!/bin/bash

function fail() {
    echo "`tput bold``tput setaf 1`#" >&2
    echo "#" >&2
    echo "# ERROR: $@" >&2
    echo "#" >&2
    echo "#`tput sgr0`" >&2
    exit 1
}

function log_info() {
    #echo "# $@" >&2
    echo "`tput bold`$@`tput sgr0`" >&2
}

[[ "$USER" == "root" ]] || fail "Please run as root with:
sudo $0"

if [[ "$NO_UPDATE" != "1" ]]; then
    log_info "Updating the package list (skip with NO_UPDATE=1)."
    apt-get update -y || fail "Update failed"
fi

log_info "Installing core tools"
apt-get install -y dnsutils curl git miniupnpc vim || fail "Core tools install failed"
apt-get install clean || fail "Failed to clean packages"

log_info "Getting parameters for no-ip dynamic DNS (see http://no-ip.org)"

function getConfig() {
    NAME="$1"
    cat /boot/config.txt 2>/dev/null | grep "^$NAME=" | head -n 1 | sed 's/^.*=//'
}

WIFI_SSID=`getConfig wifi_ssid`
if [[ -n "$TERM" ]]; then
    echo "Please enter the Wifi name / SSID [$WIFI_SSID]:"
    read NEW_WIFI_SSID || fail "Aborted by user"
    if [[ -n "$NEW_WIFI_SSID" ]]; then
        WIFI_SSID="$NEW_WIFI_SSID"
    fi
fi

WIFI_PASSWORD=`getConfig wifi_password`
if [[ -n "$TERM" ]]; then
    echo "Please enter the Wifi password [$WIFI_PASSWORD]:"
    read NEW_WIFI_PASSWORD || fail "Aborted by user"
    if [[ -n "$NEW_WIFI_PASSWORD" ]]; then
        WIFI_PASSWORD="$NEW_WIFI_PASSWORD"
    fi
fi

if [[ ! -f /boot/wpa_supplicant.conf ]]; then
    mv /etc/wpa_supplicant/wpa_supplicant.conf /boot/wpa_supplicant.conf
    ln -s /boot/wpa_supplicant.conf /etc/wpa_supplicant/wpa_supplicant.conf
fi

if [[ -n "$WIFI_SSID" ]]; then
    echo "$WIFI_PASSWORD" | wpa_passphrase "$WIFI_SSID" >> /etc/wpa_supplicant/wpa_supplicant.conf
fi

NOIP_HOST=`getConfig noip_host`
if [[ -n "$TERM" ]]; then
    echo "Please enter no-ip host [$NOIP_HOST]:"
    read NEW_NOIP_HOST || fail "Aborted by user"
    if [[ -n "$NEW_NOIP_HOST" ]]; then
        NOIP_HOST="$NEW_NOIP_HOST"
    fi
    [[ -n "$NOIP_HOST" && -n `dig +short "$NOIP_HOST"` ]] || fail "Invalid host: '$NOIP_HOST'"
fi

NOIP_USER=`getConfig noip_user`
if [[ -n "$TERM" ]]; then
    echo "Please enter no-ip user [$NOIP_USER]:"
    read NEW_NOIP_USER || fail "Aborted by user"
    if [[ -n "$NEW_NOIP_USER" ]]; then
        NOIP_USER="$NEW_NOIP_USER"
    fi
    [[ -n "$NOIP_USER" ]] || fail "User needed."
fi

NOIP_PASSWORD=`getConfig noip_password`
if [[ -n "$TERM" ]]; then
    echo "Please enter no-ip password [$NOIP_PASSWORD]:"
    read NEW_NOIP_PASSWORD || fail "Aborted by user"
    if [[ -n "$NEW_NOIP_PASSWORD" ]]; then
        NOIP_PASSWORD="$NEW_NOIP_PASSWORD"
    fi
    [[ -n "$NOIP_PASSWORD" ]] || fail "Password needed."
fi

log_info "Cloning autopilot repository."
if [[ -d /root/autopilot ]]; then
    cd /root/autopilot
    git pull || ( cd && rm -fR /root/autopilot )
fi
if [[ ! -d /root/autopilot ]]; then
    git clone git://github.com/ochafik/autopilot.git /root/autopilot || fail "Failed to clone autopilot scripts"
fi

log_info "Updating /boot/config.txt (editable from any OS)."
OLD_CONFIG="`cat /boot/config.txt | egrep -v "no-?ip"`"
CONFIG="# Edit these three lines to match your http://no-ip.org/ account.
noip_user=$NOIP_USER
noip_password=$NOIP_PASSWORD
noip_host=$NOIP_HOST
wifi_ssid=$WIFI_SSID
wifi_password=$WIFI_PASSWORD
$OLD_CONFIG"
echo "$CONFIG" > /boot/config.txt

OLD_CRONTAB=`crontab -l | grep -v '^$'`
FILTERED_CRONTAB=`echo "$CRONTAB" | grep -v "/root/autopilot" | grep -v '^$'`
CRONTAB="*/1 * * * * /root/autopilot/publicize.sh
*/1 * * * * /root/autopilot/autoconnect.sh
*/1 * * * * sleep 30 && cd /root/autopilot && git pull
$FILTERED_CRONTAB"

if [[ "$OLD_CRONTAB" != "$CRONTAB" ]]; then
    log_info "Updating crontab"
    echo "$CRONTAB" | crontab -
else
    log_info "Crontab already up-to-date"
fi

