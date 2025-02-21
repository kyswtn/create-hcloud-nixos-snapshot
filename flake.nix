{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = { self, nixpkgs, ... }:
    let
      mkInputs = system: {
        inherit system;
        pkgs = import nixpkgs {
          inherit system;
          config = { allowUnfree = true; };
        };
      };
      forAllSupportedSystems = fn:
        with nixpkgs.lib; attrsets.genAttrs systems.flakeExposed
          (system: fn (mkInputs system));
    in
    {
      devShells = forAllSupportedSystems (inputs: with inputs; {
        default = pkgs.mkShellNoCC {
          packages = with pkgs; [
            hcloud
            packer

            self.packages.${system}.default
          ];
        };
      });

      packages = forAllSupportedSystems (inputs: with inputs; {
        default = pkgs.writeShellApplication {
          name = "create-hcloud-nixos-snapshot";
          runtimeInputs = with pkgs; [ getopt jq packer ];
          text = /* sh */ ''
            PATH_ROOT=${./scripts}
            ${builtins.readFile ./scripts/create-hcloud-nixos-snapshot.sh}
          '';
        };
      });
    };
}
