#!/bin/env bash
set -euxo pipefail

# Install curl & xz.
export DEBIAN_FRONTEND=noninteractive
apt update
apt install -y curl xz-utils

# Install nix (the package manager).
sh <(curl -L https://nixos.org/nix/install) --daemon --yes
. "/etc/profile.d/nix.sh"

# Switch to stable from default nixpkgs-unstable channel.
nix-channel --add https://nixos.org/channels/nixos-24.11 nixpkgs
nix-channel --update

# For nixos-generate-config and nixos-install.
nix-env -f '<nixpkgs>' -iA nixos-install-tools parted

# Partition, format, and mount.
parted -s /dev/sda -- mklabel gpt
parted -s /dev/sda -- mkpart root ext4 512MB -8GB
parted -s /dev/sda -- mkpart swap linux-swap -8GB 100%
parted -s /dev/sda -- mkpart ESP fat32 1MB 512MB
parted -s /dev/sda -- set 3 esp on

mkfs.ext4 -L nixos /dev/sda1
mkswap -L swap /dev/sda2
mkfs.fat -F 32 -n boot /dev/sda3
mount /dev/disk/by-label/nixos /mnt
mkdir -p /mnt/boot
mount -o umask=077 /dev/disk/by-label/boot /mnt/boot
swapon /dev/sda2

# Generate hardware-configuration.nix.
nixos-generate-config --root /mnt
