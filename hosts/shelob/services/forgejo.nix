{config, ...}: let
  cfg = config.services.forgejo;
in {
  services.forgejo = {
    enable = true;
    repositoryRoot = "/var/lib/git";
    settings = {
      server = rec {
        DOMAIN = "git.wetheredge.com";
        ROOT_URL = "https://${DOMAIN}";
        PROTOCOL = "http+unix";
      };

      repository = {
        ENABLE_PUSH_CREATE_USER = true;
        DEFAULT_PRIVATE = "private";
      };

      service.DISABLE_REGISTRATION = true;
    };
  };

  services.caddy.virtualHosts = {
    "${cfg.settings.server.DOMAIN}" = {
      extraConfig = "reverse_proxy unix/${cfg.settings.server.HTTP_ADDR}";
      # Bind locally + tailscale
      listenAddresses = ["127.0.0.1" "::1" "100.104.193.124"];
    };
  };

  preservation.preserveAt = {
    state.directories = [
      {
        directory = cfg.stateDir;
        inherit (cfg) user group;
      }
    ];
    data.directories = [
      {
        directory = cfg.repositoryRoot;
        inherit (cfg) user group;
      }
    ];
  };
}
