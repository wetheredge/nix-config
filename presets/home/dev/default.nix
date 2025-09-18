{pkgs, ...}: {
  imports = [
    ./vcs.nix
  ];

  home.packages = with pkgs; [
    hyperfine # benchmarking
    scc # count lines of code
  ];

  # language servers
  programs.helix.extraPackages = with pkgs; [
    marksman
  ];

  preservation.preserveAt.data.directories = [
    "Projects"
  ];
}
