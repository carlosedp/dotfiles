# Generic shellrc to be used by both zshrc and bashrc

### From zshrc

# Make vim the default editor
export EDITOR="vim"

# Don’t clear the screen after quitting a manual page
export MANPAGER="less -X"

# Highlight section titles in manual pages
export LESS_TERMCAP_md="$ORANGE"

# Load iTerm2 integration
test -e ${HOME}/.dotfiles/shellconfig/iterm2_shell_integration.$(ps -p $$ -oargs= |tr -d "-") && source ${HOME}/.dotfiles/shellconfig/iterm2_shell_integration.$(ps -p $$ -oargs= |tr -d "-")

# Load Golang PATH
source ~/.dotfiles/shellconfig/go.sh

# Load additional PATH
source ~/.dotfiles/shellconfig/path.sh

# Additional functions
source ~/.dotfiles/shellconfig/funcs.sh

# Kubernetes
if [ -x "$(command -v kubectl)" ] > /dev/null 2>&1; then
  source ~/.dotfiles/shellconfig/kubernetes.sh
fi

# Load hub (https://github.com/github/hub)
if [ -x "$(command -v hub)" ]; then
  eval "$(hub alias -s)"
fi

# Load stern completion
if [ -x "$(command -v stern)" ] > /dev/null 2>&1; then
  source <(stern --completion=$(ps -p $$ -oargs= |tr -d "-"))
fi

# Load additional exports
source ~/.dotfiles/shellconfig/exports.sh

# Load generic aliases
source ~/.dotfiles/shellconfig/aliases.sh

# Load Mac aliases
if [ `uname -s` = 'Darwin' ]; then
    source ~/.dotfiles/shellconfig/aliases_mac.sh
fi

# Neofetch
if [ -x "$(command -v neofetch)" ] > /dev/null 2>&1; then
    neofetch --disable packages
fi

if [ "$(tmux list-sessions)" ] > /dev/null 2>&1; then
    echo ""
    echo "There are TMux sessions running:"
    echo ""
    tmux list-sessions
    echo ""
fi
