#!/bin/bash

download() {
    if $(type curl &> /dev/null); then
        curl -o $2 $1
    elif $(type wget &> /dev/null); then
        wget -O $2 $1
    else
        echo "Failed to install grab. Neither curl nor wget found!"
        exit 1
    fi

}

check_exists() {
    if $(type grab &> /dev/null); then
        exit 0
    fi
}

GRAB_URL="https://raw.githubusercontent.com/shellib/grab/master/grab"

check_exists

#1. Try at $HOME/bin if exists
if [ -d $HOME/bin ]; then
    download $GRAB_URL $HOME/bin/grab
    chmod +x $HOME/bin/grab
fi

check_exists

#2. Try at /usr/local/bin
if [ -d /usr/local/bin ]; then
    download $GRAB_URL /usr/local/bin/grab
    chmod +x /usr/local/bin/grab
fi
