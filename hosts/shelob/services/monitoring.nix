{config, ...}: let
  inherit (config.services) grafana;
  inherit (config.services.prometheus) exporters;
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
    "${grafana.settings.server.domain}" = {
      extraConfig = "reverse_proxy unix/${grafana.settings.server.socket}";
      # Bind locally + tailscale
      listenAddresses = ["127.0.0.1" "::1" "100.104.193.124"];
    };
  };

  services.prometheus = {
    enable = true;
    port = 3004;

    globalConfig = {
      scrape_interval = "15s";
    };

    scrapeConfigs = [
      {
        job_name = "node";
        static_configs = [
          {targets = ["localhost:${toString exporters.node.port}"];}
        ];
      }
      {
        job_name = "caddy";
        static_configs = [
          {targets = ["localhost:2019"];}
        ];
      }
    ];
  };

  services.prometheus.exporters.node = {
    enable = true;
    port = 9100;
    enabledCollectors = [
      "systemd"
    ];
  };

  preservation.preserveAt.data.directories = [
    {
      directory = grafana.dataDir;
      user = "grafana";
      group = "grafana";
    }
  ];
}
