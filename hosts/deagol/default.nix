{ config, lib, pkgs, ... }: {
  imports = [
    ./disks.nix
    ./hardware-configuration.nix
    ./impermanence.nix
  ];

  profiles = {
    desktop = true;
    hidpi = true;
  };

  boot.loader = {
    efi.canTouchEfiVariables = true;
    systemd-boot = {
      enable = true;
      # Disallow editting kernel command-line to prevent easy root via init=/bin/sh
      editor = false;
    };
  };

  # Pass through TRIM requests at a slight security risk
  boot.initrd.luks.devices = {
    crypted.allowDiscards = true;
  };

  networking.hostName = "deagol";
  # Pick only one of the below networking options.
  # networking.wireless.enable = true; # wpa_supplicant
  # networking.networkmanager.enable = true;

  services.spice-vdagentd.enable = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  system.stateVersion = "25.05";
}
