{ pkgs, ... }: {
  imports = [
    ./niri.nix
  ];

  # TODO: configure with nix
  programs.rbw.enable = true;
  home.packages = [ pkgs.pinentry-curses ];
}
