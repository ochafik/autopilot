#!/bin/bash

log_info "Configuring SOCKS server"

read_config_var SOCKS_USER socks_user "Please enter the SOCKS user"
read_config_var SOCKS_PASSWORD socks_password "Please enter the SOCKS password"
read_config_var EXTERNAL_SOCKS_PORT external_socks_port "Please enter the external SOCKS port"

if [[ -n "$SOCKS_USER" ]]; then
    [[ -z "$SOCKS_PASSWORD" ]] || fail "SOCKS password is needed"

    if ! grep "$SOCKS_USER" > /dev/null; then
        useradd --system "$SOCKS_USER" -s /bin/false
	echo "$SOCKS_PASSWORD" | passwd "$SOCKS_USER" --stdin
    fi
fi

echo "
#logging
logoutput: /var/log/sockd.log
#debug: 1

#server address specification
internal: 192.0.2.1 port = 1080
external: eth1

#server identities (not needed on solaris)
user.privileged: root
user.notprivileged: socks
#user.libwrap: libwrap

#reverse dns lookup
#srchost: nodnsmismatch

#authentication methods
method: username

#block communication with www.example.org
# block {
#        from: 0.0.0.0/0 to: www.example.org
#        command: bind connect udpassociate
#        log: error # connect disconnect iooperation
# }

#generic pass statement - bind/outgoing traffic
pass {  
        from: 0.0.0.0/0 to: 0.0.0.0/0
        command: bind connect udpassociate
        log: error # connect disconnect iooperation
	method: username
}

#generic pass statement for incoming connections/packets
pass {
        from: 0.0.0.0/0 to: 0.0.0.0/0
        command: bindreply udpreply
        log: error # connect disconnect iooperation
}
" > /etc/sockd.conf
