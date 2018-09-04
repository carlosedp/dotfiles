# Path to your oh-my-zsh configuration.
ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
ZSH_THEME="frisk"
#ZSH_THEME="afowler"

# Automatically quote globs in URL and remote references
__remote_commands=(scp rsync)
autoload -U url-quote-magic
zle -N self-insert url-quote-magic
zstyle -e :urlglobber url-other-schema '[[ $__remote_commands[(i)$words[1]] -le ${#__remote_commands} ]] && reply=("*") || reply=(http https ftp)'

# Comment this out to disable weekly auto-update checks
# DISABLE_AUTO_UPDATE="true"

# Uncomment following line if you want to disable autosetting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment following line if you want red dots to be displayed while waiting for completion
# COMPLETION_WAITING_DOTS="true"

# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
plugins=(git osx colored-man colorize pip python brew extract zsh-syntax-highlighting vi-mode)

source $ZSH/oh-my-zsh.sh

# Customize to your needs...

# Combined left and right prompt configuration.
# local smiley="%(?,%{$fg[green]%`}☺%{$reset_color%},%{$fg[red]%}☹%{$reset_color%})"

# Make vim the default editor
export EDITOR="vim"
# Don’t clear the screen after quitting a manual page
export MANPAGER="less -X"
# Highlight section titles in manual pages
export LESS_TERMCAP_md="$ORANGE"

# Something to look for when waiting for auto-completition
COMPLETION_WAITING_DOTS="true"

# PROMPT='
# %{$fg[green]%}%~%{$reset_color%}
# ${smiley}  %{$reset_color%}'

#RPROMPT='%{$fg[white]%}[%{$fg[cyan]%}node-$(node --version)%{$reset_color%} | %{$fg[cyan]%}$(~/.rvm/bin/rvm-prompt)%{$reset_color%}] $(~/dev/tools/git-cwd-info.rb)%{$reset_color%}'
#RPROMPT='%{$fg[white]%}[%{$fg[cyan]%}node-$(node --version)%{$reset_color%} | %{$fg[cyan]%}$(~/dev/tools/erlang_version.sh)%{$reset_color%}] $(~/dev/tools/git-cwd-info.rb)%{$reset_color%}'
# RPROMPT='%{$fg[white]%} $(~/dev/tools/git-cwd-info.rb)%{$reset_color%}'
# zmv
autoload -U zmv

# Add lunchy (launchctl wrapper)
#LUNCHY_DIR=$(dirname `gem which lunchy`)/../extras
#  if [ -f $LUNCHY_DIR/lunchy-completion.zsh ]; then
#    . $LUNCHY_DIR/lunchy-completion.zsh
#  fi

# View HTTP traffic
#alias sniff="sudo ngrep -d 'en1' -t '^(GET|POST) ' 'tcp and port 80'"
alias httpdump="sudo tcpdump -i en1 -n -s 0 -w - | grep -a -o -E \"Host\: .*|GET \/.*\""

sniff()
{
    if [[ $1 == '' ]]; then
        local INTERF="en0"
    else
        local INTERF=$1
    fi
    sudo ngrep -d $INTERF -t '^(GET|POST) ' 'tcp and port 80'
}

alias sniffapp="lsof -i 4tcp"

# Recursively delete `.DS_Store` files
alias cleanup="find . -type f -name '*.DS_Store' -ls -delete"

# Empty the Trash on all mounted volumes and the main HDD
# Also, clear Apple’s System Logs to improve shell startup speed
alias emptytrash="sudo rm -rfv /Volumes/*/.Trashes; sudo rm -rfv ~/.Trash; sudo rm -rfv /private/var/log/asl/*.asl"

alias erl='nocorrect erl'

alias brewupd='brew update; brew upgrade; brew cleanup'

# Node.js library path
export NODE_PATH="/usr/local/lib/node_modules"

# jsctags
export NODE_PATH="/usr/local/lib/jsctags/:$NODE_PATH"

# Set custom PATH
export PATH="$HOME/Dev/tools:/usr/local/sbin:/usr/local/bin:/usr/local/share/npm/bin:$PATH"
export MANPATH="/usr/local/man:$MANPATH"

if [ -f ~/.aliases ]; then
    . ~/.aliases
fi

# Kubernetes
if kubectl > /dev/null 2>&1; then
  source ~/.dotfiles/kubernetes
fi

# Load go PATH
source ~/.dotfiles/go

# Load additional PATH
source ~/.dotfiles/path
