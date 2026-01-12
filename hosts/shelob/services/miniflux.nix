{
  config,
  lib,
  ...
}: let
  cfg = config.services.miniflux;
  domain = "miniflux.wetheredge.com";
in {
  services.miniflux = {
    enable = true;
    adminCredentialsFile = config.age.secrets.miniflux-env.path;
    config = {
      LISTEN_ADDR = "/run/miniflux/miniflux.sock";
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

  systemd.services.miniflux.serviceConfig = {
    RuntimeDirectoryMode = lib.mkForce 777;
  };

  services.caddy.virtualHosts = {
    ${domain}.extraConfig = "reverse_proxy unix/${cfg.config.LISTEN_ADDR}";
  };

  # age.secrets.miniflux-env = {
  #   owner = cfg.user;
  #   inherit (cfg) group;
  # };
}
