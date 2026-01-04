{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (config.networking) hostName;
in {
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

  security.sudo-rs.wheelNeedsPassword = false;

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

  # Based on <https://github.com/stendler/systemd-ntfy-poweronoff/blob/f1038b7d3277824e4717a71fd081f6dfdd2627f7/ntfy-startup%40.service>
  systemd.services.ntfy-boot = let
    mkNtfy = tag: msg: "${pkgs.curl}/bin/curl --no-progress-meter --fail-with-body -H Authorization:\${NTFY_AUTH} -H Tags:${tag} -d '${msg}' https://ntfy.wetheredge.com/boot";
  in {
    description = "Send a notification on system start up/shut down";
    wantedBy = ["default.target"];
    bindsTo = ["network-online.target"];
    after = ["network-online.target" "multi-user.target"];
    startLimitIntervalSec = 100;
    startLimitBurst = 6;
    serviceConfig = {
      Type = "oneshot";
      Restart = "on-failure";
      RestartSec = 10;
      ExecStart = mkNtfy "green_circle" "%H is online";
      RemainAfterExit = true;
      ExecStop = mkNtfy "red_circle" "%H is shutting down";
      EnvironmentFile = config.age.secrets."ntfy-boot-${hostName}".path;
    };
  };

  settings.demolition.keep.count = lib.mkDefault "3";

  services.wren.backup = let
    backupSecret = suffix: config.age.secrets."backup-${hostName}-${suffix}".path;
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
