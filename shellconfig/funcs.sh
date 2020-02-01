#!/bin/bash

scppath () { echo $USER@`hostname -I | awk '{print $1}'`:`readlink -f $1`; }
jo () { if [[ "$1" != "" ]]; then sudo journalctl -xef -u $1; else sudo journalctl -xef; fi }

