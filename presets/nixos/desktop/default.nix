{vars, ...}: {
  imports = [
    ./fprint.nix
    ./greeter.nix
    ./ios.nix
    ./keyd.nix
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

  networking.networkmanager.enable = true;
  users.users.${vars.user}.extraGroups = ["networkmanager"];
  preservation.preserveAt.state.directories = ["/etc/NetworkManager/system-connections"];

  programs.niri.enable = true;
}
