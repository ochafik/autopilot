#!/bin/bash


# Also see:
# http://www.mybigideas.co.uk/RPi/RPiCamera/

SERVER=$1
PORT=${2:-1234}
CLIENT=

echo ssh -C pi@$SERVER -C "( which nc || sudo apt-get install nc ) && raspivid -t 999999 -o - | nc \`echo \$SSH_CLIENT | awk '{ print \$1 }'\` $PORT"

