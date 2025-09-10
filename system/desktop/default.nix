{
  imports = [
    ./greeter.nix
    ./ios.nix
    ./keyd.nix
    ./pam-fprint.nix
  ];

  nixpkgs.config.allowUnfree = true;

  boot.loader.timeout = 0;

  time.timeZone = "America/New_York";

  # CUPS
  # services.printing.enable = true;

  # Sound
  # services.pulseaudio.enable = true;
  # OR
  # services.pipewire = {
  #   enable = true;
  #   pulse.enable = true;
  # };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;

  programs.niri.enable = true;
}
