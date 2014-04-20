#!/bin/bash

set -e

CLIENT_IP="$1"

if [[ -z "$CLIENT_IP" ]]; then
    echo "No client ip provided, stopping danted."
    /etc/init.d/danted stop
    exit 0
fi

function start() {
  /etc/init.d/danted start
}

trap start EXIT

echo "
# logoutput: syslog

internal: eth0 port=1080
external: eth0

clientmethod: none
method: none

user.privileged: root
user.notprivileged: nobody
user.libwrap: nobody

client pass {
  from: $CLIENT_IP/0 port 1-65535 to: 0.0.0.0/0
  log: error
}

pass {
  from: 0.0.0.0/0 to: 0.0.0.0/0
  log: error
}" > /etc/danted.conf
