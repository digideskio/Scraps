#!/bin/bash
#
# Useful for pushing to different git accounts / repos on the same domain via 
# different SSH keys for each repo
# $1 = domain
# $2 = repo

ssh -i /home/user/.ssh/id_rsa_custom $1 $2

