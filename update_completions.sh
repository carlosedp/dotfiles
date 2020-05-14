#!/usr/bin/env bash

# BASH
## Generate/Update Kubectl completion scripts
if [[ $(command -v kubectl) ]]; then
        kubectl completion bash > $HOME/.dotfiles/completion/kubectl.bash
fi
## Generate stern (Kubernetes log utility) completions
if [[ $(command -v stern) ]]; then
        stern --completion=bash >> $HOME/.dotfiles/completion/stern.bash
fi
## Generate kubectx and kubens completions
for X in kubectx kubens; do
    curl -sL -o $HOME/.dotfiles/completion/$X.bash https://raw.githubusercontent.com/ahmetb/kubectx/master/completion/$X.bash
done

# ZSH
## Generate/Update Kubectl completion scripts
if [[ $(command -v kubectl) ]]; then
        kubectl completion zsh > $HOME/.dotfiles/completion/_kubectl
fi
## Generate stern (Kubernetes log utility) completions
if [[ $(command -v stern) ]]; then
        echo "#compdef stern kl=stern" > $HOME/.dotfiles/completion/_stern
        stern --completion=zsh >> $HOME/.dotfiles/completion/_stern
fi
## Generate kubectx and kubens completions
for X in kubectx kubens; do
    curl -sL -o $HOME/.dotfiles/completion/_$X.zsh https://raw.githubusercontent.com/ahmetb/kubectx/master/completion/$X.zsh
done
