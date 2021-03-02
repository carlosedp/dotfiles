#!/usr/bin/env bash

# Log to terminal with colors
BLACK="\e[30m"
RED="\e[31m"
REDBOLD="\e[31m\e[1m"
REDUNDER="\e[31m\u001b[4m"
GREEN="\e[32m"
GREENBOLD="\e[32m\e[1m"
GREENUNDER="\e[32m\u001b[4m"
YELLOW="\e[33m"
YELLOWUNDER="\e[33m\u001b[4m"
BLUE="\e[34m"
MAGENTA="\e[35m"
CYAN="\e[36m"
WHITE="\e[37m"
RESET="\e[0m"

log () {
    if [ -z ${2+x} ]; then
        echo $(printf "$2$1 $RESET")
    else
        echo $(printf "$RESET$1 $RESET")
    fi
}

logtest () {
    log "Test Black" $BLACK
    log "Test Red" $RED
    log "Test Red Bold" $REDBOLD
    log "Test Red Underline" $REDUNDER
    log "Test Green" $GREEN
    log "Test Green Bold" $GREENBOLD
    log "Test Green Underline" $GREENUNDER
    log "Test Yellow" $YELLOW
    log "Test Yellow Underline" $YELLOWUNDER
    log "Test Blue" $BLUE
    log "Test Magenta" $MAGENTA
    log "Test Cyan" $CYAN
    log "Test White" $WHITE
}

# Clone or pull git repository
function cloneorpull () {
    # $1 is the repository
    # $2 is the destination dir
    repo=$1
    dest=$2
    shift;shift;

    if [[ ! -d "$dest" ]]; then
        log "> Cloning $repo... into $dest" $GREEN
        git clone --quiet $repo "$dest" $@
    else
        log "> You already have $repo, updating..." $GREEN
        pushd $dest >/dev/null
        if [[ ! -z $(git status --porcelain) ]]; then
            log "> Your dir $dest has changes" $MAGENTA
        fi
        git pull --autostash --quiet $@
        popd >/dev/null
    fi
}

# Check if array contains element
containsElement () {
  local e match="$1"
  shift
  for e; do [[ "$e" == "$match" ]] && return 0; done
  return 1
}
