#!/bin/bash

source ./install.sh

TMP_DIR=`mktemp -d -p /tmp/`
trap 'cleanup' EXIT

cleanup() {
    rm -rf $TMPFILE
    rm -rf $TMP_DIR
}

test_download() {
    download $GRAB_URL $TMPFILE/test
    if [ ! -f $TMPFILE/test ]; then
        download $GRAB_URL $TMP_DIR/grab
        if [ ! -f $TMP_DIR/grab ]; then
            echo "Downloaded file not found!"
            exit 1
        else
            chmod +x $TMP_DIR/grab
        fi
    fi
}

test_grab() {
    local libfile=$($TMP_DIR/grab github.com/shellib/cli)
    if [ ! -f $libfile ]; then
        echo "Grabbed library file not found!"
        exit 1
    fi
}

test_download
test_grab

echo "Install tests completed successfully!"
