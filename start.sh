#!/bin/sh

# if [ ! -d "/fwj" ]
# then
  # git clone https://gitlab.com/foodswithjudes/fwj /fwj
# fi
  mkdir -p /fwj/.git/hooks

/install_git_hooks.py

mkdir -p /fwj
cd /fwj
exec /bin/zsh