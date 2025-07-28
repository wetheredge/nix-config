{ vars, ... }: {
  imports = [
    ./base
    ./dev
  ];

  home = {
    username = vars.user;
    homeDirectory = "/home/${vars.user}";
    preferXdgDirectories = true;

    stateVersion = "25.05";
  };
}
