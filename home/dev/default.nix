{ pkgs, ... }: {
  imports = [
    ./vcs.nix
  ];

  # language servers
  home.packages = with pkgs; [
    nixd
  ];
}
