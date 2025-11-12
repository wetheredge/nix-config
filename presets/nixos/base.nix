{
  config,
  lib,
  pkgs,
  vars,
  ...
}: let
  sshHostKey = "/etc/ssh/ssh_host_ed25519_key";
in {
  nix = {
    settings = {
      trusted-public-keys = [
        "wetheredge.com-0:4JvkPV66FEugl7ay+F0dFqR5SXcMMfSY245ZS2QYBmA="
      ];
      experimental-features = ["nix-command" "flakes"];
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };
  };

  boot = {
    initrd.systemd.enable = true;
    loader.systemd-boot.enable = true;
  };

  console.earlySetup = true;

  security.sudo-rs.enable = true;

  i18n.defaultLocale = "en_US.UTF-8";

  environment.systemPackages = with pkgs; [
    git
    micro
    rsync
  ];
  environment.variables.EDITOR = "micro";

  # Disable default packages
  environment.defaultPackages = [];
  programs.nano.enable = false;

  services.userborn.enable = true;
  users = {
    mutableUsers = false;
    users.${vars.user} = {
      isNormalUser = true;
      extraGroups = ["wheel"];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDcpiTcBohkLUbAt/dnk/FGlViXBwMBQpfx5lLP55HdM wren@eowyn"
      ];
    };
  };

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
    # Use pregenerated keys only
    hostKeys = [];
  };
  # TODO: set programs.ssh.knownHosts from GitHub api?
  preservation.preserveAt.state.files = [
    "${sshHostKey}.pub"
    {
      file = sshHostKey;
      mode = "0600";
    }
  ];

  age.identityPaths = let
    prefix = lib.optionalString config.preservation.enable config.preservation.preserveAt.state.persistentStoragePath;
  in [(prefix + sshHostKey)];

  services.tailscale.enable = true;
  preservation.preserveAt.state.directories = ["/var/lib/tailscale"];
}
