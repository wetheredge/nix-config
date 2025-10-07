{pkgs, ...}: {
  imports = [
    ./vcs.nix
  ];

  home.packages = with pkgs; [
    rustup

    hyperfine # benchmarking
    scc # count lines of code
  ];

  # language servers
  programs.helix.extraPackages = with pkgs; [
    marksman
  ];

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  services.podman.enable = true;

  preservation.preserveAt = {
    data.directories = [
      "Projects"
      "Work"
    ];
    state.directories = [
      ".local/share/direnv/allow"
    ];
    cache.directories = [
      ".cargo/registry"
      ".rustup/toolchains"
      ".rustup/update-hashes"
    ];
  };
}
