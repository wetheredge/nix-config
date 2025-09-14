{
  pkgs,
  vars,
  ...
}: {
  nix = {
    settings.experimental-features = ["nix-command" "flakes"];
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };

  console.earlySetup = true;
  boot.initrd.systemd.enable = true;

  security.sudo-rs.enable = true;

  i18n.defaultLocale = "en_US.UTF-8";

  environment.systemPackages = with pkgs; [
    git
    micro
    wget
  ];
  environment.variables.EDITOR = "micro";

  services.userborn.enable = true;
  users = {
    mutableUsers = false;
    users.${vars.user} = {
      isNormalUser = true;
      extraGroups = ["wheel"];
      password = "wren";
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB+q0xtKrTMzJLwr1rRNcJJzpP/FL1/ugnNF6WC3rE7M me@wetheredge.com"
      ];
    };
  };

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };
  # TODO: set programs.ssh.knownHosts from GitHub api?

  services.tailscale.enable = true;
  preservation.preserveAt.state.directories = ["/var/lib/tailscale"];

  services.fwupd.enable = true;
}
