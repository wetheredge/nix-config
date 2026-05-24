{
  imports = [
    ../../presets/home/dev
    ../../presets/home/desktop
    ../../presets/home/gaming.nix
  ];

  xdg.configFile."niri/host.kdl".text = ''
    output "eDP-1" {
    	scale 2
    }
  '';

  home.stateVersion = "25.05";
}
