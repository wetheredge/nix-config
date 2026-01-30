{modulesPath, ...}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")

    ../../presets/nixos/vps.nix

    ./disks.nix

    ./services
  ];

  services.wren.caddy.enable = true;

  preservation.enable = true;
  settings.demolition = {
    enable = true;
    device = "/dev/disk/by-partlabel/disk-main-root";
  };

  system.stateVersion = "25.05";
}
