#!/bin/bash

install_package dig dnsutils
install_package upnpc miniupnpc
install_package curl

log_info "Configuring dynamic DNS"

read_config_var NOIP_HOST noip_host "Please enter no-ip host"
[[ -n "$NOIP_HOST" && -n `dig +short "$NOIP_HOST"` ]] || fail "Invalid host: '$NOIP_HOST'"

read_config_var NOIP_USER noip_user "Please enter no-ip username"
[[ -n "$NOIP_USER" ]] || fail "User needed."

read_config_var NOIP_PASSWORD noip_password "Please enter no-ip password"
[[ -n "$NOIP_PASSWORD" ]] || fail "Password needed."

