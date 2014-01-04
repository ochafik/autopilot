#!/bin/bash

set -e

readonly AUTOPILOT_HOME=${AUTOPILOT_HOME:-/root/autopilot}

if [[ "$USER" != "root" ]]; then
    echo "Please run as root with:
sudo $0"
    exit 1
fi

function log_info() {
    echo "`tput bold`$@`tput sgr0`" >&2
}

TODAY=`date +%Y%m%M`
if [[ ! -f ~/.update.timestamp || `cat ~/.update.timestamp` != "$TODAY" ]]; then
    log_info "Updating the package list"
    apt-get update -y
    echo "$TODAY" > ~/.update.timestamp
fi

log_info "Installing core tools"
apt-get install -y dnsutils curl git miniupnpc vim
apt-get clean

if [[ -d $AUTOPILOT_HOME ]]; then
    log_info "Updating autopilot repository."
    cd $AUTOPILOT_HOME
    git pull
else
    log_info "Cloning autopilot repository."
    git clone git://github.com/ochafik/autopilot.git $AUTOPILOT_HOME
fi

source $AUTOPILOT_HOME/common.sh

source $AUTOPILOT_HOME/install/install-wpa.sh
source $AUTOPILOT_HOME/install/install-noip.sh

read_config_var USER_EMAIL user_email
[[ -n "$USER_EMAIL" ]] || fail "User email needed."

log_info "You can edit $CONFIG_FILE from any OS to tweak these settings."

OLD_CRONTAB=`crontab -l | grep -v '^$'`
FILTERED_CRONTAB=`echo "$CRONTAB" | grep -v "autopilot" | grep -v '^$'`
CRONTAB="*/1 * * * * $AUTOPILOT_HOME/publicize.sh
*/1 * * * * $AUTOPILOT_HOME/autoconnect.sh
*/1 * * * * sleep 30 && cd $AUTOPILOT_HOME && git pull
$FILTERED_CRONTAB"

if [[ "$OLD_CRONTAB" != "$CRONTAB" ]]; then
    log_info "Updating crontab"
    echo "$CRONTAB" | crontab -
else
    log_info "Crontab already up-to-date"
fi

