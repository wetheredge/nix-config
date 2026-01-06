{
  config,
  lib,
  ...
}: let
  cfg = config.services.linkding;
in {
  options.services.linkding = with lib; {
    enable = mkEnableOption "linkding";

    image = mkOption {
      description = "docker image to run";
      type = types.str;
      default = "sissbruecker/linkding";
    };

    rev = mkOption {
      description = "docker image tag or hash";
      type = types.str;
      default = "latest";
    };

    port = mkOption {
      type = types.number;
      default = 9090;
    };

    stateDirectory = mkOption {
      type = types.path;
      default = "/var/lib/linkding";
    };

    environmentFile = mkOption {
      description = "Path to a systemd `EnvironmentFile`";
      type = types.nullOr types.path;
      default = null;
      example = "/run/secrets/linkding";
    };
  };

  config = lib.mkIf cfg.enable {
    virtualisation.oci-containers.containers.linkding = {
      autoStart = true;
      image = "${cfg.image}@${cfg.rev}";
      volumes = ["${cfg.stateDirectory}:/etc/linkding/data"];
      ports = ["${toString cfg.port}:9090"];
      environmentFiles = lib.optional (cfg.environmentFile != null) cfg.environmentFile;
      environment = {
        LD_FAVICON_PROVIDER = "https://icons.duckduckgo.com/ip3/{domain}.ico";
      };
    };

    systemd.tmpfiles.settings."10-linkding" = {
      ${cfg.stateDirectory}.d = {
        mode = "0755";
        user = "root";
        group = "root";
      };
    };
  };
}
