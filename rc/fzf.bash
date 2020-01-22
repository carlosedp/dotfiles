# Setup fzf
# ---------
if [ ! -x "$(command -v fzf)" ] > /dev/null 2>&1; then
    echo "Error: fzf binary not installed. Use go_apps.sh script to install."
    return
fi

if [[ ! -d "$HOME/.fzf" ]]; then
    echo "Error: .fzf directory not installed. Use setup_zsh.sh script to install."
    return
fi

# Auto-completion
# ---------------
[[ $- == *i* ]] && source "$HOME/.fzf/shell/completion.bash" 2> /dev/null

# Key bindings
# ------------
source "$HOME/.fzf/shell/key-bindings.bash"
