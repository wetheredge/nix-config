{pkgs, ...}: let
  flavor = "mocha";
  accent = "mauve";
in {
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    theme = "catppuccin-${flavor}-${accent}";
  };

  environment.systemPackages = [
    (pkgs.catppuccin-sddm.override {
      inherit flavor accent;
      fontSize = "24";
    })
  ];

  preservation.preserveAt.cache.directories = [
    "/var/lib/sddm"
  ];
}
