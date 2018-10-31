#!/bin/bash

echo "Setting dotfiles on ~/"
echo `pwd`

# Settings
sync_folder="$HOME/Google\ Drive"
container_settings='com.termius.mac'
application_support_settings='iTerm2 Franz'


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
fi

