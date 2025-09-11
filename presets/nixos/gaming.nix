{pkgs, ...}: {
  programs.steam = {
    enable = true;
    package = pkgs.steam.override {
      # Fix black screen when running under xwayland-satellite
      extraArgs = "-system-composer";
    };
  };
}
