#!/bin/bash

set -e

########################## constant

RED="\e[91m"
YELLOW="\e[93m"
BLUE="\e[94m"
GREEN="\e[92m"
PLAIN="\e[0m"

########################## shared functions

unsafe_notice() {
    echo -e "${RED}UNSAFE command!${PLAIN} sleep 3s"
    sleep 3s
}

########################## commands

custom_help() {
    echo
    echo -e "${GREEN}$0 ${BLUE}<command> ${YELLOW}[options]${PLAIN}"
    echo
    echo "command:"
    echo -e "    ${BLUE}help${PLAIN}                show this message"
    echo -e "    ${BLUE}addall${PLAIN}              add all file to git"
    echo -e "    ${BLUE}commits${PLAIN}             git commit -s"
    echo -e "    ${BLUE}commita${PLAIN}             git commit --amend"
    echo -e "    ${BLUE}sync${PLAIN}                force sync remote"
    echo -e "    ${BLUE}clean${PLAIN}               clean git reflog"
    echo -e "    ${BLUE}squash [HEAD]${PLAIN}       squash some commits"
    echo
    echo -e "${YELLOW}options:${PLAIN}"
    echo "    options for git"
    echo
    echo -e "${YELLOW}HEAD:${PLAIN}"
    echo -e "    git hader, like HEAD^ or sha1"

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

    local TARGET_COMMIT=$1
    local NOW_COMMIT=$(git rev-parse HEAD)
    local OTHER_OPTIONS=${@:2}

    git reset --hard $TARGET_COMMIT
    git merge $NOW_COMMIT --squash
    git commit $OTHER_OPTIONS
}

############################# start

main() {
    [ "$1" == "clean" ] && clean
    [ "$1" == "squash" ] && squash $2

    local OTHER_OPTIONS=${@:2}

    [ "$1" == "help" ] && custom_help
    [ "$1" == "addall" ] && addall $OTHER_OPTIONS
    [ "$1" == "commits" ] && commits $OTHER_OPTIONS
    [ "$1" == "commita" ] && commita $OTHER_OPTIONS
    [ "$1" == "sync" ] && sync $OTHER_OPTIONS

    git $@
}

main $@
