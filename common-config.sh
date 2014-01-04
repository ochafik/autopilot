#!/bin/bash

readonly CONFIG_FILE=${CONFIG_FILE:-/boot/config.txt}

# function get_config() {
#     NAME="$1"
#     cat /boot/config.txt 2>/dev/null | grep "^$NAME=" | head -n 1 | sed 's/^.*=//'
# }

# Equivalent to `vcgencmd getconfig $NAME`, with default value.
function get_config() {
    local name="$1"
    local default_value="$2"
    local value=`cat $CONFIG_FILE 2>/dev/null | grep "^$name=" | head -n 1 | sed 's/^.*=//'`
    
    if [[ -z "$value" ]]; then
        if [[ -z "$default_value" ]]; then
            fail "failed to get config '$name' and no default value"
        else
            echo "$default_value"
        fi
    else
        echo "$value"
    fi
}

function set_config() {
    local name="$1"
    local value="$2"
    
    values=`cat $CONFIG_FILE 2>/dev/null | grep -v "^$name="`
    echo $values > $CONFIG_FILE
    echo "$name=$value" >> $CONFIG_FILE
}

function read_config_var() {
    local var_name=$1
    local property_name=$2
    local prompt=$3
    
    local default_value=`get_config "$property_name"`
    local value
    eval "$var_name=$default_value"
    if [[ -n "$TERM" ]]; then
        echo "$prompt [$default_value]:"
        read value || fail "Aborted by user"
        if [[ -n "$value" ]]; then
            eval "$var_name=$value"
            set_config "$property_name" "$value"
        fi
    fi
}
