#!/bin/bash

echo "Setting dotfiles on user home dir: $HOME"

# Settings
sync_folder="$HOME/Google\ Drive"

# List of settings to be syncd between computers. Separated by spaces.
# Settings from $HOME/Library/Containers
container_settings='com.termius.mac'
# Settings from $HOME/Library/Application Support
application_support_settings='iTerm2'

create_link() {
  origin=$1
  dest=$2
  echo Linking origin file \"$origin\" to destination \"$dest\"

  if [[ -f "$dest" || -d "$dest" ]] && [ ! -L "$dest" ]; then
      echo "Destination ($dest) already exists. Renaming to $dest-old"
      mv "$dest" "$dest-old"
  fi
  ln -sf "$origin" "$dest"
}

# Link .rc files
for FILE in $HOME/.dotfiles/rc/*
do
  create_link $FILE ~/.$(basename $FILE)
done

# Link SSH keys
if [[ ! -d "$sync_folder/SSH_Keys" ]]; then
    ln -sf "$sync_folder/SSH_Keys" $HOME/.ssh
fi

if [ $(uname) == "Darwin" ]; then
  # Link settings from ~/Library/Containers
  for X in $container_settings
  do
    create_link "$sync_folder/Configs/$X" "$HOME/Library/Containers/$X"
  done

  # Link settings from ~/Library/Application Support
  for X in $application_support_settings
  do
    create_link "$sync_folder/Configs/$X" "$HOME/Library/Application Support/$X"
  done

  # Link preferences from ~/Library/Preferences
  #for X in $sync_folder/Preferences/*
  #do
  #  echo create_link "$X" "$HOME/Library/Preferences/$(basename $X)"
  #done
fi
