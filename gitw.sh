#!/bin/bash

set -e
# set -x

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
    git log -n 1 --pretty=format:%H "$1"
}

########################## commands

custom_help() {
    # shellcheck disable=SC2155
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
    echo -e "    ${BLUE}pick [HEAD]${PLAIN}         auto pick commit"
    echo
    echo -e "${YELLOW}options:${PLAIN}"
    echo "    options for git"
    echo
    echo -e "${YELLOW}HEAD:${PLAIN}"
    echo -e "    git hader, like HEAD^ or sha1"
}

addall() {
    pushd "$(git rev-parse --show-toplevel)" >/dev/null
    # shellcheck disable=SC2068
    git add . $@
    popd >/dev/null
}

commits() {
    # shellcheck disable=SC2068
    git commit -s $@
}

commita() {
    unsafe_notice
    # shellcheck disable=SC2068
    git commit --amend $@
}

sync() {
    unsafe_notice

    # shellcheck disable=SC2068
    git fetch $@
    git reset --hard FETCH_HEAD
}

clean() {
    unsafe_notice

    git reflog expire --expire=now --all
    git gc --prune=now
}

squash() {
    if [ -z "$(git branch --show-current)" ]; then
        echo "You are not one a branch"
        exit 1
    fi

    unsafe_notice

    local TARGET_COMMIT=$1
    # shellcheck disable=SC2155
    local NOW_COMMIT=$(now_commit HEAD)
    # shellcheck disable=SC2124
    local OTHER_OPTIONS=${@:2}

    git reset --hard "$TARGET_COMMIT"
    git merge "$NOW_COMMIT" --squash
    git commit $OTHER_OPTIONS
}

now() {
    now_commit HEAD
}

auto_pick() {
    local PICK_COMMIT=$1
    # shellcheck disable=SC2155
    local NOW_COMMIT=$(now_commit HEAD)
    # shellcheck disable=SC2124
    local OTHER_OPTIONS=${@:2}

    # shellcheck disable=SC2155
    local pick_parent=$(now_commit "${PICK_COMMIT}^")

    if [[ "$pick_parent" == ${NOW_COMMIT}* ]]; then
        git merge "$PICK_COMMIT" --ff-only \
            $OTHER_OPTIONS
    else
        git cherry-pick "$PICK_COMMIT" \
            $OTHER_OPTIONS
    fi
}

############################# start

main() {
    [ "$1" == "clean" ] && clean

    # shellcheck disable=SC2124
    local OTHER_OPTIONS=${@:2}

    case "${1}" in
    "help")
        custom_help
        exit 0
        ;;
    "add")
        # shellcheck disable=SC2086
        addall $OTHER_OPTIONS
        exit 0
        ;;
    "commits")
        # shellcheck disable=SC2086
        commits $OTHER_OPTIONS
        exit 0
        ;;
    "commita")
        # shellcheck disable=SC2086
        commita $OTHER_OPTIONS
        exit 0
        ;;
    "sync")
        # shellcheck disable=SC2086
        sync $OTHER_OPTIONS
        exit 0
        ;;
    "clean")
        # shellcheck disable=SC2086
        clean $OTHER_OPTIONS
        exit 0
        ;;
    "squash")
        # shellcheck disable=SC2086
        squash $OTHER_OPTIONS
        exit 0
        ;;
    "now")
        # shellcheck disable=SC2086
        now $OTHER_OPTIONS
        exit 0
        ;;
    "pick")
        # shellcheck disable=SC2086
        auto_pick $OTHER_OPTIONS
        exit 0
        ;;
    *) ;;
    esac

    # shellcheck disable=SC2068
    git $@
}

# shellcheck disable=SC2068
main $@
