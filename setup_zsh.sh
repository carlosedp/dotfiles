#!/usr/bin/env bash

RED="\e[31m"
REDBOLD="\e[31m\e[1m"
GREEN="\e[32m"
YELLOW="\e[33m"
RESET="\e[0m"

log () {
    if [ $2 ]; then
        echo `printf "$2$1 $RESET"`
    else
        echo `printf "$RESET$1 $RESET"`
    fi
}

# Check pre-reqs
EXIT=0
for C in sudo curl git bash; do
    if [[ ! $(command -v $C) ]]; then
        log "ERROR: The command $C is not installed" $REDBOLD
        EXIT=1
    fi
done
if [ $EXIT == "1" ]; then exit 1; fi

# Load Linux distro info
if [ $(uname -s) != "Darwin" ]; then
    if [ -f /etc/os-release ]; then
        source /etc/os-release
    else
        log "ERROR: I need the file /etc/os-release to determine the Linux distribution..." $REDBOLD
        exit 1
    fi
fi

log "Starting Zsh setup" $GREEN
echo ""
DOTFILES=$HOME/.dotfiles
PATH=/usr/local/go/bin:$HOME/go/bin:"$PATH"

sudo -v

if [ ! "$(command -v zsh)" ] 2> /dev/null 2>&1; then
    log "Zsh not installed, installing..." $GREEN

    if [ $(uname -s) == "Darwin" ]; then
        log "> Checking if Homebrew is installed" $YELLOW
        echo ""
        if [[ $(command -v brew) == "" ]]; then
            log "> Homebrew not installed, installing..." $YELLOW
            /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
            echo ""
        fi
        # Install Zsh on Mac
        brew install zsh
    else
        # Install Zsh on Linux
        if [ $ID == "debian" ] || [ $ID == "ubuntu" ]; then
            sudo apt update
            sudo apt install --no-install-recommends -y zsh
        elif [ $ID == "fedora" ] || [ $ID == "centos" ]; then
            sudo dnf install -y zsh
        elif [ $ID == "alpine" ]; then
            sudo apk add zsh
        elif [ $ID == "void" ]; then
            sudo xbps-install -Su zsh
        else
            log "ERROR: Your distro is not supported, install zsh manually." $REDBOLD
            exit 1
        fi
    fi
fi

log "Change default shell to zsh" $GREEN
if [ $(uname -s) == "Darwin" ]; then
    sudo chsh -s /usr/local/bin/zsh $USER
else
    if [[ $ID == "debian" || $ID == "ubuntu" || $ID == "void" ]]; then
        ZSH=`which zsh`
        sudo chsh $USER -s $ZSH
    elif [ $ID == "fedora" ] || [ $ID == "centos" ]; then
        ZSH=`which zsh`
        sudo usermod --shell $ZSH $(whoami)
    else
        log "Your distro is not supported, change default shell manually." $RED
    fi
fi


echo ""
log "Update dotfiles" $GREEN
if [[ ! -d "$DOTFILES" ]]; then
    git clone --quiet https://github.com/carlosedp/dotfiles.git $DOTFILES
else
    log "> You already have the dotfiles, updating..." $YELLOW
    pushd $DOTFILES; git pull; popd
fi

echo ""
log "Install oh-my-zsh" $GREEN
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    curl -L https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh | sh
else
    log "> You already have the oh-my-zsh, updating..." $YELLOW
    pushd $HOME/.oh-my-zsh; git pull --quiet; popd
fi

echo ""
log "Install fzf plugin" $GREEN
if [[ $(command -v go) != "" ]]; then
    # Install fzf - Command line fuzzy finder
    log "> Installing fzf" $YELLOW
    go get -u github.com/junegunn/fzf
else
    log "> You don't have Go installed, can't install fzf." $RED
fi

if [[ ! -d "$HOME/.fzf" ]]; then
    git clone --quiet https://github.com/junegunn/fzf $HOME/.fzf --depth=1
else
    log "> You already have the fzf config, updating..." $GREEN
    pushd $HOME/.fzf; git pull --quiet --depth=1; popd
fi

if [[ $(command -v fzf) == "" ]]; then
    log "You don't have fzf installed, install thru go_apps.sh script..."$RED
    echo ""
fi

echo ""
log "Add completion scripts" $GREEN
mkdir -p $HOME/.oh-my-zsh/completions
for FILE in $HOME/.dotfiles/completion/*; do
    ln -sfn "$FILE" $HOME/.oh-my-zsh/completions/_$(basename $FILE)
done

# Link .rc files
bash -c $DOTFILES/setup_links.sh

# Zsh plugins
ZSH_CUSTOM=$HOME/.oh-my-zsh/custom

themes=("https://github.com/romkatv/powerlevel10k" \
        )

for t in "${themes[@]}"
    do
    log "Installing $t prompt..." $GREEN
    theme_name=`basename $t`
    if [[ ! -d "$ZSH_CUSTOM/themes/$theme_name" ]]; then
        log "> Installing $theme_name..." $YELLOW
        git clone --quiet $t "$ZSH_CUSTOM/themes/$theme_name"
    else
        log "> You already have $theme_name, updating..." $YELLOW
        pushd $ZSH_CUSTOM/themes/$theme_name; git pull --quiet; popd
    fi
done

# Add plugins to the array below
plugins=("https://github.com/carlosedp/zsh-iterm-touchbar" \
         "https://github.com/TamCore/autoupdate-oh-my-zsh-plugins" \
         "https://github.com/zsh-users/zsh-autosuggestions" \
         "https://github.com/zdharma/fast-syntax-highlighting" \
         "https://github.com/zsh-users/zsh-completions" \
         "https://github.com/zsh-users/zsh-history-substring-search" \
         "https://github.com/MichaelAquilina/zsh-you-should-use" \
         "https://github.com/wfxr/forgit"
        )
plugin_names=()
for p in "${plugins[@]}"
    do
    plugin_name=`basename $p`
    plugin_names+=($plugin_name)
    log "Installing $plugin_name..." $GREEN
    if [[ ! -d "$ZSH_CUSTOM/plugins/$plugin_name" ]]; then
        git clone --quiet $p "$ZSH_CUSTOM/plugins/$plugin_name"
    else
        log "> You already have $plugin_name, updating..." $YELLOW
        pushd $ZSH_CUSTOM/plugins/$plugin_name; git pull --quiet; popd
    fi
done

# Check if array contains element
containsElement () {
  local e match="$1"
  shift
  for e; do [[ "$e" == "$match" ]] && return 0; done
  return 1
}

echo ""
log "Clean unused plugins" $GREEN
pushd "$ZSH_CUSTOM/plugins/"
for d in *; do
    if [ -d "$d" ]; then
        if containsElement $d "${plugin_names[@]}"; then
            log "Keep $d." $YELLOW
        else
            log "Should not have $d, removing." $YELLOW
            rm -rf $d
        fi
    fi
done
popd

echo ""
log "Update kubectx/kubens completion" $GREEN
pushd $DOTFILES/completion
for X in kubectx kubens; do
    curl -sL -o $X.bash https://raw.githubusercontent.com/ahmetb/kubectx/master/completion/$X.bash
    curl -sL -o $X.zsh https://raw.githubusercontent.com/ahmetb/kubectx/master/completion/$X.zsh
    chmod +x $X.bash
    chmod +x $X.zsh
done;
popd

echo ""
log "Clean completion cache" $GREEN
\rm -rf $home/.zcompdump*

echo ""
log "ZSH Setup finished!" $GREEN
echo ""