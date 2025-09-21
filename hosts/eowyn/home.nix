{
  imports = [
    ../../presets/home/dev
    ../../presets/home/desktop
    ../../presets/home/gaming.nix
  ];

  programs.niri.settings.outputs."eDP-1".scale = 2;

  home.stateVersion = "25.05";
}
