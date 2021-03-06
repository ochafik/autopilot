#!/bin/bash

function fail() {
    if [[ -n "$TERM" ]]; then
        echo "`tput bold``tput setaf 1`#" >&2
    fi
    echo "#" >&2
    echo "# ERROR: $@" >&2
    echo "#" >&2
    if [[ -n "$TERM" ]]; then
       echo "#`tput sgr0`" >&2
    fi
    exit 1
}

function log_info() {
    if [[ -n "$TERM" ]]; then
        echo "`tput bold`$@`tput sgr0`" >&2
    else
        echo "$@" >&2
    fi
}

function checkInstalled() {
    local cmd=$1
    local pack=$2
    [[ -n "$cmd" && -n "$pack" ]] || fail "No cmd or no package name(s) provided"
    which $cmd > /dev/null || fail "Command '$cmd' not found. Please install with something like \`sudo apt-get install $pack\`"
}

function trim() {
    local var=$@
    var="${var#"${var%%[![:space:]]*}"}"
    var="${var%"${var##*[![:space:]]}"}"
    echo -n "$var"
}

function once_a_day() {
    local timestamp_file=~/.$1.timestamp
    local day_last_updated
    
    if [[ -f $timestamp_file ]]; then
        day_last_updated=`cat $timestamp_file`
    else
        day_last_updated=""
    fi
    local today=`date +%Y%m%M`
    if [[ "$day_last_updated" == "$today" ]]; then
        return 1
    else
        echo $today > $timestamp_file
        return 0
    fi
}

source `dirname $0`/common/common-config.sh
source `dirname $0`/common/common-net.sh

function checkRoot() {
    [[ "$USER" == "root" ]] || fail "Please run as root with:
sudo $0"
}
