#!/bin/bash


LIBFILE_NAME="library.sh"

HOST_REGEX="[a-zA-Z0-9_\.]+"
ORG_REGEX="[a-zA-Z0-9_\-]+"
REPO_REGEX="[a-zA-Z0-9_\-]+"
PATH_REGEX="[a-zA-Z0-9_\.\-\/]*"
VERSION_REGEX="[a-zA-Z0-9\.\-]+"

FUNCTION_PATTERN='^[[:space:]]*([[:alnum:]_]+[[:space:]]*\(\)|function[[:space:]]+[[:alnum:]_]+)'

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
    local prefix=""
    local separator=""
    local source=`basename $script | cut -d "." -f1`
    local dir=`dirname $script`
    local target="$script"

    local tmp_dir=$(mktemp -d /tmp/grab-alias.XXXXXXXX)
    local tmp_source=$tmp_dir/source.sh
    local tmp_target=$tmp_dir/target.sh

    local needs_normalization=`grep -E $FUNCTION_PATTERN $script | grep "^__"`


    #If an alias has been specified....
    if [ "$2" == "as" ] && [ -n "$3" ]; then
        prefix=$3
        separator="::"
        mkdir -p $dir/.alias/$source
        target="$dir/.alias/${source}/$prefix.sh"
    elif [ -n "$needs_normalization" ]; then
        mkdir -p $dir/.normalized
        target="$dir/.normalized/${source}.sh"
    fi

    cp $script $tmp_source
    cp $script $tmp_target

    grep -E $FUNCTION_PATTERN $tmp_source | grep -v "::" | cut -d "{" -f1 | cut -d "(" -f1 | sed "s/^[ ]*function //g" | while read func; do
        cat $tmp_source | sed "s/\b$func\b/$prefix$separator$func/g" > $tmp_target
        cp $tmp_target $tmp_source
        local normalized=`echo $func | sed "s/^__//g"`
        if [ "$normalized" != "$func" ]; then
            cat $tmp_source | sed "s/$func/$normalized/g" > $tmp_target
            cp $tmp_target $tmp_source
        fi
    done

    cp $tmp_target $target
    echo $target
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


    mkdir -p $shellib_home/$host/$organization/$repository
    pushd $shellib_home/$host/$organization/$repository

    if [ -d $version ]; then
        pushd $version
        if [ "master" == "$version" ]; then
            # If version branch already exists, just rebase
            git pull --rebase origin $version > /dev/null 2> /dev/null
        fi
        translate_as $(find_library_path $path) $2 $3
        popd
    else
        #Clone the repository
        git clone -b $version --single-branch $clone_url $shellib_home/$host/$organization/$repository/$version > /dev/null 2> /dev/null
        pushd $version
        translate_as $(find_library_path $path) $2 $3
        popd
    fi
}

#Only run grab if script is not sourced (for unit test shake)
if [ -n "$1" ]; then
    do_grab $*
fi
