#!/bin/bash

set -e

CLIENT_IP=`echo $SSH_CLIENT | awk '{ print $1}'`

if [[ -z "$CLIENT_IP" ]]; then
    echo "Failed to get client ip."
    exit 1
fi

/etc/init.d/danted stop

function start() {
  /etc/init.d/danted start
}

trap start EXIT

echo "
logoutput: syslog

internal: eth0 port=1080
external: eth0

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
