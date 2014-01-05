#!/bin/bash

log_info "Configuring SOCKS proxy"

readonly DEFAULT_SOCKS_USER=proxima

read_config_var SOCKS_USER socks_user "Please enter the SOCKS user" "$DEFAULT_SOCKS_USER"
read_config_var SOCKS_PASSWORD socks_password "Please enter the SOCKS password"
read_config_var EXTERNAL_SOCKS_PORT external_socks_port "Please enter the external SOCKS port" 8080

install_package /etc/init.d/danted dante-server

if [[ -n "$SOCKS_USER" ]]; then
    [[ -n "$SOCKS_PASSWORD" ]] || fail "SOCKS password is needed"

    if ! grep "$SOCKS_USER" /etc/passwd > /dev/null; then
	log_info "Creating user $SOCKS_USER"
        useradd --system "$SOCKS_USER" -s /bin/false
    fi
    echo "$SOCKS_USER:$SOCKS_PASSWORD" | chpasswd

    echo "
#logging
logoutput: /var/log/sockd.log

internal: $NETWORK_DEVICE port=1080
internal: 127.0.0.1 port = 1080

external: $NETWORK_DEVICE

user.privileged: root
user.notprivileged: pi 
# user.libwrap: $SOCKS_USER

clientmethod: pam
method: pam

client pass {
        from: 0.0.0.0/0 to: 0.0.0.0/0
        log: connect error
	pamservicename: pam_host
}

#generic pass statement - bind/outgoing traffic
pass {  
        from: 0.0.0.0/0 to: 0.0.0.0/0
        command: bind connect udpassociate
        log: error # connect disconnect iooperation
	method: pam
}

#generic pass statement for incoming connections/packets
pass {
        from: 0.0.0.0/0 to: 0.0.0.0/0
        command: bindreply udpreply
        log: error # connect disconnect iooperation
}
" > /etc/danted.conf

    # See http://www.raspberrypi.org/phpBB3/viewtopic.php?f=66&t=34115
    readonly LIB_DIR=/lib/arm-linux-gnueabihf
    readonly LIBC_SO=$LIB_DIR/libc.so
    readonly LIBC_SO_6=$LIB_DIR/libc.so.6
    if [[ ! -f $LIBC_SO ]]; then
	ln -s $LIBC_SO_6 $LIBC_SO
    fi

    /etc/init.d/danted stop
    /etc/init.d/danted start
fi


