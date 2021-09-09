#!/usr/bin/env bash

# Larger bash history (allow 32³ entries; default is 500)
export HISTSIZE=50000000;
export SAVEHIST=50000000;
export HISTFILESIZE=$HISTSIZE;
export HISTCONTROL=ignoredups;
# Make some commands not show up in history
export HISTIGNORE=" *:ls:cd:cd -:pwd:exit:date:* --help:* -h:pony:pony add *:pony update *:pony save *:pony ls:pony ls *:history*";
export HISTTIMEFORMAT="%d/%m/%y %T "

# Prefer US English and use UTF-8
export LC_CTYPE="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"
export LANG="en_US.UTF-8"

export LESS="-FRX"

# Don’t clear the screen after quitting a manual page
export MANPAGER="less -X";

# Do not clear screen after exiting LESS
unset LESS

# Make vim the default editor
export EDITOR="vim"

# colored GCC warnings and errors
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# Highlight section titles in manual pages
export LESS_TERMCAP_md="$YELLOW"

# Add alt-up/down keybinding to fzf preview window
export FORGIT_FZF_DEFAULT_OPTS="
${FORGIT_FZF_DEFAULT_OPTS:-""}
--bind='alt-up:preview-up'
--bind='alt-down:preview-down'
--no-mouse
"
# Change fzf trigger from "**"
export FZF_COMPLETION_TRIGGER=';'

# Additional PATH exports
export PATH="$HOME/.dotfiles/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="/usr/local/sbin:$PATH"
export PATH="/usr/local/opt/coreutils/libexec/gnubin:$PATH"
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

## Golang path
export GOPATH=$HOME/go
export PATH=/usr/local/go/bin:$GOPATH/bin:$PATH

# Add Erlang shell history and unicode messages
export ERL_AFLAGS="+pc unicode -kernel shell_history enabled"

## Scala Coursier Path for Mac and Linux
export PATH="$HOME/Library/Application Support/Coursier/bin:$PATH"
export PATH="$HOME/.local/share/coursier/bin:$PATH"

# Add Java to path (if coursier is installed)
export JVM=graalvm-ce-java11
JAVA_HOME=/usr/local/java
if [ "$(command -v cs > /dev/null 2>&1)" -eq 0 ] ; then
    if [ "$(cs java-home --jvm ${JVM} > /dev/null 2>&1)" -eq 0 ]; then
        JAVA_HOME=$(cs java-home --jvm ${JVM})
    fi
    export JAVA_HOME
    export PATH=$JAVA_HOME/bin:$PATH
fi

# Ripgrep config
export RIPGREP_CONFIG_PATH=$HOME/.ripgreprc

# GPG
GPG_TTY=$(tty)
export GPG_TTY
