#!/bin/bash

source `dirname $0`/common.sh

# http://www.youtube.com/watch?v=O7D7UkA3IKQ

if [[ ! -d /usr/share/doc/openvpn ]]; then
    apt-get -y install openvpn openssl ssl-cert
    apt-get clean
fi

USER_EMAIL=`get_config user_email`
ssh-keygen -t rsa -C "$USER_EMAIL"

# http://blog.remibergsma.com/2013/01/05/building-an-economical-openvpn-server-using-the-raspberry-pi/
cp -R /usr/share/doc/openvpn/examples/easy-rsa /etc/openvpn
cd /etc/openvpn/easy-rsa/2.0

export COMMON_KEY_PARAMS="UK
EN
London
NativeLibs4Java
raspberrypi
Olivier Chafik
olivier.chafik@gmail.com"
export PASSWORD=dgem5mnu

. ./vars
./clean-all
./build-ca
./build-key-server server
./build-key client-name
./build-dh

cd keys
cp ca.crt ca.key dh1024.pem server.crt server.key /etc/openvpn

cp /usr/share/doc/openvpn/examples/sample-config-files/server.conf.gz /etc/openvpn
gunzip /etc/openvpn/server.conf.gz
vi /etc/openvpn/server.conf

/etc/init.d/openvpn start

ifconfig tun0

#Dev

mkdir ~/bin ; cd ~/bin
wget http://www.java.net/download/JavaFXarm/jdk-8-ea-b36e-linux-arm-hflt-29_nov_2012.tar.gz
tar -zxvf jdk-*.tar.gz

mkdir ~/src ; cd ~/src
bzr co lp:pocl
git clone git@github.com:ochafik/nativelibs4java.git

