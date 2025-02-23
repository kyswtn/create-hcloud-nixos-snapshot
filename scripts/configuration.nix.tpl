{ config, lib, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "${host_name}";
  networking.networkmanager.enable = true;
  i18n.defaultLocale = "en_US.UTF-8";

  nix = {
    settings = {
      auto-optimise-store = true;
      experimental-features = [ "nix-command" "flakes" ];
      keep-outputs = true;
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 1w";
    };
  };

  users.users.root = {
    extraGroups = [ ];
    openssh.authorizedKeys.keys = [ 
%{ for ssh_key in ssh_keys ~}
"${ssh_key}"
%{ endfor ~}
    ];
  };

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "prohibit-password";
    };
  };
  services.fail2ban.enable = true;
  services.tailscale.enable = true;

  system.stateVersion = "24.11";
}
