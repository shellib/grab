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

translate_as() {
    local script=$1
    if [ "$2" == "as" ] && [ -n "$3" ]; then
        local prefix=$3
        local source=`basename $script | cut -d "." -f1`
        local dir=`dirname $script`
        local target="$dir/${source}_as_$prefix.sh"
        local intermediate=$(mktemp -d grab-alias.XXXXXXXX)/$prefix.sh
        cp $1 $target
        grep -E '^[[:space:]]*([[:alnum:]_]+[[:space:]]*\(\)|function[[:space:]]+[[:alnum:]_]+)' $target | grep -v "::" | cut -d "{" -f1 | cut -d "(" -f1 | sed "s/^[ ]*function //g" | while read f; do
            cat $target | sed "s/\b$f\b/$prefix::$f/g" > $intermediate
            cat $intermediate > $target
        done
        echo $target
    else
        echo $1
    fi
}


# Utils
pushd () {
    command pushd "$@" > /dev/null
}

popd () {
    command popd "$@" > /dev/null
}

do_grab() {
    # Command execution
    local host=$(find_host $1)
    local organization=$(find_organization $1)
    local repository=$(find_repository $1)
    local version=$(find_version $1)
    local path=$(find_path $1)
    local clone_url=$(to_clone_url $host $organization $repository)

    local shellib_home=${SHELLIB_HOME:=$HOME/.shellib}


    mkdir -p $shellib_home/$organization/$repository
    pushd $shellib_home/$organization/$repository

    if [ -d $version ]; then
        # If version branch already exists, just rebase
        pushd $version
        git pull --rebase origin $version > /dev/null 2> /dev/null
        translate_as $(find_library_path $path) $2 $3
        popd
    else
        #Clone the repository
        git clone -b $version --single-branch $clone_url $shellib_home/$organization/$repository/$version > /dev/null 2> /dev/null
	pushd $version
        translate_as $(find_library_path $path) $2 $3
	popd
    fi
}

#Only run grab if script is not sourced (for unit test shake)
if [ -n "$1" ]; then
    do_grab $*
fi
