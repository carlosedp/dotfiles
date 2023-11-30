#!/usr/bin/env bash

# Get command line arguments

# Get the IP address of the host to be configured
IP_ADDRESS=$1

# Get the username of the host to be configured
USERNAME=$2

# Show help if no arguments are provided
if [ -z "$IP_ADDRESS" ] || [ -z "$USERNAME" ]; then
  echo "Usage: $0 <ip_address> <username>"
  exit 1
fi

REMAINING_ARGS="${@:3}"

ansible-playbook setup.yml --ask-pass --ask-become-pass -u "$USERNAME" -i "$IP_ADDRESS," $REMAINING_ARGS
