{
  config,
  lib,
  ...
}: let
  cfg = config.services.wren.caddy;
  caddyCfg = config.services.caddy;
in {
  options.services.wren.caddy = with lib; {
    enable = mkEnableOption "caddy";

    interface = mkOption {
      type = types.str;
      default = "eth0";
    };
  };

  config = lib.mkIf cfg.enable {
    services.caddy.enable = true;

    sockets.defaultGroup = caddyCfg.group;

    networking.firewall.interfaces.${cfg.interface} = {
      allowedTCPPorts = [80 443];
      allowedUDPPorts = [443];
    };

    preservation.preserveAt.state.users.${caddyCfg.user}.directories = [
      ".local/share/caddy"
    ];
  };
}
