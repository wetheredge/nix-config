{config, ...}: let
  cfg = config.services.grafana;
in {
  services.grafana = {
    enable = true;
    settings = {
      server = rec {
        domain = "grafana.wetheredge.com";
        protocol = "socket";
        inherit (config.sockets.sockets.grafana) socket;
        socket_mode = "0666";
        root_url = "https://${domain}";
      };

      auth.disable_login_form = true;
      "auth.basic".enabled = false;
      "auth.generic_oauth" = {
        enabled = true;
        name = "Authelia";
        icon = "signin";
        scopes = "openid profile email groups";
        empty_scopes = false;
        auth_url = "https://auth.wetheredge.com/api/oidc/authorization";
        token_url = "https://auth.wetheredge.com/api/oidc/token";
        api_url = "https://auth.wetheredge.com/api/oidc/userinfo";
        use_pkce = true;
        login_attribute_path = "preferred_username";
        groups_attribute_path = "groups";
        name_attribute_path = "name";
        role_attribute_path = "contains(groups[*], 'admin') && 'Admin' || 'Viewer'";
      };

      users = {
        allow_org_create = false;
        default_theme = "system";
      };

      cloud_migration.enabled = false;
    };
  };

  sockets.sockets.grafana = {};

  systemd.services.grafana.serviceConfig = {
    EnvironmentFile = config.age.secrets.grafana.path;
  };

  services.caddy.virtualHosts = {
    "${cfg.settings.server.domain}" = {
      extraConfig = "reverse_proxy unix/${cfg.settings.server.socket}";
      # Bind locally + tailscale
      listenAddresses = ["127.0.0.1" "::1" "100.121.216.28"];
    };
  };

  preservation.preserveAt.data.directories = [
    {
      directory = cfg.dataDir;
      user = "grafana";
      group = "grafana";
    }
  ];
}
