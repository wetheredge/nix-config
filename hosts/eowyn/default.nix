{
  pkgs,
  nixos-hardware,
  ...
}: {
  imports = [
    nixos-hardware.nixosModules.dell-xps-13-9300

    ./disks.nix
    ./hardware-configuration.nix

    ../../presets/nixos/desktop
    ../../presets/nixos/gaming.nix
  ];

  environment.machine-info.prettyHostname = "Éowyn";

  boot.loader = {
    efi.canTouchEfiVariables = true;
    # Disallow editing kernel command-line to prevent easy root via init=/bin/sh
    systemd-boot.editor = false;
  };

  # Pass through TRIM requests at a slight security risk
  boot.initrd.luks.devices = {
    crypted.allowDiscards = true;
  };

  preservation.enable = true;
  settings.rollback = {
    enable = true;
    device = "/dev/mapper/crypted";
    after = ["cryptsetup.target"];
  };

  services.fprintd = {
    enable = true;
    tod = {
      enable = true;
      driver = pkgs.libfprint-2-tod1-goodix;
    };
  };

  system.stateVersion = "25.05";
}
