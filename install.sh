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

log_info "Getting parameters for no-ip dynamic DNS (see http://no-ip.org)"

echo "Please enter no-ip host:"
read NOIP_HOST || fail "Aborted by user"
[[ -n "$NOIP_HOST" && -n `dig +short "$NOIP_HOST"` ]] || fail "Invalid host: '$NOIP_HOST'"

echo "Please enter no-ip user:"
read NOIP_USER || fail "Aborted by user"
[[ -n "$NOIP_USER" ]] || fail "User needed."

echo "Please enter no-ip password:"
read NOIP_PASSWORD || fail "Aborted by user"
[[ -n "$NOIP_PASSWORD" ]] || fail "Password needed."

log_info "Updating the OS"
apt-get update || fail "Update failed"

log_info "Installing core tools"
apt-get install dnsutils curl miniupnp wpasupplicant || fail "Core tools install failed"

log_info "Cloning autopilot repository."
git clone git://github.com/ochafik/autopilot.git /root/autopilot

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
    echo "$CRONTAB" | crontab
else
    log_info "Crontab already up-to-date"
fi

