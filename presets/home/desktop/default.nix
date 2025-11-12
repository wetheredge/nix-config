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
    ./kickoff
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

    # For rbw
    pinentry-curses
  ];

  xdg.userDirs.enable = true;

  programs.ssh = {
    enable = true;
    addKeysToAgent = "yes";
    compression = true;
    matchBlocks."knot.wetheredge.com" = {
      hostname = "shelob";
      port = 2222;
    };
  };
  services.ssh-agent.enable = true;

  # TODO: configure with nix
  programs.rbw.enable = true;

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
      files = [
        ".config/rbw/config.json"
      ];
    };
    state = {
      directories = [
        ".config/Signal"
        ".config/dorion"
        ".local/share/dorion"
      ];
      files = [
        {
          file = ".local/share/rbw/device_id";
          mode = "0600";
        }
      ];
    };
    cache = {
      directories = [
        ".cache/dorion"
      ];
    };
  };
}
