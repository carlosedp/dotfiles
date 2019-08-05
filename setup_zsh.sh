#!/bin/bash

# Check pre-reqs
if [[ $(command -v git) == "" ]] || [[ $(command -v curl) == "" ]]; then
    echo "Curl or git not installed..."
    exit 1
fi

echo "Starting Zsh setup"
echo ""
DOTFILES=$HOME/.dotfiles

containsElement () {
  local e match="$1"
  shift
  for e; do [[ "$e" == "$match" ]] && return 0; done
  return 1
}

sudo -v

if [ $(uname) == "Darwin" ]; then
    echo "Checking if Homebrew is installed"
    echo ""
    if [[ $(command -v brew) == "" ]]; then
        echo "Homebrew not installed, installing..."
        /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
        echo ""
    fi

     # Install Zsh on Mac
    if [ -x "$(command zsh --version)" ] 2> /dev/null 2>&1; then
        echo "Zsh not installed, installing..."
        brew install zsh
        sudo chsh -s /usr/local/bin/zsh $USER
    fi
else
    # Install Zsh on Linux
    if [ $(cat /etc/os-release | grep -i "ID=debian") ] || [ $(cat /etc/os-release | grep -i "ID=ubuntu") ]; then
        sudo apt update
        sudo apt install -y zsh
        ZSH=`which zsh`
        sudo chsh -s $ZSH $USER
    fi
    if [ $(cat /etc/os-release | grep -i "ID=fedora") ]; then
        sudo dnf install -y zsh
        ZSH=`which zsh`
        sudo usermod --shell $ZSH $USER
    fi
fi

echo "Get dotfiles"
if [[ ! -d "$DOTFILES" ]]; then
    git clone https://github.com/carlosedp/dotfiles.git $DOTFILES
else
    echo "You already have the dotfiles, updating..."
    pushd $DOTFILES; git pull; popd
fi

echo "Install oh-my-zsh"
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    curl -L https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh | sh
else
    echo "You already have the oh-my-zsh, updating..."
    pushd $HOME/.oh-my-zsh; git pull; popd
fi

# Link .rc files
bash -c $DOTFILES/setup_links.sh

# Zsh plugins
ZSH_CUSTOM=$HOME/.oh-my-zsh/custom

themes=("https://github.com/denysdovhan/spaceship-prompt" \
        "https://github.com/romkatv/powerlevel10k" \
        )

for t in "${themes[@]}"
    do
    echo "Installing $t prompt..."
    theme_name=`basename $t`
    if [[ ! -d "$ZSH_CUSTOM/themes/$theme_name" ]]; then
        echo "Installing $theme_name..."
        git clone $t "$ZSH_CUSTOM/themes/$theme_name"
    else
        echo "You already have $theme_name, updating..."
        pushd $ZSH_CUSTOM/themes/$theme_name; git pull; popd
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
        )
plugin_names=()
for p in "${plugins[@]}"
    do
    plugin_name=`basename $p`
    plugin_names+=($plugin_name)
    echo "Installing $plugin_name..."
    if [[ ! -d "$ZSH_CUSTOM/plugins/$plugin_name" ]]; then
        git clone $p "$ZSH_CUSTOM/plugins/$plugin_name"
    else
        echo "You already have $plugin_name, updating..."
        pushd $ZSH_CUSTOM/plugins/$plugin_name; git pull; popd
    fi
done

# Clean unused plugins
pushd "$ZSH_CUSTOM/plugins/"
for d in *; do
    if [ -d "$d" ]; then
        if containsElement $d "${plugin_names[@]}"; then
            echo "Contains $d."
        else
            echo "Does not contain $d, removing."
            rm -rf $d
        fi
    fi
done
popd