{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./atuin.nix
    ./beancount.nix
    ./firefox.nix
    ./fitness.nix
    ./media.nix
    ./ui
  ];

  home.packages = with pkgs; [
    just
    nix-tree
    nvd
    ragenix

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
