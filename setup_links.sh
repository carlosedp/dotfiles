#!/usr/bin/env bash

# ------------------------------------------------------------------------------
# Settings
# ------------------------------------------------------------------------------
SYNC_FOLDER="$HOME/Dropbox"

# ------------------------------------------------------------------------------
# Utility Funtions
# ------------------------------------------------------------------------------
RED="\e[31m"
REDBOLD="\e[31m\e[1m"
GREEN="\e[32m"
YELLOW="\e[33m"
RESET="\e[0m"

log () {
    if [ $2 ]; then
        echo $(printf "$2$1 $RESET")
    else
        echo $(printf "$RESET$1 $RESET")
    fi
}

create_link() {
  origin=$1
  dest=$2
  log " > Linking origin file \"$origin\" to destination \"$dest\""
  if [[ ! -e "$origin" ]]; then
    log " >> Origin $origin does not exist" $RED
    return 1
  fi
  if [[ -f "$dest" || -d "$dest" ]] && [ ! -L "$dest" ]; then
      log " > Destination ($dest) already exists. Renaming to $dest-old" $YELLOW
      mv "$dest" "$dest-old"
  fi
  ln -sfn "$origin" "$dest"
}

#-------------------------------------------------------------------------------
# Script start
# ------------------------------------------------------------------------------

if [ $(uname -s) == "Darwin" ] && [ ! -d "$SYNC_FOLDER" ]; then
  log "----------------------------------------------------------------" $REDBOLD
  log "Could not find the source for private files (Dropbox or GDrive)." $REDBOLD
  log "Adjust the setup_links.sh script or sync your files first." $REDBOLD
  log "Your source folder is currently set to $SYNC_FOLDER" $REDBOLD
  log "----------------------------------------------------------------" $REDBOLD
  echo ""
fi

log "Setting links to dotfiles on user home dir: $HOME" $GREEN

# Link .rc files
log "Linking .rc files" $GREEN
for FILE in $HOME/.dotfiles/rc/*
do
  create_link $FILE ~/.$(basename $FILE)
done

# Link SSH keys
log "Linking .ssh directory" $GREEN
if [[ -d "$SYNC_FOLDER/Configs/SSH_Keys" ]]; then
    ln -sfn "$SYNC_FOLDER/Configs/SSH_Keys" $HOME/.ssh
fi

# List of settings to be syncd between computers. Separated by spaces.
if [ $(uname -s) == "Darwin" ]; then
  ## Settings from $HOME/Library/Application Support
  log "Linking ~/Library/Application Support files" $GREEN
  for X in $(ls "$SYNC_FOLDER/Configs/AppSupport/")
  do
    create_link "$SYNC_FOLDER/Configs/AppSupport/$X" "$HOME/Library/Application Support/$X"
  done

  ## Link preferences from ~/Library/Preferences/
  log "Linking ~/Library/Preferences files" $GREEN
  for X in $(ls "$SYNC_FOLDER/Configs/Preferences/")
  do
    create_link "$SYNC_FOLDER/Configs/Preferences/$X" "$HOME/Library/Preferences/$X"
  done

  ## Link workflows from ~/Library/Services/
  log "Linking ~/Library/Services (automator) files" $GREEN
  for X in $(ls "$SYNC_FOLDER/Configs/automator/")
  do
    create_link "$SYNC_FOLDER/Configs/automator/"$X "$HOME/Library/Services/$X"
  done
fi

log "Setting links finished" $GREEN
