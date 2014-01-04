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

function checkInstalled() {
    local cmd=$1
    local pack=$2
    [[ -n "$cmd" && -n "$pack" ]] || fail "No cmd or no package name(s) provided"
    which $cmd > /dev/null || fail "Command '$cmd' not found. Please install with something like \`sudo apt-get install $pack\`"
}

source `basedir $0`/common-config.sh
source `basedir $0`/common-net.sh

function checkRoot() {
    [[ "$USER" == "root" ]] || fail "Please run as root with:
sudo $0"
}
