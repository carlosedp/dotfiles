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

# Log message to console
# Usage: log <message> <color>
log () {
    if [ "${2:-}" ]; then
        printf "%b%b%b\n" "$2" "$1" "$RESET"
    else
        printf "%b%b%b\n" "$RESET" "$1" "$RESET"
    fi
}

# Test all log colors
logTest () {
    log "Test Black" "$BLACK"
    log "Test Red" "$RED"
    log "Test Red Bold" "$REDBOLD"
    log "Test Red Underline" "$REDUNDER"
    log "Test Green" "$GREEN"
    log "Test Green Bold" "$GREENBOLD"
    log "Test Green Underline" "$GREENUNDER"
    log "Test Yellow" "$YELLOW"
    log "Test Yellow Underline" "$YELLOWUNDER"
    log "Test Blue" "$BLUE"
    log "Test Magenta" "$MAGENTA"
    log "Test Cyan" "$CYAN"
    log "Test White" "$WHITE"
}

# Clone or pull git repository
# Usage: cloneorpull <user/repo> <destination_dir>
cloneorpull () {
    # $1 is the repository
    # $2 is the destination dir
    repo=$1
    dest=$2
    shift;shift;

    if [[ ! -d "$dest" ]]; then
        log "> Cloning $repo... into $dest" "$GREEN"
        git clone --quiet "$repo" "$dest" "$@"
    else
        log "> You already have $repo, updating..." "$GREEN"
        pushd "$dest" >/dev/null || return
        if [[ -n $(git status --porcelain) ]]; then
            log "> Your dir $dest has changes" "$MAGENTA"
        fi
        git pull --rebase --autostash --quiet "$@"
        popd >/dev/null || return
    fi
}

# Check if array contains element
# Usage: containsElement <array> <element>
containsElement () {
  local e match="$1"
  shift
  for e; do [[ "$e" == "$match" ]] && return 0; done
  return 1
}

# Create link from source to destination checking if it exists
# Usage: createLink <source> <destination>
createLink() {
  origin=$1
  dest=$2
  log " > Linking origin file \"$origin\" to destination \"$dest\""
  if [[ ! -e "$origin" ]]; then
    log " >> Origin $origin does not exist" "$RED"
    return
  fi
  if [[ ! -e "$(dirname "$dest")" ]]; then
    log " >> Destination $dest does not exist, creating" "$YELLOW"
    mkdir -p "$(dirname "$dest")"
  fi
  if [[ -f "$dest" || -d "$dest" ]] && [ ! -L "$dest" ]; then
      log " > Destination ($dest) already exists. Renaming to $dest-old" "$YELLOW"
      mv "$dest" "$dest-old"
  fi
  ln -sfn "$origin" "$dest"
}

# Link all files or directories from source to destination
# Usage: linkAll <source> <destination>
linkAll() {
  log " > Linking all files from origin \"$1\" to destination \"$2\""
  if [[ -e $1 ]]; then
    for FILE in "$1"/*
    do
      if ! [ -e "$FILE" ];then break; fi
      createLink "$FILE" "${2}/$(basename "$FILE")"
    done
  fi
}
