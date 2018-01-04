#!/bin/bash

source ./install.sh

TMPFILE=`mktemp -d -p /tmp/`
trap 'cleanup' EXIT

cleanup() {
    rm -rf $TMPFILE
}

test_download() {
    download $GRAB_URL $TMPFILE/test
    if [ ! -f $TMPFILE/test ]; then
        echo "Downloaded file not found!"
        exit 1
    fi
}

test_download
