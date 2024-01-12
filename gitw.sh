#!/bin/bash

set -e

########################## constant

RED="\e[91m"
PLAIN="\e[0m"

########################## shared functions

unsafe_notice() {
    echo -e "${RED}UNSAFE command!${PLAIN} sleep 3s"
    sleep 3s
}

########################## commands

custom_help() {
    echo
    echo "$0 <command> [options]"
    echo
    echo "command:"
    echo "    help        show this message"
    echo "    addall      add all file to git"
    echo "    commits     git commit -s"
    echo "    commita     git commit --amend"
    echo "    sync        force sync remote"
    echo "    clean       clean git reflog"
    echo
    echo "options:"
    echo "    options for git"

    exit 0
}

addall() {
    pushd $(git rev-parse --show-toplevel) >/dev/null
    git add . $@
    popd >/dev/null

    exit 0
}

commits() {
    git commit -s $@
    exit 0
}

commita() {
    unsafe_notice
    git commit --amend $@
    exit 0
}

sync() {
    unsafe_notice

    git fetch
    git reset --hard FETCH_HEAD

    exit 0
}

clean() {
    unsafe_notice

    git reflog expire --expire=now --all
    git gc --prune=now

    exit 0
}

############################# start

main() {
    OTHER_OPTIONS=${@:2}

    [ "$1" == "help" ] && custom_help
    [ "$1" == "addall" ] && addall $OTHER_OPTIONS
    [ "$1" == "commits" ] && commits $OTHER_OPTIONS
    [ "$1" == "commita" ] && commita $OTHER_OPTIONS
    [ "$1" == "sync" ] && sync $OTHER_OPTIONS
    [ "$1" == "clean" ] && clean

    git $@
}

main $@
