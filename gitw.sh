#!/bin/bash

set -e

RED="\e[91m"
PLAIN="\e[0m"

unsafe_notice() {
    echo "${RED}UNSAFE command!${PLAIN} sleep 3s"
    sleep 3s
}

main() {
    [ "$1" == "help" ] && custom_help
    [ "$1" == "addall" ] && addall ${@:2}
    [ "$1" == "commits" ] && commits ${@:2}
    [ "$1" == "sync" ] && sync ${@:2}

    git "$@"
}

custom_help() {
    echo
    echo "$0 <command> [options]"
    echo
    echo "command:"
    echo "    help        show this message"
    echo "    addall      add all file to git"
    echo "    commits     git commit -s"
    echo "    sync        force sync remote"
    echo
    echo "options:"
    echo "    options for git"

    exit 0
}

addall() {
    pushd $(git rev-parse --show-toplevel) > /dev/null
    git add . "$@"
    popd > /dev/null

    exit 0
}

commits() {
    git commit -s "$@"
    exit 0
}

sync() {
    unsafe_notice

    git fetch
    git reset --hard FETCH_HEAD

    exit 0
}

main "$@"
