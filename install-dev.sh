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

[[ "$USER" != "root" ]] || fail "Please don't run as root."

sudo apt-get install maven2 bzr java svn git || fail "Failed to install core dependencies"

PUBKEY_FILE="~/.ssh/id_rsa.pub"
if [[ ! -d "$PUBKEY_FILE" ]]; then
  ssh-keygen -t rsa -C "olivier.chafik@gmail.com" || fail "Failed to generate ssh key"
  cat "$PUBKEY_FILE" || fail "No public key"
fi

mkdir ~/bin 2>/dev/null ; cd ~/bin

# http://www.java.net/download/JavaFXarm/jdk-8-ea-b36e-linux-arm-hflt-29_nov_2012.tar.gz
JDK8_DIR="~/bin/jdk1.8.0"
if [[ ! -d "$JDK8_DIR" ]]; then
    JDK8_ARCHIVE="jdk-8-ea-b36e-linux-arm-hflt-29_nov_2012.tar.gz"
    wget "http://www.java.net/download/JavaFXarm/$JDK8_ARCHIVE" || fail "Failed to get JDK 8"
    tar -zxvf "$JDK8_ARCHIVE" || fail "Failed to get JDK 8"
    rm "$JDK8_ARCHIVE"
    echo "export JAVA_HOME=$JDK8_DIR" >> ~/.profile
    echo "export PATH=\$JAVA_HOME/bin:\$PATH" >> ~/.profile
fi

mkdir ~/src ; cd ~/src

bzr co lp:pocl || fail "Failed to get pocl sources"

git clone git@github.com:ochafik/nativelibs4java.git || fail "Failed to clone NativeLibs4Java"

