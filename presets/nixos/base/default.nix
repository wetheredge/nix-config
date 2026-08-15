{vars, ...}: {
  imports = [
    ./ssh.nix
    ./packages.nix
  ];

  nix = {
    settings = {
      trusted-public-keys = [
        "wetheredge.com-0:4JvkPV66FEugl7ay+F0dFqR5SXcMMfSY245ZS2QYBmA="
      ];
      experimental-features = [
        "flakes"
        "nix-command"
      ];
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

  system.etc.overlay.enable = true;

  security.sudo-rs.enable = true;

  i18n.defaultLocale = "en_US.UTF-8";

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

  services.tailscale.enable = true;
  preservation.preserveAt.state.directories = ["/var/lib/tailscale"];
}
