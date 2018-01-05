#!/bin/bash


LIBFILE_NAME="library.sh"

HOST_REGEX="[a-zA-Z0-9_\.]+"
ORG_REGEX="[a-zA-Z0-9_\-]+"
REPO_REGEX="[a-zA-Z0-9_\-]+"
PATH_REGEX="[a-zA-Z0-9_\.\-\/]*"
VERSION_REGEX="[a-zA-Z0-9\.\-]+"

FULL_REGEX="($HOST_REGEX)\/($ORG_REGEX)\/($REPO_REGEX)($PATH_REGEX)?([@]$VERSION_REGEX)?"

#
# Converts a string of the format pointed bellow to an actual git url.
# <host>/<organization>/<repository>@<branch>
#
to_clone_url() {
	echo "https://$1/$2/$3.git"
}

find_host() {
	echo $1 | sed -E "s/$FULL_REGEX/\1/"
}

find_organization() {
	echo $1 | sed -E "s/$FULL_REGEX/\2/"
}

find_repository() {
	echo $1 | sed -E "s/$FULL_REGEX/\3/"
}

find_path() {
	echo -n "."
  echo $1 | sed -E "s/$FULL_REGEX/\4/"
}

find_version() {
	local version=`echo $1 | awk -F "@" '{print $NF}'`
	if [ "$version" == "$1" ]; then
		echo "master"
	elif [ -z "$version" ]; then
		echo "master"
	else
		echo $version
	fi
}

find_library_path() {
    local path=$1
    local filename=$LIBFILE_NAME;

    if [ -f $path ]; then
        filename=$(echo $path | awk -F "/" '{print $NF}')
        path=$(dirname $path)
    fi

	  pushd $path
	  if [ -f "$filename" ]; then
		    realpath $filename
	  fi
	  popd
}

# Utils
pushd () {
    command pushd "$@" > /dev/null
}

popd () {
    command popd "$@" > /dev/null
}

#
# Test code

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
	assert_equals "./dir1/dir2" $(find_path "github.com/my-org/my-repo/dir1/dir2/myscript.sh")
	assert_equals "./dir1" $(find_path "github.com/my-org/my-repo/dir1@master")
	assert_equals "./dir1/dir2" $(find_path "github.com/my-org/my-repo/dir1/dir2@master")
	assert_equals "./dir1/dir2" $(find_path "github.com/my-org/my-repo/dir1/dir2/myscript.sh@master")
	assert_equals "./dir1" $(find_path "github.com/my-org/my-repoi/dir1@5.0.0")
}

test_find_version() {
	assert_equals "master" $(find_version "github.com/org/repo")
	assert_equals "master" $(find_version "github.com/my-org/my-repo")
	assert_equals "master" $(find_version "github.com/my-org/my-repo@master")
	assert_equals "5.0.0" $(find_version "github.com/my-org/my-repo@5.0.0")
}


if [ -z "$1" ]; then
	exit 0;
elif [ "test" == "$1" ]; then
	test_find_host
	test_find_version
	test_find_organization
	test_find_repository
	test_find_path
	echo "Tests completed successfully!"
	exit 0
fi

# Command execution
host=$(find_host $1)
organization=$(find_organization $1)
repository=$(find_repository $1)
version=$(find_version $1)
path=$(find_path $1)
clone_url=$(to_clone_url $host $organization $repository)

shellib_home=${SHELLIB_HOME:=$HOME/.shellib}

mkdir -p $shellib_home/$organization/$repository
pushd $shellib_home/$organization/$repository

if [ -d $version ]; then
	# If version branch already exists, just rebase
	pushd $version
	git pull --rebase origin $version > /dev/null 2> /dev/null
  echo $(find_library_path $path)
	popd
else
	#Clone the repository
	git clone -b $version --single-branch $clone_url $shellib_home/$organization/$repository/$version > /dev/null 2> /dev/null
	pushd $version
  echo $(find_library_path $path)
	popd
fi
