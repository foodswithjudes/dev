#!/bin/sh

ls /src

DEV_UID=${DEV_UID:-1000}
DEV_GID=${DEV_GID:-1000}
DEV_SHELL=${DEV_SHELL:-/bin/bash}

cat << EOF > docker-compose.override.yml
version: '3.3'
services:
  dev:
    user: $DEV_UID:$DEV_GID
    environment:
      DEV_UID: $DEV_UID
      DEV_GID: $DEV_GID
      DEV_SHELL: $DEV_SHELL
EOF

chown $DEV_UID:$DEVGID docker-compose.override.yml