#!/usr/bin/env bash
set -euo pipefail

# Load utility functions
source "$HOME/.dotfiles/utils.sh"

log "Starting ZSH setup" "$GREENUNDER"
echo ""

# Check pre-reqs
EXIT=0
for C in sudo curl git bash; do
    if [[ ! $(command -v $C) ]]; then
        log "ERROR: The command $C is not installed" "$REDBOLD"
        EXIT=1
    fi
done
if [ $EXIT == "1" ]; then exit 1; fi

# Load Linux distro info
if [ "$(uname -s)" != "Darwin" ]; then
    if [ -f /etc/os-release ]; then
        source /etc/os-release
    else
        log "ERROR: I need the file /etc/os-release to determine the Linux distribution..." "$REDBOLD"
        exit 1
    fi
fi

DOTFILES="$HOME/.dotfiles"
PATH=/usr/local/go/bin:"$HOME"/go/bin:"$PATH"

sudo -v

if [ ! "$(command -v zsh)" ] 2> /dev/null 2>&1; then
    log "Zsh not installed, installing..." "$GREEN"

    if [ "$(uname -s)" == "Darwin" ]; then
        log "> Checking if Homebrew is installed" "$YELLOW"
        echo ""
        if [[ $(command -v brew) == "" ]]; then
            log "> Homebrew not installed, installing..." "$YELLOW"
            /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
            echo ""
        fi
        # Install Zsh on Mac
        brew install zsh
    else
        # Install Zsh on Linux
        if [ "$ID" == "debian" ] || [ "$ID" == "ubuntu" ]; then
            sudo apt update
            sudo apt install --no-install-recommends -y zsh
        elif [ "$ID" == "fedora" ] || [ "$ID" == "centos" ] || [ "$ID" == "rhel" ]; then
            sudo dnf install -y zsh
        elif [ "$ID" == "alpine" ]; then
            sudo apk add zsh
        elif [ "$ID" == "void" ]; then
            sudo xbps-install -Su zsh
        else
            log "ERROR: Your distro is not supported, install zsh manually." "$REDBOLD"
            exit 1
        fi
    fi
fi

log "Change default shell to zsh" "$GREEN"
if [ "$(uname -s)" == "Darwin" ]; then
    sudo chsh -s /usr/local/bin/zsh "$USER"
else
    if [[ "$ID" == "debian" || "$ID" == "ubuntu" || "$ID" == "void" ]]; then
        ZSH=$(which zsh)
        sudo chsh "$USER" -s "$ZSH"
    elif [ "$ID" == "fedora" ] || [ "$ID" == "centos" ] || [ "$ID" == "rhel" ]; then
        ZSH=$(which zsh)
        sudo usermod --shell "$ZSH" "$(whoami)"
    else
        log "Your distro is not supported, change default shell manually." "$RED"
    fi
fi


echo ""
log "Update dotfiles" "$GREEN"
cloneorpull https://github.com/carlosedp/dotfiles.git "$DOTFILES"

echo ""
log "Install oh-my-zsh" "$GREEN"
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    curl -L https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh | sh
else
    log "> You already have the oh-my-zsh, updating..." "$YELLOW"
    pushd "$HOME"/.oh-my-zsh >/dev/null
    git pull --quiet
    popd >/dev/null
fi

echo ""
log "Install fzf plugin" "$GREEN"
if [[ $(command -v go) != "" ]]; then
    # Install fzf - Command line fuzzy finder
    log "> Installing fzf" "$YELLOW"
    go install github.com/junegunn/fzf@latest
else
    log "> You don't have Go installed, can't install fzf." "$RED"
fi

cloneorpull https://github.com/junegunn/fzf "$HOME"/.fzf --depth=1

if [[ $(command -v fzf) == "" ]]; then
    log "You don't have fzf installed, install thru setup_apps.sh script..." "$RED"
    echo ""
fi

log "Create dotfiles links" "$GREEN"
# Link .rc files
bash -c "$DOTFILES/setup_links.sh"

# Zsh plugins
ZSH_CUSTOM=$HOME/.oh-my-zsh/custom

themes=("https://github.com/romkatv/powerlevel10k" \
        )

for t in "${themes[@]}"
    do
    log "Installing $t prompt..." "$GREEN"
    theme_name=$(basename "$t")

    cloneorpull "$t" "$ZSH_CUSTOM/themes/$theme_name"
done

# Add plugins to the array below
plugins=("https://github.com/carlosedp/zsh-iterm-touchbar" \
         "https://github.com/TamCore/autoupdate-oh-my-zsh-plugins" \
         "https://github.com/zsh-users/zsh-autosuggestions" \
         "https://github.com/zdharma/fast-syntax-highlighting" \
         "https://github.com/zsh-users/zsh-completions" \
         "https://github.com/zsh-users/zsh-history-substring-search" \
         "https://github.com/MichaelAquilina/zsh-you-should-use" \
         "https://github.com/Aloxaf/fzf-tab" \
         "https://github.com/wfxr/forgit"
        )
plugin_names=()
for p in "${plugins[@]}"
    do
    plugin_name=$(basename "$p")
    plugin_names+=("$plugin_name")
    log "Installing $plugin_name..." "$GREEN"
    cloneorpull "$p" "$ZSH_CUSTOM/plugins/$plugin_name"
done

echo ""
log "Clean unused plugins" "$GREEN"
pushd "$ZSH_CUSTOM/plugins/" >/dev/null
plugin_names+=("example")
for d in *; do
    if [ -d "$d" ]; then
        if containsElement "$d" "${plugin_names[@]}"; then
            log "Keep $d." "$YELLOW"
        else
            log "Should not have $d, removing." "$YELLOW"
            rm -rf "$d"
        fi
    fi
done
popd >/dev/null

echo ""
log "Clean completion cache" "$GREEN"
\rm -rf "$HOME"/.zcompdump*

echo ""
log "ZSH Setup finished!" "$GREENUNDER"
echo ""