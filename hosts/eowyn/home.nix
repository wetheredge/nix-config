{
  imports = [
    ../../presets/home/dev
    ../../presets/home/desktop
    ../../presets/home/gaming.nix
  ];

  services.ssh-agent.enable = true;

  home.stateVersion = "25.05";
}
