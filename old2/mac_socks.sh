#!/bin/bash

set -e

readonly HOST="$1"
readonly SOCKS_PORT="${SOCKS_PORT:-8080}"
readonly SSH_PORT="${SSH_PORT:-1022}"
readonly HOST_USER="${HOST_USER:-pi}"
readonly INTERFACE=${INTERFACE:-Wi-Fi}

if [[ -z "$HOST" ]]; then
    echo "Please specify the proxy host."
    exit 1
fi

function cleanup() {
    echo ""
    echo "Disabling proxy"
    sudo networksetup -setsocksfirewallproxystate $INTERFACE off
    # ssh $HOST_USER@$HOST -p $SSH_PORT 'sudo /root/autopilot/allow_client.sh ""'
}

trap cleanup EXIT

# ssh $HOST_USER@$HOST -p $SSH_PORT 'sudo /root/autopilot/allow_client.sh `echo $SSH_CLIENT | awk "{ print \\$1}"`'

sudo networksetup -setsocksfirewallproxy $INTERFACE $HOST $SOCKS_PORT off
sudo networksetup -setsocksfirewallproxystate $INTERFACE on

echo "Proxy enabled (interrupt this command to disable)."

tail -f /dev/null & wait

