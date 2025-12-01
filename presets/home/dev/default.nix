{pkgs, ...}: {
  imports = [
    ./vcs.nix
  ];

  home.packages = with pkgs; [
    hyperfine # benchmarking
    lldb # debugger
    scc # count lines of code

    # Rust
    cargo-expand
    cargo-features-manager
  ];

  # language servers
  programs.helix.extraPackages = with pkgs; [
    marksman # markdown
    typescript-language-server
    zls # zig
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
      {
        directory = ".gnupg";
        mode = "0700";
      }
    ];
    state.directories = [
      ".local/share/direnv/allow"
    ];
    cache.directories = [
      ".cache/dprint"
      ".cargo/git"
      ".cargo/registry"
    ];
  };
}
