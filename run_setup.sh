#!/usr/bin/env bash
# shellcheck disable=SC1091

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

  # Mac OSX
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    # Check if Homebrew is installed
    if ! command -v brew &>/dev/null; then
      echo "Homebrew could not be found. Installing Homebrew..."
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    if ! command -v ansible &>/dev/null; then
      echo "Installing Ansible via Homebrew..."
      brew install ansible git python
    fi
  else
    echo "Unsupported OS"
    exit 1
  fi
fi

# Install Ansible Galaxy requirements
ansible-galaxy install -r requirements.yml

# Call the Ansible playbook to setup the machine
ansible-playbook setup.yml --ask-become-pass
