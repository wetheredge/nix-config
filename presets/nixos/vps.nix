{
  config,
  lib,
  ...
}: {
  boot = {
    loader.efi.canTouchEfiVariables = true;
    kernelParams = [
      # Name interfaces by order instead of PCIe addresses (eth* vs enp*)
      "net.ifnames=0"
    ];
  };

  # Various GUI or interactive features not needed on a VPS; largely based on
  # <https://github.com/nix-community/srvos/blob/c04379f95fca70b38cdd45a1a7affe6d4226912b/nixos/server/default.nix>
  documentation.enable = false;
  environment.stub-ld.enable = false;
  fonts.fontconfig.enable = false;
  programs.command-not-found.enable = false;
  xdg = {
    autostart.enable = false;
    icons.enable = false;
    menus.enable = false;
    mime.enable = false;
    sounds.enable = false;
  };

  time.timeZone = "UTC";

  networking = {
    # Quad9
    nameservers = [
      "9.9.9.9"
      "149.112.112.112"
      "2620:fe::fe"
      "2620:fe::9"
    ];
    firewall.trustedInterfaces = [config.services.tailscale.interfaceName];
  };

  # Ideally, use tailscale ssh. Specific allowlist if required.
  services.openssh = {
    enable = lib.mkDefault false;
    openFirewall = false;
    settings = {
      AllowUsers = [];
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  services.tailscale = {
    authKeyFile = config.age.secrets.tailscale-auth-key.path;
    useRoutingFeatures = "server";
    extraSetFlags = [
      "--ssh"
    ];
  };

  services.wren.backup = let
    backupSecret = suffix: config.age.secrets."backup-${config.networking.hostName}-${suffix}".path;
  in {
    enable = lib.mkDefault true;
    envFile = lib.mkDefault (backupSecret "env");
    config = {
      repository = {
        repository = "opendal:b2";
        password-file = lib.mkDefault (backupSecret "password");
      };
      forget = {
        keep-tags = ["manual"];
        keep-within-hourly = "1 week";
        keep-within-daily = "1 month";
        keep-within-weekly = "1 year";
        keep-monthly = -1;
      };
    };

    timerConfig = {
      OnCalendar = "hourly";
      AccuracySec = "5m";
      RandomizedDelaySec = "15m";
      FixedRandomDelay = true;
    };
  };
}
