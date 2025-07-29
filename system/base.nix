{ pkgs, vars, ... }: {
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  console.earlySetup = true;

  i18n.defaultLocale = "en_US.UTF-8";

  environment.systemPackages = with pkgs; [
    git
    helix
    wget
  ];
  environment.variables.EDITOR = "hx";

  services.userborn.enable = true;
  users.users.${vars.user} = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    password = "wren";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB+q0xtKrTMzJLwr1rRNcJJzpP/FL1/ugnNF6WC3rE7M me@wetheredge.com"
    ];
  };

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };
}
