{pkgs, ...}: {
  home.packages = with pkgs; [
    steamcmd
    steam-tui
  ];
}
