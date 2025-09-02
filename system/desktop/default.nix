{ ... }: {
  imports = [
    ./ios.nix
    ./keyd.nix
  ];

  time.timeZone = "America/New_York";

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

  services.displayManager.ly.enable = true;
  programs.niri.enable = true;
}
