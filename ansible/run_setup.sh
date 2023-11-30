#!/usr/bin/env bash

# Install Ansible Galaxy requirements
ansible-galaxy install -r requirements.yml

# Call the Ansible playbook to setup the machine
ansible-playbook setup.yml --ask-become-pass
