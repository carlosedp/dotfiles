#!/usr/bin/env bash

# BASH
## Generate kubectx and kubens completions
for X in kubectx kubens; do
    curl -sL -o $HOME/.dotfiles/completion/$X.bash https://raw.githubusercontent.com/ahmetb/kubectx/master/completion/$X.bash
done

# ZSH
## Generate kubectx and kubens completions
for X in kubectx kubens; do
    curl -sL -o $HOME/.dotfiles/completion/_$X.zsh https://raw.githubusercontent.com/ahmetb/kubectx/master/completion/$X.zsh
done
