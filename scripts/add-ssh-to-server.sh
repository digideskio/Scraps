#!/bin/bash
#
# Adds an SSH public key to server by creating dir and adding to file
# $1 = user@server

check_ssh_dir

cat ~/.ssh/id_rsa.pub | ssh $1 'mkdir ~/.ssh/ && touch ~/.ssh/authorized_keys && cat >>~/.ssh/authorized_keys'
