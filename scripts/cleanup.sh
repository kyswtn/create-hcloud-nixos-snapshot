#!/bin/env bash
set -euxo pipefail
. "/etc/profile.d/nix.sh"

# Clean apt files, because initial OS is debian.
export DEBIAN_FRONTEND=noninteractive
apt-get -y autopurge
apt-get -y clean
rm -rf /var/lib/apt/lists/*

# Clean logs.
journalctl --flush
journalctl --rotate --vacuum-time=0
rm -rf /var/log/*

# Clean nix.
rm -rf /tmp/*
nix-collect-garbage -d
nix-channel --update # Nix's broken without this.

# Discard unused blocks.
dd if=/dev/zero of=/zero bs=4M || true
sync
rm -rf /zero
