{ pkgs, ... }: {
  imports = [
    ./vcs.nix
  ];

  # language servers
  programs.helix.extraPackages = with pkgs; [
    marksman
  ];
}
