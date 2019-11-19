#!/bin/sh

set -e

# Setup user defaults.
USER_UID=${FWJ_DEV_USER_UID:-1000}
USER_GID=${FWJ_DEV_USER_GID:-$USER_UID}
USER_SHELL=${FWJ_DEV_USER_SHELL:-/bin/bash}

# Fix group of the docker daemon socket
chgrp dev /var/run/docker.sock

usermod --shell "$USER_SHELL" dev

if ! [ $(id -u dev) = $USER_UID ] || ! [ $(id -g dev) = $USER_GID ]; then
  groupmod --gid "$USER_GID" dev
  usermod --uid "$USER_UID" -g dev dev
  chown -R dev:dev /home/dev /go
fi

# Clone the repository if it wasn't mounted into /fwj
# if [ ! -d "/fwj" ]
# then
#   echo "/fwj is empty - cloning repository..."
#   git clone https://github.com/katcheCode/fwj.git /fwj
# fi

# Kick off final shell as the user.
cd /fwj
exec sudo -E --preserve-env=PATH -u dev "$USER_SHELL"

