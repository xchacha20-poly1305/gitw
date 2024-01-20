#!/bin/bash

set -e

########################## constant

RED="\e[91m"
YELLOW="\e[93m"
BLUE="\e[94m"
GREEN="\e[92m"
PLAIN="\e[0m"

########################## shared functions

function unsafe_notice() {
    echo -e "${RED}UNSAFE command!${PLAIN}"

    for ((i = 3; i > 0; i--)); do
        echo -e "${YELLOW}$i${PLAIN}"
        sleep 1
    done
}

function now_commit() {
    git log -n 1 --pretty=format:%H ${@:2}
}

########################## commands

custom_help() {
    local script_name=$(basename "$0")

    echo
    echo -e "${GREEN}$script_name ${BLUE}<command> ${YELLOW}[options]${PLAIN}"
    echo
    echo "commands:"
    echo -e "    ${BLUE}help${PLAIN}                show this message"
    echo -e "    ${BLUE}add${PLAIN}                 add ${RED}all${PLAIN} file to git"
    echo -e "    ${BLUE}commits${PLAIN}             git commit -s"
    echo -e "    ${BLUE}commita${PLAIN}             git commit --amend"
    echo -e "    ${BLUE}sync${PLAIN}                force sync remote"
    echo -e "    ${BLUE}clean${PLAIN}               clean git reflog"
    echo -e "    ${BLUE}squash [HEAD]${PLAIN}       squash some commits"
    echo -e "    ${BLUE}now${PLAIN}                 Show now HEAD"
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

    git fetch $@
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
    local NOW_COMMIT=$(now_commit)
    local OTHER_OPTIONS=${@:2}

    git reset --hard $TARGET_COMMIT
    git merge $NOW_COMMIT --squash
    git commit $OTHER_OPTIONS

    exit 0
}

now() {
    now_commit ${@:2}
    exit 0
}

############################# start

main() {
    [ "$1" == "clean" ] && clean

    local OTHER_OPTIONS=${@:2}

    [ "$1" == "help" ] && custom_help
    [ "$1" == "add" ] && addall $OTHER_OPTIONS
    [ "$1" == "commits" ] && commits $OTHER_OPTIONS
    [ "$1" == "commita" ] && commita $OTHER_OPTIONS
    [ "$1" == "sync" ] && sync $OTHER_OPTIONS
    [ "$1" == "squash" ] && squash $OTHER_OPTIONS
    [ "$1" == "now" ] && now $OTHER_OPTIONS

    git $@
}

main $@
