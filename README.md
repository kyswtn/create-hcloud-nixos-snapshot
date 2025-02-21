Quickly create a [NixOS](https://nixos.org) snapshot on [Hetzner Cloud](https://www.hetzner.com/cloud) using [Packer](https://www.packer.io).

```sh
create-hcloud-nixos-snapshot \
  --location hel1 \
  --server-type cax11 \
  --ssh-key "$SSH_KEY"
```

If the script succeeds, it'll save generated `hardware-configuration.nix` file in current working directory or directory configured via `--save-config-to`. Once created, the snapshot can be referenced by tools such as [Terraform](http://terraform.io) during provisioning pipeline.

The script is exported at `packages.${system}.default` and can be installed via [Nix flakes](https://wiki.nixos.org/wiki/Flakes). For example,

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    chns = {
      url = "github:kyswtn/create-hcloud-nixos-snapshot";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { self, nixpkgs, chns, ... }:
    let
      system = "aarch64-darwin";
      nixpkgs = nixpkgs.legacyPackages.${system};
      create-hcloud-nixos-snapshot = chns.packages.${system}.default;
    in
    {
      devShells.${system}.default = pkgs.mkShellNoCC {
        packages = [
          create-hcloud-nixos-snapshot
        ];
      };
    };
}
```

Generated snapshot is intentionally as minimal as possible, and only allows [SSH with Public Key Authentication](https://www.ssh.com/academy/ssh/public-key-authentication). Once a machine has been provisioned based off the snapshot, use `nixos-rebuild` with `--target-host` to rebuild with desired new configuration.

This script installs NixOS exactly how the official documentation guides you to. If [nixos-anywhere](https://github.com/nix-community/nixos-anywhere) or [nixos-infect](https://github.com/elitak/nixos-infect) is too overwhelming, this is for you. Until Hetzner [officially provides NixOS standard images](https://www.reddit.com/r/NixOS/comments/1desdbv/could_we_convince_hetzner_to_add_nixos_as_a), this script will be handy. Especially for those who don't want to maintain extra configurations.
