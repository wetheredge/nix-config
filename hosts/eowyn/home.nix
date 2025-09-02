{ ... }: {
  imports = [
    ../../home/dev
    ../../home/desktop
  ];

  services.ssh-agent.enable = true;

  home.stateVersion = "25.05";
}
