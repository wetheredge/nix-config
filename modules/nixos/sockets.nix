{
  config,
  lib,
  ...
}: let
  cfg = config.sockets;
in {
  options.sockets = with lib; {
    defaultGroup = mkOption {
      description = "Default group for all socket directories";
      type = types.nullOr (types.passwdEntry types.str);
      default = null;
    };

    sockets = mkOption {
      default = {};
      type = types.attrsOf (types.submodule ({
        name,
        config,
        ...
      }: {
        options = {
          user = mkOption {
            type = types.passwdEntry types.str;
          };
          group = mkOption {
            type = types.passwdEntry types.str;
          };
          directory = mkOption {
            type = types.str;
          };
          name = mkOption {
            type = types.str;
          };
          socket = mkOption {
            type = types.str;
          };
        };

        config = {
          user = mkDefault name;
          group = mkIf (cfg.defaultGroup != null) (mkDefault cfg.defaultGroup);
          directory = mkDefault "/run/sockets/${config.user}";
          name = mkDefault "${name}.sock";
          socket = mkDefault "${config.directory}/${config.name}";
        };
      }));
    };
  };

  config = lib.mkIf (cfg.sockets != []) {
    systemd.tmpfiles.settings."10-sockets" =
      {
        "/run/sockets".d = {};
      }
      // lib.mapAttrs' (_: socket: {
        name = socket.directory;
        value = {
          d = {
            inherit (socket) user group;
            mode = "0750";
          };
        };
      })
      cfg.sockets;
  };
}
