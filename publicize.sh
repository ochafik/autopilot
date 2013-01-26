#!/bin/bash

# Run every minute with:
# */1 * * * * /root/autopilot/publicize.sh

function fail() {
    echo "`tput bold``tput setaf 1`#" >&2
    echo "#" >&2
    echo "# ERROR: $@" >&2
    echo "#" >&2
    echo "#`tput sgr0`" >&2
    exit 1
}

function log_info() {
    echo "`tput bold`$@`tput sgr0`" >&2
}

function checkInstalled() {
    CMD=$1
    PACK=$2
    [[ -n "$CMD" && -n "$PACK" ]] || fail "No cmd or no package name(s) provided"
    which $CMD > /dev/null || fail "Command '$CMD' not found. Please install with something like \`sudo apt-get install $PACK\`"
}

function getLocalIP() {
    ETH=$1
    [[ -n "$ETH" ]] || fail "No interface"
    /sbin/ifconfig "$ETH" | grep "inet " | perl -p -e 's/^.*?inet (?:addr:)?(.*?) .*$/\1/'
}

function getExternalIP() {
    ( upnpc -s | grep ExternalIPAddress | perl -p -e 's/[^=]+= //' ) || fail "Failed to get external IP address"
}

function updateDynamicDNS() {
    NOIP_USER="$1"
    NOIP_PASSWORD="$2"
    NOIP_HOST="$3"
    NOIP_ADDRESS="$4"
    
    [[ -n "$NOIP_USER" ]] || fail "Missing no-ip user"
    [[ -n "$NOIP_PASSWORD" ]] || fail "Missing no-ip password"
    [[ -n "$NOIP_HOST" ]] || fail "Missing no-ip host"
    [[ -n "$NOIP_ADDRESS" ]] || fail "Missing no-ip address"
    
    CURRENT_NOIP_ADDRESS=`dig +short "$NOIP_HOST"`
    
    if [[ "$NOIP_ADDRESS" == "$CURRENT_NOIP_ADDRESS" ]]; then
        log_info "Host $NOIP_HOST is already associated with IP $NOIP_ADDRESS"
    else
        log_info "Updating host $NOIP_HOST to IP $NOIP_ADDRESS"
        RESPONSE=$(curl -s "http://dynupdate.no-ip.com/nic/update?hostname=$NOIP_HOST&myip=$NOIP_ADDRESS" -H "Host: dynupdate.no-ip.com" -H "Authorization: Basic `echo "$NOIP_USER:$NOIP_PASSWORD" | base64`" -H "User-Agent: $SCRIPT_NAME/$SCRIPT_VERSION olivier.chafik@gmail.com" || fail "Failed to contact the no-ip update server.")
        
        ( echo "$RESPONSE" | grep "\(nochg\|good\) `echo "$NOIP_ADDRESS" | sed 's/\./\\\\./'`" > /dev/null ) || fail "Failed to update IP for host '$NOIP_HOST' with user '$NOIP_USER': $RESPONSE"
    fi
}

function isIP() {
   IP="$1"
   [[ "$LOCAL_IP" =~ [0-9]+\.[0-9]+\.[0-9]+\.[0-9]+ ]] && [ "$LOCAL_IP" != "0.0.0.0" ]
}

log_info "Running as user $USER"

checkInstalled upnpc miniupnp
checkInstalled curl curl
checkInstalled dig dnsutils

UPNP_LIST="`upnpc -l`"

EXTERNAL_IP="`echo "$UPNP_LIST" | grep '^ExternalIPAddress = ' | head -n 1 | sed 's/^.*= //'`"

LOCAL_IP="`echo "$UPNP_LIST" | grep '^Local LAN ip address : ' | head -n 1 | sed 's/^.*: //'`"

log_info "Local IP: '$LOCAL_IP'"
log_info "External IP: '$EXTERNAL_IP'"

[[ -n "$EXTERNAL_IP" && -n "$LOCAL_IP" ]] || fail "Failed to get local and external IPs."

function currentRouteForPort() {
    PORT=$1
    PROTOCOL=$2
    [[ -n "$PORT" && -n "$PROTOCOL" ]] || fail "Bad call to currentRouteForPort"
    echo "$UPNP_LIST" | grep -E "[0-9]+ $PROTOCOL +$PORT->.*" | sed 's/^.*->//' | sed 's/ .*$//'
}

function openRouterPort() {
    NAME=$1
    LOCAL_IP=$2
    LOCAL_PORT=$3
    EXTERNAL_PORT=$4
    PROTOCOL=$5
    
    [[ -n "$NAME" ]] || fail "Missing service name"
    [[ -n "$LOCAL_IP" ]] || fail "Missing local ip"
    [[ -n "$LOCAL_PORT" ]] || fail "Missing local port"
    [[ -n "$EXTERNAL_PORT" ]] || fail "Missing external port"
    [[ -n "$PROTOCOL" ]] || fail "Missing protocol"
    
    CURRENT_ROUTE=`currentRouteForPort $EXTERNAL_PORT $PROTOCOL`
    EXPECTED_ROUTE="$LOCAL_IP:$LOCAL_PORT"
    
    if [[ -n "$CURRENT_ROUTE" && "$CURRENT_ROUTE" != "$EXPECTED_ROUTE" ]]; then
        log_info "Removing previous route $PROTOCOL $EXTERNAL_PORT->$CURRENT_ROUTE"
        upnpc -d "$EXTERNAL_PORT" "$PROTOCOL" || fail "Failed to remove previous route"
    fi
    
    if [[ "$CURRENT_ROUTE" == "$EXPECTED_ROUTE" ]]; then
        log_info "Port $PROTOCOL $EXTERNAL_PORT is already correctly routed to $EXPECTED_ROUTE"
    else
        log_info "Routing external port $PROTOCOL $EXTERNAL_PORT to $EXPECTED_ROUTE"
        upnpc -a "$LOCAL_IP" "$LOCAL_PORT" "$EXTERNAL_PORT" "$PROTOCOL" || fail "Failed to open port $EXTERNAL_PORT on router for $NAME"
    fi
}

# Equivalent to `vcgencmd getconfig $NAME`, with default value.
function getConfig() {
    NAME="$1"
    DEFAULT_VALUE="$2"
    
    VALUE=`cat /boot/config.txt 2>/dev/null | grep "^$NAME=" | head -n 1 | sed 's/^.*=//'`
    
    if [[ -z "$VALUE" ]]; then
        if [[ -z "$DEFAULT_VALUE" ]]; then
            fail "Failed to get config '$NAME' and no default value"
        else
            echo "$DEFAULT_VALUE"
        fi
    else
        echo "$VALUE"
    fi
}

EXTERNAL_SSH_PORT=${EXTERNAL_SSH_PORT:-`getConfig external_ssh_port 1022`}
if [[ -z "$SKIP_UPNP" ]]; then 
    openRouterPort "SSH" "$LOCAL_IP" 22 $EXTERNAL_SSH_PORT TCP
fi

NOIP_USER=${NOIP_USER:-`getConfig noip_user`}
NOIP_PASSWORD=${NOIP_PASSWORD:-`getConfig noip_password`}
NOIP_HOST=${NOIP_HOST:-`getConfig noip_host`}
if [[ -z "$SKIP_NOIP" ]]; then    
    updateDynamicDNS "$NOIP_USER" "$NOIP_PASSWORD" "$NOIP_HOST" "$EXTERNAL_IP"
fi

log_info "You can now connect with:
ssh -X pi@$NOIP_HOST -p $EXTERNAL_SSH_PORT"
