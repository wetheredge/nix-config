{pkgs, ...}: {
  imports = [
    ./beancount.nix
    ./eww
    ./firefox.nix
    ./kickoff
  ];

  home.packages = with pkgs; [
    just
    nvd

    brightnessctl
    swayimg
    wev
    xwayland-satellite

    # For rbw
    pinentry-curses
  ];

  programs.ssh = {
    enable = true;
    addKeysToAgent = "yes";
    compression = true;
  };
  services.ssh-agent.enable = true;

  xdg.configFile."niri/config.kdl".source = ./niri.kdl;

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
