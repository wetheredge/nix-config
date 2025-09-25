{
  config,
  vars,
  ...
}: {
  imports = [
    ./fprint.nix
    ./greeter.nix
    ./ios.nix
    ./keyd.nix
  ];

  nix.extraOptions = ''
    secret-key-files = ${config.age.secrets.nix-secret-key.path}
  '';

  nixpkgs.config.allowUnfree = true;

  boot.loader.timeout = 0;

  services.fwupd.enable = true;

  time.timeZone = "America/New_York";

  services.wren.backup = {
    enable = true;
    passwordFile = config.age.secrets.backup-desktop-password.path;
    envFile = config.age.secrets.backup-desktop-env.path;
  };

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

  services.tailscale.useRoutingFeatures = "client";

  programs.niri.enable = true;

  programs.appimage = {
    enable = true;
    binfmt = true;
  };
}
