#!/bin/bash
# Run every minute with:
# */1 * * * * /root/autopilot/publicize.sh

source `dirname $0`/common.sh

checkRoot

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
    
    if once_a_day publicize && [[ "$NOIP_ADDRESS" == "$CURRENT_NOIP_ADDRESS" ]]; then
        log_info "Host $NOIP_HOST is already associated with IP $NOIP_ADDRESS"
    else
        log_info "Updating host $NOIP_HOST to IP $NOIP_ADDRESS"
        RESPONSE=$(curl -s "http://dynupdate.no-ip.com/nic/update?hostname=$NOIP_HOST&myip=$NOIP_ADDRESS" -H "Host: dynupdate.no-ip.com" -H "Authorization: Basic `echo "$NOIP_USER:$NOIP_PASSWORD" | base64`" -H "User-Agent: $SCRIPT_NAME/$SCRIPT_VERSION olivier.chafik@gmail.com" || fail "Failed to contact the no-ip update server.")
        
        ( echo "$RESPONSE" | grep "\(nochg\|good\) `echo "$NOIP_ADDRESS" | sed 's/\./\\\\./'`" > /dev/null ) || fail "Failed to update IP for host '$NOIP_HOST' with user '$NOIP_USER': $RESPONSE"
    fi
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

EXTERNAL_SSH_PORT=${EXTERNAL_SSH_PORT:-`get_config external_ssh_port 1022`}
if [[ -z "$SKIP_UPNP" ]]; then 
    openRouterPort "SSH" "$LOCAL_IP" 22 $EXTERNAL_SSH_PORT TCP
fi

NOIP_USER=${NOIP_USER:-`get_config noip_user`}
NOIP_PASSWORD=${NOIP_PASSWORD:-`get_config noip_password`}
NOIP_HOST=${NOIP_HOST:-`get_config noip_host`}
if [[ -z "$SKIP_NOIP" ]]; then    
    updateDynamicDNS "$NOIP_USER" "$NOIP_PASSWORD" "$NOIP_HOST" "$EXTERNAL_IP"
fi

log_info "You can now connect with:
ssh -X pi@$NOIP_HOST -p $EXTERNAL_SSH_PORT"
