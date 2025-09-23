{pkgs, ...}: {
  imports = [
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
    xwayland-satellite

    # For rbw
    pinentry-curses
  ];

  xdg.userDirs.enable = true;

  programs.ssh = {
    enable = true;
    addKeysToAgent = "yes";
    compression = true;
  };
  services.ssh-agent.enable = true;

  # TODO: configure with nix
  programs.rbw.enable = true;

  programs.wezterm = {
    enable = true;
    extraConfig = builtins.readFile ./wezterm.lua;
  };

  preservation.preserveAt = {
    data = {
      directories = [
        "Documents"
        "Pictures"
      ];
      files = [
        ".config/rbw/config.json"
      ];
    };
    state.files = [
      {
        file = ".local/share/rbw/device_id";
        mode = "0600";
      }
    ];
  };
}
