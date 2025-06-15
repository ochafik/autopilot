#!/bin/bash
set -e

CONFIG_FILE=config.txt

source `dirname $0`/common.sh

read_config_var FOO foo "Please enter foo"
read_config_var FOO2 foo2 "Please enter foo2"

echo "FOO=$FOO, FOO2=$FOO2"

if once_a_day $1 && [[ "a" == "a" ]]; then
    echo "Once a day..."
fi
