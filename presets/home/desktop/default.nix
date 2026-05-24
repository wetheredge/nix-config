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
    ./fonts.nix
    ./kickoff
    ./media.nix
    ./theme.nix
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
  ];

  xdg.userDirs.enable = true;

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings = {
      "*" = {
        AddKeysToAgent = "yes";
        Compression = true;
      };
      "knot.wetheredge.com" = {
        HostName = "shelob";
        Port = 2222;
      };
    };
  };
  services.ssh-agent.enable = true;

  xdg.configFile."niri/config.kdl".text = builtins.readFile ./niri.kdl;

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
      ];
    };
  };
}
