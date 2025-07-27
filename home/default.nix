{ ... }: {
  imports = [
    ./base
    ./dev
  ];

  home = {
    username = "wren";
    homeDirectory = "/home/wren";
    preferXdgDirectories = true;

    stateVersion = "25.05";
  };
}
