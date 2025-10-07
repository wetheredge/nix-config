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

  # Git tag signing
  services.gpg-agent.enable = true;
  programs.gpg = {
    enable = true;
    settings = {
      pinentry-mode = "loopback";
      default-new-key-algo = "ed25519/cert";
      auto-key-retrieve = true;
      keyserver-options = "honor-keyserver-url";
    };
  };

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
