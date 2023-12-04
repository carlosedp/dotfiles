#!/usr/bin/env bash
# shellcheck disable=SC1091
set -euo pipefail

# Bootstrap script to setup any Linux or Mac with Ansible

# Check if Ansible is installed and install it if not
if ! command -v ansible &>/dev/null; then
  echo "Ansible could not be found. Installing Ansible..."
  if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Load Linux distro info
    if [ -f /etc/os-release ]; then
      source /etc/os-release
    else
      echo "ERROR: I need the file /etc/os-release to determine the Linux distribution..."
      exit 1
    fi
    echo "Installing Ansible via package manager..."
    if [ "$ID" == "debian" ] || [ "$ID" == "ubuntu" ]; then
      sudo apt update
      sudo apt install --no-install-recommends -y git ansible python3-pip python3
    elif [ "$ID" == "fedora" ] || [ "$ID" == "centos" ] || [ "$ID" == "rhel" ]; then
      sudo dnf install -y git ansible python3-pip python3
    elif [ "$ID" == "alpine" ]; then
      sudo apk add git ansible py3-pip python3
    elif [ "$ID" == "void" ]; then
      sudo xbps-install -Su -y git ansible python3-pip python3
    else
      echo "Your distro is not supported, install git manually."
      exit 1
    fi

  elif [[ "$OSTYPE" == "darwin"* ]]; then
    # Mac OSX
    echo "Install homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    echo "Installing Ansible via Homebrew..."
    brew install ansible git python
  else
    echo "Unsupported OS"
    exit 1
  fi
fi

# Clone dotfiles into $HOME
echo "Cloning dotfiles..."
repo=https://github.com/carlosedp/dotfiles.git
dest="$HOME/.dotfiles"

if [[ ! -d "$dest" ]]; then
  log "> Cloning $repo... into $dest" "$GREEN"
  git clone --quiet "$repo" "$dest" "$@"
else
  # Check if the repo is the same as the one we want to clone
  if [[ $(git -C "$dest" config --get remote.origin.url) != *"$repo"* ]]; then
    log "> $dest is not the same repo as $repo, skipping..." "$RED"
    return
  fi
  log "> You already have $repo, updating..." "$GREEN"
  pushd "$dest" >/dev/null || return
  if [[ -n $(git status --porcelain) ]]; then
    log "> Your dir $dest has changes" "$MAGENTA"
  fi
  git pull --rebase --autostash --quiet "$@"
  popd >/dev/null || return
fi

# Run setup playbook
echo "Running setup playbook..."

# Install Ansible Galaxy requirements
ansible-galaxy install -r "$HOME/.dotfiles/requirements.yml"

# Call the Ansible playbook to setup the machine
ansible-playbook "$HOME/.dotfiles/setup.yml" --ask-become-pass
