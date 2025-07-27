{ config, lib, pkgs, ... }:
{
  imports = [
    ./disk.nix
    ./hardware-configuration.nix
    ./impermanence.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.luks.devices = {
    crypted = {
      device = "/dev/disk/by-partlabel/disk-main-luks";
      allowDiscards = true;
      preLVM = true;
    };
  };

  networking.hostName = "deagol";

  time.timeZone = "America/New_York";

  i18n.defaultLocale = "en_US.UTF-8";
  # console.font = "";

  users.users.wren = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
  };

  environment.systemPackages = with pkgs; [
    git
    helix
    wget
  ];

  services.spice-vdagentd.enable = true;

  system.stateVersion = "25.05";
}
