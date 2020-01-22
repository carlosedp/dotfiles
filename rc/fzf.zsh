# Setup fzf
# ---------
if [ ! -x "$(command -v fzf)" ] > /dev/null 2>&1; then
    echo "Error: fzf binary not installed"
    return
fi

if [[ ! -d "$HOME/.fzf" ]]; then
    echo "Error: .fzf directory not installed"
    return
fi

# Auto-completion
# ---------------
[[ $- == *i* ]] && source "$HOME/.fzf/shell/completion.zsh" 2> /dev/null

# Key bindings
# ------------
source "$HOME/.fzf/shell/key-bindings.zsh"
