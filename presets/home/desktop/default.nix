{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./atuin.nix
    ./beancount.nix
    ./eww
    ./firefox.nix
    ./fitness.nix
    ./kickoff
    ./media.nix
    ./niri.nix
  ];

  home.packages = with pkgs; [
    just
    nix-tree
    nvd
    ragenix

    brightnessctl
    swayimg
    wev
    wl-clipboard-rs
    xwayland-satellite

    # Chat
    signal-desktop
    dorion
  ];

  xdg.userDirs.enable = true;

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks = {
      "*" = {
        addKeysToAgent = "yes";
        compression = true;
      };
      "knot.wetheredge.com" = {
        hostname = "shelob";
        port = 2222;
      };
    };
  };
  services.ssh-agent.enable = true;

  programs.wezterm = {
    enable = true;
    extraConfig = builtins.readFile ./wezterm.lua;
  };

  preservation.preserveAt = with config.xdg.userDirs; let
    toRelative = lib.removePrefix config.home.homeDirectory;
  in {
    data = {
      directories = [
        (toRelative documents)
        (toRelative pictures)
        "nix/config"
        "nix/secrets"
      ];
    };
    state = {
      directories = [
        ".config/Signal"
        ".config/dorion"
        ".local/share/dorion"
      ];
    };
    cache = {
      directories = [
        ".cache/dorion"
      ];
    };
  };
}
