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

  xdg.configFile."niri/config.kdl".source = ./niri.kdl;

  # TODO: configure with nix
  programs.rbw.enable = true;

  programs.wezterm = {
    enable = true;
    extraConfig = builtins.readFile ./wezterm.lua;
  };
}
