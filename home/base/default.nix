{ pkgs, ... }: {
  imports = [
    ./shell.nix
  ];

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
