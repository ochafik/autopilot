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
apt-get install -y dnsutils curl git miniupnpc || fail "Core tools install failed"

log_info "Getting parameters for no-ip dynamic DNS (see http://no-ip.org)"

function getConfig() {
    NAME="$1"
    cat /boot/config.txt 2>/dev/null | grep "^$NAME=" | head -n 1 | sed 's/^.*=//'
}

OLD_NOIP_HOST=`getConfig noip_host`
if [[ -z "$TERM" ]]; then
    NOIP_HOST="$OLD_NOIP_HOST"
else
    echo "Please enter no-ip host [$OLD_NOIP_HOST]:"
    read NOIP_HOST || fail "Aborted by user"
    if [[ -z "$NOIP_HOST" ]]; then
        NOIP_HOST="$OLD_NOIP_HOST"
        [[ -n "$NOIP_HOST" && -n `dig +short "$NOIP_HOST"` ]] || fail "Invalid host: '$NOIP_HOST'"
    fi
fi

OLD_NOIP_USER=`getConfig noip_user`
if [[ -z "$TERM" ]]; then
    NOIP_USER="$OLD_NOIP_USER"
else
    echo "Please enter no-ip user [$OLD_NOIP_USER]:"
    read NOIP_USER || fail "Aborted by user"
    if [[ -z "$NOIP_USER" ]]; then
        NOIP_USER="$OLD_NOIP_USER"
        [[ -n "$NOIP_USER" ]] || fail "User needed."
    fi
fi

OLD_NOIP_PASSWORD=`getConfig noip_password`
if [[ -z "$TERM" ]]; then
    NOIP_PASSWORD="$OLD_NOIP_PASSWORD"
else
    echo "Please enter no-ip password [$OLD_NOIP_PASSWORD]:"
    read NOIP_PASSWORD || fail "Aborted by user"
    if [[ -z "$NOIP_PASSWORD" ]]; then
        NOIP_PASSWORD="$OLD_NOIP_PASSWORD"
        [[ -n "$NOIP_PASSWORD" ]] || fail "Password needed."
    fi
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
$OLD_CONFIG"
echo "$CONFIG" > /boot/config.txt

log_info "Registering various cron jobs."
OLD_CRONTAB=`crontab -l`
FILTERED_CRONTAB=`echo "$CRONTAB" | grep -v "/root/autopilot"`
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

