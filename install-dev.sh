#!/bin/bash

function fail() {
    echo "`tput bold``tput setaf 1`#" >&2
    echo "#" >&2
    echo "# ERROR: $@" >&2
    echo "#" >&2
    echo "#`tput sgr0`" >&2
    exit 1
}

function log_info() {
    #echo "# $@" >&2
    echo "`tput bold`$@`tput sgr0`" >&2
}

[[ "$USER" == "root" ]] || fail "Please run as root with:
sudo $0"

apt-get install maven2 bzr java svn git || fail "Failed to install core dependencies"

mkdir ~/bin ; cd ~/bin

JDK8_FILE="jdk-8-ea-b36e-linux-arm-hflt-29_nov_2012.tar.gz"
wget http://www.java.net/download/JavaFXarm/$JDK8_FILE || fail "Failed to get JDK 8"
tar -zxvf "$JDK8_FILE" || fail "Failed to get JDK 8"
rm "$JDK8_FILE"

mkdir ~/src ; cd ~/src

bzr co lp:pocl

git clone git@github.com:ochafik/nativelibs4java.git

