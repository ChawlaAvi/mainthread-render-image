#!/bin/bash
# Runs when the machine starts: lets the key in PUBLIC_KEY log in as root over SSH, then serves SSH until the machine is deleted.
mkdir -p ~/.ssh /run/sshd
if [ -n "$PUBLIC_KEY" ]; then echo "$PUBLIC_KEY" >> ~/.ssh/authorized_keys; fi
chmod 700 ~/.ssh
touch ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
ssh-keygen -A
exec /usr/sbin/sshd -D -e
