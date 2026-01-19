{
  config,
  lib,
  ...
}: let
  cfg = config.services.miniflux;
  domain = "feeds.wetheredge.com";
in {
  services.miniflux = {
    enable = true;
    adminCredentialsFile = config.age.secrets.miniflux-env.path;
    config = {
      LISTEN_ADDR = config.sockets.sockets.miniflux.socket;
      BASE_URL = "https://${domain}";

      POLLING_LIMIT_PER_HOST = 2;

      CREATE_ADMIN = false;
      DISABLE_AUTH_LOCAL = 1;
      OAUTH2_USER_CREATION = 1;
      OAUTH2_PROVIDER = "oidc";
      OAUTH2_OIDC_DISCOVERY_ENDPOINT = "https://auth.wetheredge.com";
      OAUTH2_OIDC_PROVIDER_NAME = "Authelia";
      OAUTH2_REDIRECT_URL = "https://${domain}/oauth2/oidc/callback";
    };
  };

  sockets.sockets.miniflux = {};

  services.caddy.virtualHosts = {
    ${domain}.extraConfig = "reverse_proxy unix/${cfg.config.LISTEN_ADDR}";
  };

  systemd.services.miniflux.serviceConfig = {
    DynamicUser = lib.mkForce false;
    User = "miniflux";
    Group = "miniflux";
  };
  users = {
    users.miniflux = {
      group = "miniflux";
      isSystemUser = true;
    };
    groups.miniflux = {};
  };
}
