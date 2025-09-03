{ pkgs, ... }: {
  home.packages = with pkgs; [
    swayimg
  ];

  programs = {
    alacritty.enable = true;
  };

  programs.wezterm = {
    enable = true;
    extraConfig = builtins.readFile ./wezterm.lua;
  };
}
