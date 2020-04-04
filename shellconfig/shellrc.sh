###
# Generic shellrc to be used by both zshrc and bashrc
###

# NOTE: problems might occur if /bin/sh is symlinked to /bin/bash
if [ -n "${BASH}" ]; then
    shell="bash"
elif [ -n "${ZSH_NAME}" ]; then
    shell="zsh"
fi

# Load exports
source ~/.dotfiles/shellconfig/exports.sh

# Functions
source ~/.dotfiles/shellconfig/funcs.sh

# Load generic aliases
source ~/.dotfiles/shellconfig/aliases.sh

# Load Mac aliases
if [ `uname -s` = 'Darwin' ]; then
    source ~/.dotfiles/shellconfig/aliases_mac.sh
fi

#####
# Now load plugins and utilities
#####

# Enable autojump
[ -f /usr/local/etc/profile.d/autojump.sh ] && source /usr/local/etc/profile.d/autojump.sh # Mac
[ -f /usr/share/autojump/autojump.sh ] && source /usr/share/autojump/autojump.sh # Linux

# Wasmer
export WASMER_DIR="$HOME/.wasmer"
[ -s "$WASMER_DIR/wasmer.sh" ] && source "$WASMER_DIR/wasmer.sh"  # This loads wasmer

# Use gitstatusd built locally if exists
# To build, run `zsh -c "$(curl -fsSL https://raw.githubusercontent.com/romkatv/gitstatus/master/build.zsh)"`
if command -v $HOME/.dotfiles/bin/gitstatusd-linux-`uname -m` &> /dev/null; then
    GITSTATUS_DAEMON=$HOME/.dotfiles/bin/gitstatusd-linux-`uname -m`
fi

# Load fzf plugin. Installed thru setup_zsh.sh
[ -f ~/.fzf.${shell} ] && source ~/.fzf.${shell}

# Kubernetes
if [ -x "$(command -v kubectl)" ] > /dev/null 2>&1; then
  source ~/.dotfiles/shellconfig/kubernetes.sh
fi

# Load hub (https://github.com/github/hub)
if [ -x "$(command -v hub)" ]; then
  eval "$(hub alias -s)"
fi

# Load stern log tool completion
if [ -x "$(command -v stern)" ] > /dev/null 2>&1; then
  source <(stern --completion=$(ps -p $$ -oargs= |tr -d "-"))
fi

# Load iTerm2 integration
[ -f ${HOME}/.dotfiles/shellconfig/iterm2_shell_integration.${shell} ] && source ${HOME}/.dotfiles/shellconfig/iterm2_shell_integration.${shell}

#####
# These are at the end to print on user login
#####

# Neofetch
if [ -x "$(command -v neofetch)" ] > /dev/null 2>&1; then
    neofetch --disable packages
fi

if tmux list-sessions > /dev/null 2>&1; then
    echo ""
    echo "There are TMux sessions running:"
    echo ""
    tmux list-sessions
    echo ""
fi
