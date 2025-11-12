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
    envFile = config.age.secrets.backup-desktop-env.path;
    config = {
      repository = {
        repository = "opendal:b2";
        password-file = config.age.secrets.backup-desktop-password.path;
      };
      forget = {
        keep-last = 10;
        keep-within-daily = "2 weeks";
        keep-within-weekly = "2 months";
        keep-monthly = -1;
      };
    };
    timerConfig = {
      OnCalendar = "daily";
      AccuracySec = "1h";
      Persistent = true;
    };
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
  preservation.preserveAt.state.directories = ["/etc/NetworkManager/system-connections"];

  services.tailscale.useRoutingFeatures = "client";

  programs.niri.enable = true;

  programs.appimage = {
    enable = true;
    binfmt = true;
  };

  users.users.${vars.user} = {
    inherit (vars) hashedPassword;
    extraGroups = ["networkmanager"];
  };
}
