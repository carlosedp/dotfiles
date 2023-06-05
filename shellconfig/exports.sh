#!/usr/bin/env bash
# shellcheck disable=SC1091

# Load utility functions
source "$HOME/.dotfiles/utils.sh"

# Larger bash history (allow 32³ entries; default is 500)
export HISTSIZE=50000000
export SAVEHIST=50000000
export HISTFILESIZE=$HISTSIZE
export HISTCONTROL=ignoredups
# Make some commands not show up in history
export HISTIGNORE=" *:ls:cd:cd -:pwd:exit:date:* --help:* -h:pony:pony add *:pony update *:pony save *:pony ls:pony ls *:history*"
export HISTTIMEFORMAT="%d/%m/%y %T "

# Prefer US English and use UTF-8
export LC_CTYPE="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"
export LANG="en_US.UTF-8"

export LESS="-FR"

# Don’t clear the screen after quitting a manual page
export MANPAGER="sh -c 'col -bx | bat -l man -p'"

# Do not clear screen after exiting LESS
# unset LESS

# Make vim the default editor
export EDITOR="vim"

# colored GCC warnings and errors
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# Highlight section titles in manual pages
export LESS_TERMCAP_md="$YELLOW"

# Use bat as previewer for FZF
export FZF_DEFAULT_OPTS='--height "75%" --preview "bat --style=numbers --cycle --reverse --color=always --line-range :500 {}"'
export FZF_DEFAULT_COMMAND="rg --files --hidden --follow --glob '!.git'"
export FZF_CTRL_T_OPTS='--preview "bat --color=always --line-range :500 {}"'

# Add alt-up/down keybinding to fzf preview window
export FORGIT_FZF_DEFAULT_OPTS="
${FORGIT_FZF_DEFAULT_OPTS:-""}
--bind='alt-up:preview-up'
--bind='alt-down:preview-down'
--no-mouse
--preview-window='right:75%'
--exact
--border
--cycle
--reverse
--height '90%'
"
export FORGIT_LOG_FZF_OPTS="${FORGIT_FZF_DEFAULT_OPTS:-""} --height 100% --preview-window='up:50%'"

# Change fzf trigger from "**"
export FZF_COMPLETION_TRIGGER=';'

# Additional PATH exports
export PATH="$HOME/.dotfiles/bin:$PATH"
export PATH="$HOME/.dotfiles/bin/scala_scripts/:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="/usr/local/sbin:$PATH"
export PATH="/usr/local/opt/coreutils/libexec/gnubin:$PATH"
for d in /usr/local/opt/gnu-*; do
    export PATH="$d/libexec/gnubin:$PATH"
done
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
export PATH=$HOME/.cargo/bin:$PATH

## Golang path
export GOPATH=$HOME/go
export PATH=/usr/local/go/bin:$GOPATH/bin:$PATH

# Add Erlang shell history and unicode messages
export ERL_AFLAGS="+pc unicode -kernel shell_history enabled -enable-feature all"

# Ripgrep config
export RIPGREP_CONFIG_PATH=$HOME/.ripgreprc

# GPG
GPG_TTY=$(tty)
export GPG_TTY

# Set exa colors (https://the.exa.website/docs/colour-themes)
export EXA_COLORS="uu=1;36"
