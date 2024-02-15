#!/usr/bin/env bash
# shellcheck disable=SC1091

# Check if Ansible is installed and install it if not
if ! command -v ansible &>/dev/null; then
  echo "Ansible could not be found...."
  exit 1
fi

# Call the Ansible playbook to update the system
ansible-playbook setup_apps.yml --ask-become-pass
