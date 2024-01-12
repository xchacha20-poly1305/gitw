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
    echo "    squash [HEAD]      squash some commits"
    echo
    echo "options:"
    echo "    options for git"
    echo
    echo "HEAD:"
    echo "    git hader, like HEAD^ or sha1"

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

squash() {
    if [ -z $(git branch --show-current) ]; then
        echo "You are not one a branch"
        exit 1
    fi

    unsafe_notice

    TARGET_COMMIT=$1
    NOW_COMMIT=$(git rev-parse HEAD)

    git reset --hard $TARGET_COMMIT
    git merge $NOW_COMMIT --squash
    git commit -s
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
    [ "$1" == "squash" ] && squash $2

    git $@
}

main $@
