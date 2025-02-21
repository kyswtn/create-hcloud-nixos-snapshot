#!/bin/env bash
set -euxo pipefail
. "/etc/profile.d/nix.sh"

nixos-install --no-root-passwd --root /mnt
