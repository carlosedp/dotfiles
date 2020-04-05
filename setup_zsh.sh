#!/bin/bash

# Check pre-reqs
if [[ $(command -v git) == "" ]] || [[ $(command -v curl) == "" ]]; then
    echo "Curl or git not installed..."
    exit 1
fi

echo "Starting Zsh setup"
echo ""
DOTFILES=$HOME/.dotfiles

sudo -v

if [ -x "$(command zsh --version)" ] 2> /dev/null 2>&1; then
    echo "Zsh not installed, installing..."

    if [ $(uname) == "Darwin" ]; then
        echo "Checking if Homebrew is installed"
        echo ""
        if [[ $(command -v brew) == "" ]]; then
            echo "Homebrew not installed, installing..."
            /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
            echo ""
        fi
        # Install Zsh on Mac
        brew install zsh
    else
        # Install Zsh on Linux
        if [ $(cat /etc/os-release | grep -i "ID=debian") ] || [ $(cat /etc/os-release | grep -i "ID=ubuntu") ]; then
            sudo apt update
            sudo apt install -y zsh
        fi
        if [ $(cat /etc/os-release | grep -i "ID=fedora") ]; then
            sudo dnf install -y zsh
        fi
    fi
fi

echo "Change default shell to zsh"
if [ $(uname) == "Darwin" ]; then
    sudo chsh -s /usr/local/bin/zsh $USER
else
    if [ $(cat /etc/os-release | grep -i "ID=debian") ] || [ $(cat /etc/os-release | grep -i "ID=ubuntu") ] || [ $(cat /etc/os-release | grep -i "ID=alpine"); then
        ZSH=`which zsh`
        sudo chsh $USER -s $ZSH
    fi
    if [ $(cat /etc/os-release | grep -i "ID=fedora") ]; then
        ZSH=`which zsh`
        sudo usermod --shell $ZSH $USER
    fi
fi


echo ""
echo "Update dotfiles"
if [[ ! -d "$DOTFILES" ]]; then
    git clone https://github.com/carlosedp/dotfiles.git $DOTFILES
else
    echo "You already have the dotfiles, updating..."
    pushd $DOTFILES; git pull; popd
fi

echo ""
echo "Install oh-my-zsh"
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    curl -L https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh | sh
else
    echo "You already have the oh-my-zsh, updating..."
    pushd $HOME/.oh-my-zsh; git pull; popd
fi

echo ""
echo "Install fzf plugin"
if [[ $(command -v go) != "" ]]; then
    # Install fzf - Command line fuzzy finder
    echo "Installing fzf"
    go get -u github.com/junegunn/fzf
else
    echo "You don't have Go installed, can't install fzf."
fi

if [[ ! -d "$HOME/.fzf" ]]; then
    git clone https://github.com/junegunn/fzf $HOME/.fzf --depth=1
else
    echo "You already have the fzf config, updating..."
    pushd $HOME/.fzf; git pull --depth=1; popd
fi

if [[ $(command -v fzf) == "" ]]; then
    echo "You don't have fzf installed, install thru go_apps.sh script..."
    echo ""
fi

echo ""
echo "Add completion scripts"
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
         "https://github.com/wfxr/forgit"
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

# Check if array contains element
containsElement () {
  local e match="$1"
  shift
  for e; do [[ "$e" == "$match" ]] && return 0; done
  return 1
}

echo ""
echo "Clean unused plugins"
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

echo ""
echo "Update kubectx/kubens plugins"
pushd $DOTFILES/bin
for X in kubectx kubens; do
    curl -sL -o $X https://raw.githubusercontent.com/ahmetb/kubectx/master/$X
    chmod +x $X
    pushd $DOTFILES/completion
    curl -sL -o $X.bash https://raw.githubusercontent.com/ahmetb/kubectx/master/completion/$X.bash
    curl -sL -o $X.zsh https://raw.githubusercontent.com/ahmetb/kubectx/master/completion/$X.zsh
    chmod +x $X.bash
    chmod +x $X.zsh
    popd
done;
popd

echo ""
echo "Clean completion cache"
\rm -rf $home/.zcompdump*

