{pkgs, ...}: {
  home.packages = with pkgs; [
    gcc
    rustup

    cargo-features-manager
  ];

  preservation.preserveAt = {
    state.files = [
      ".rustup/settings.toml"
    ];
    cache.directories = [
      ".cargo/git"
      ".cargo/registry"
      ".rustup"
    ];
  };
}
