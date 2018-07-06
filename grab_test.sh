#!/bin/bash

source ./grab.sh

TMP_DIR=`mktemp -d -p /tmp/`
trap 'cleanup' EXIT

cleanup() {
    rm -rf $TMPFILE
    rm -rf $TMP_DIR
}

assert_equals() {
	if [ "$1" == "$2" ]; then
		return
	else
		echo "Expected [$1] but found [$2]!"
		exit 1
	fi
}

test_find_host() {
	assert_equals "github.com" $(find_host "github.com/org/repo")
	assert_equals "github.com" $(find_host "github.com/my-org/my-repo")
	assert_equals "github.com" $(find_host "github.com/my-org/my-repo/path")
	assert_equals "github.com" $(find_host "github.com/my-org/my-repo/path/myscript.sh")
	assert_equals "github.com" $(find_host "github.com/my-org/my-repo@master")
	assert_equals "github.com" $(find_host "github.com/my-org/my-repo@5.0.0")
	assert_equals "github.com" $(find_host "github.com/my-org/my-repo/path@5.0.0")
	assert_equals "github.com" $(find_host "github.com/my-org/my-repo/path/myscript.sh@5.0.0")
}

test_find_organization() {
	assert_equals "org" $(find_organization "github.com/org/repo")
	assert_equals "my-org" $(find_organization "github.com/my-org/my-repo")
	assert_equals "my-org" $(find_organization "github.com/my-org/my-repo/path")
	assert_equals "my-org" $(find_organization "github.com/my-org/my-repo/path/myscript.sh")
	assert_equals "my-org" $(find_organization "github.com/my-org/my-repo@master")
	assert_equals "my-org" $(find_organization "github.com/my-org/my-repo@5.0.0")
	assert_equals "my-org" $(find_organization "github.com/my-org/my-repo/path/@5.0.0")
	assert_equals "my-org" $(find_organization "github.com/my-org/my-repo/path/myscript.sh@5.0.0")
}

test_find_repository() {
	assert_equals "repo" $(find_repository "github.com/org/repo")
	assert_equals "my-repo" $(find_repository "github.com/my-org/my-repo")
	assert_equals "my-repo" $(find_repository "github.com/my-org/my-repo@master")
	assert_equals "my-repo" $(find_repository "github.com/my-org/my-repo@5.0.0")
}

test_find_path() {
	assert_equals "." $(find_path "github.com/org/repo")
	assert_equals "./dir1" $(find_path "github.com/my-org/my-repo/dir1")
	assert_equals "./dir1/dir2" $(find_path "github.com/my-org/my-repo/dir1/dir2")
	assert_equals "./dir1/dir2/myscript.sh" $(find_path "github.com/my-org/my-repo/dir1/dir2/myscript.sh")
	assert_equals "./dir1" $(find_path "github.com/my-org/my-repo/dir1@master")
	assert_equals "./dir1/dir2" $(find_path "github.com/my-org/my-repo/dir1/dir2@master")
	assert_equals "./dir1/dir2/myscript.sh" $(find_path "github.com/my-org/my-repo/dir1/dir2/myscript.sh@master")
	assert_equals "./dir1" $(find_path "github.com/my-org/my-repoi/dir1@5.0.0")
}

test_find_version() {
	assert_equals "master" $(find_version "github.com/org/repo")
	assert_equals "master" $(find_version "github.com/my-org/my-repo")
	assert_equals "master" $(find_version "github.com/my-org/my-repo@master")
	assert_equals "5.0.0" $(find_version "github.com/my-org/my-repo@5.0.0")
}

test_find_host
test_find_version
test_find_organization
test_find_repository
test_find_path

echo "Grab tests completed successfully!"
