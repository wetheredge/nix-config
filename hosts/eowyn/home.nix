{
  imports = [
    ../../home/dev
    ../../home/desktop
    ../../home/gaming.nix
  ];

  services.ssh-agent.enable = true;

  home.stateVersion = "25.05";
}
