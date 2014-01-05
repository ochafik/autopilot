#!/bin/bash

CONFIG_FILE=${CONFIG_FILE:-/boot/config.txt}

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
    
    if [[ -f $CONFIG_FILE ]]; then
        values=`cat $CONFIG_FILE 2>/dev/null | grep -v "^$name="`
    else
        values=""
    fi
    echo "$values" > $CONFIG_FILE
    echo "$name=$value" >> $CONFIG_FILE
}

function read_config_var() {
    local var_name=$1
    local property_name=$2
    local prompt=$3
    local default_value=$4
 
    local current_value=`get_config "$property_name" "$default_value"`
    local value=""
    eval "$var_name=$current_value"
    if [[ -n "$TERM" ]]; then
        echo "$prompt [$current_value]:"
        read value
        if [[ -n "$value" ]]; then
            if [[ "$value" == '""' || "$value" == "''" ]]; then
                value=""
            fi
            eval "$var_name=\"$value\""
            set_config "$property_name" "$value"
        fi
    fi
}
