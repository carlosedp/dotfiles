#!/bin/bash

echo "Setting dotfiles on ~/"
echo `pwd`

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
      echo "Destination already exists. Renaming to $dest-old"
      mv "$dest" "$dest-old"
  fi
  ln -sf "$origin" "$dest"
}


# Link .rc files
for FILE in `pwd`/rc/*
do
  create_link $FILE ~/.$(basename $FILE)
done

# Link SSH keys
ln -sf "$sync_folder/SSH_Keys" ~/.ssh

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
