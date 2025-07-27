{ config, lib, pkgs, ... }:
{
  imports = [
    ./disk.nix
    ./hardware-configuration.nix
    ./impermanence.nix
  ];

  boot.loader.systemd-boot = {
    enable = true;
    # Disallow editting kernel command-line to prevent easy root via init=/bin/sh
    editor = false;
  };
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.luks.devices = {
    crypted = {
      device = "/dev/disk/by-partlabel/disk-main-luks";
      allowDiscards = true;
      preLVM = true;
    };
  };

  networking.hostName = "deagol";
  # Pick only one of the below networking options.
  # networking.wireless.enable = true; # wpa_supplicant
  # networking.networkmanager.enable = true;

  time.timeZone = "America/New_York";

  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    earlySetup = true;
    font = "ter-v28n";
    packages = [ pkgs.terminus_font ];
  };

  # CUPS
  # sevices.printing.enable = true;

  # Sound
  # services.pulseaudio.enable = true;
  # OR
  # services.pipewire = {
  #   enable = true;
  #   pulse.enable = true;
  # };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;

  users.users.wren = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    password = "wren";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB+q0xtKrTMzJLwr1rRNcJJzpP/FL1/ugnNF6WC3rE7M me@wetheredge.com"
    ];
  };

  environment.systemPackages = with pkgs; [
    git
    helix
    wget
  ];
  environment.variables.EDITOR = "hx";

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
