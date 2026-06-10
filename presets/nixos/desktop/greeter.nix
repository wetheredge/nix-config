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
    })
  ];
}
