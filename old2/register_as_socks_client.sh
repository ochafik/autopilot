#!/bin/bash

set -e

function get_external_ip() {
  dig +short myip.opendns.com @resolver1.opendns.com
}

readonly HOST="$1"
readonly SSH_PORT="${SSH_PORT:-1022}"
readonly HOST_USER="${HOST_USER:-pi}"

readonly LAST_IP_FILE=~/.$(basename $0).last_external_ip
readonly EXTERNAL_IP=`get_external_ip`

if [[ -z "$HOST" ]]; then
    echo "Please specify the proxy host."
    exit 1
fi

if [[ ! -f "$LAST_IP_FILE" || "`cat "$LAST_IP_FILE"`" != "$EXTERNAL_IP" ]]; then
  # Note: we could use $EXTERNAL_IP, but opendns.com might not always be trustable: use the take the ip from the SSH_CLIENT variable instead.
  ssh $HOST_USER@$HOST -p $SSH_PORT 'sudo /root/autopilot/allow_client.sh `echo $SSH_CLIENT | awk "{ print \\$1}"`'
  echo "$EXTERNAL_IP" > "$LAST_IP_FILE"
fi
