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

  # Use tailscale ssh instead
  services.openssh.openFirewall = false;

  services.tailscale = {
    authKeyFile = config.age.secrets.tailscale-auth-key.path;
    useRoutingFeatures = "server";
    extraUpFlags = [
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
  };

  documentation.enable = false;
}
