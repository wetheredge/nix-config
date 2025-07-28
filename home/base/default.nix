{ vars, pkgs, ... }: {
  imports = [
    ./shell.nix
  ];

  home = {
    username = vars.user;
    homeDirectory = "/home/${vars.user}";
    preferXdgDirectories = true;
  };

  home.packages = with pkgs; [
    bat
    ripgrep
    btop
  ];

  programs.eza = {
    enable = true;
    git = true;
  };
}
