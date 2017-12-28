#!/bin/bash

download() {
    if $(type curl &> /dev/null); then
        curl -o $2 $1
    elif $(type wget &> /dev/null); then
        wget -O $2 $1
    else
        echo "Failed to install shellib. Neither curl nor wget found!"
        exit 1
    fi

}

check_exists() {
    if $(type shellib &> /dev/null); then
        exit 0
    fi
}

SHELLIB_URL="https://raw.githubusercontent.com/shellib/shellib/master/shellib"

check_exists

#1. Try at $HOME/bin if exists
if [ -d $HOME/bin ]; then
    download $SHELLIB_URL $HOME/bin/shellib
    chmod +x $HOME/bin/shellib
fi

check_exists

#2. Try at /usr/local/bin
if [ -d /usr/local/bin ]; then
    download $SHELLIB_URL /usr/local/bin/shellib
    chmod +x /usr/local/bin/shellib
fi
