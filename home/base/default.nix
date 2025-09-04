{
  vars,
  pkgs,
  ...
}: {
  imports = [
    ./shells.nix
    ./editor.nix
  ];

  home = {
    username = vars.user;
    homeDirectory = "/home/${vars.user}";
    preferXdgDirectories = true;
  };

  home.packages = with pkgs; [
    btop
    httpie
    jq
    ncdu
    pv
    delta

    qrrs
  ];

  programs.bat = {
    enable = true;
    config.map-syntax = [
      "*.ino:C++"
      # "*.x:Linker Script"
      ".ignore:Git Ignore"
    ];
  };

  programs.eza = {
    enable = true;
    enableFishIntegration = false;
    extraOptions = [
      "--git"
    ];
  };
  programs.fish.shellAliases = {
    ls = "eza";
    ll = "eza --long";
    la = "eza --all";
    lla = "eza --long --all";
  };

  programs.ripgrep = {
    enable = true;
    arguments = [
      "--smart-case"
    ];
  };
}
