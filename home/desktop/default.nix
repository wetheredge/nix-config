{ pkgs, ... }: {
  imports = [
    ./kickoff
    ./eww
  ];

  home.packages = with pkgs; [
    swayimg

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
