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
      sudo apt install --no-install-recommends -y git ansible
    elif [ "$ID" == "fedora" ] || [ "$ID" == "centos" ] || [ "$ID" == "rhel" ]; then
      sudo dnf install -y git ansible
    elif [ "$ID" == "alpine" ]; then
      sudo apk add git ansible
    elif [ "$ID" == "void" ]; then
      sudo xbps-install -Su -y git ansible
    else
      echo "Your distro is not supported, install git manually."
      exit 1
    fi

  elif [[ "$OSTYPE" == "darwin"* ]]; then
    # Mac OSX
    echo "Install homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    echo "Installing Ansible via Homebrew..."
    brew install ansible
  else
    echo "Unsupported OS"
    exit 1
  fi
fi
