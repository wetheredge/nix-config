{modulesPath, ...}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")

    ../../presets/nixos/vps.nix

    ./disks.nix

    ./server.nix
    ./pds.nix
  ];

  preservation.enable = true;
  settings.rollback = {
    enable = true;
    device = "/dev/disk/by-partlabel/disk-main-root";
  };

  system.stateVersion = "25.05";
}
