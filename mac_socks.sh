#!/bin/bash

set -e

readonly STATE="$1"
readonly HOST="$2"
readonly SOCKS_PORT="${SOCKS_PORT:-8080}"
readonly SSH_PORT="${SSH_PORT:-1022}"
readonly HOST_USER="${HOST_USER:-pi}"
readonly INTERFACE=${INTERFACE:-Wi-Fi}

case $STATE in
    off)
        sudo networksetup -setsocksfirewallproxystate $INTERFACE off
        ;;
    on)
        if [[ -z "$HOST" ]]; then
            echo "Please specify a host."
            exit 1
        fi
        ssh $HOST_USER@$HOST -p $SSH_PORT 'sudo /root/autopilot/allow_client.sh `echo $SSH_CLIENT | awk "{ print \\$1}"`'

        sudo networksetup -setsocksfirewallproxy $INTERFACE $HOST $SOCKS_PORT off
        sudo networksetup -setsocksfirewallproxystate $INTERFACE on
        ;;
    *)
        echo "Unknown state: '$STATE'"
        ;;
esac

