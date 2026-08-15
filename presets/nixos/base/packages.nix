{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    git
    micro
    rsync
  ];
  environment.variables.EDITOR = "micro";

  environment.defaultPackages = [];
  programs.nano.enable = false;
  fonts.enableDefaultPackages = false;
  system.tools = {
    nixos-generate-config.enable = false;
    nixos-install.enable = false;
    nixos-option.enable = false;
  };
}
