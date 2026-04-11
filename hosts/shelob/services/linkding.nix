{config, ...}: let
  cfg = config.services.linkding;
in {
  services.linkding = {
    enable = true;
    port = 3003;
    environmentFile = config.age.secrets.linkding-env.path;
    settings = {
      LD_FAVICON_PROVIDER = "https://icons.duckduckgo.com/ip3/{domain}.ico";

      # NOTE: must configure a superuser account with an email matching an OIDC user before first run:
      # <https://linkding.link/installation/#user-setup>
      LD_DISABLE_LOGIN_FORM = "True";
      LD_ENABLE_OIDC = "True";
      OIDC_OP_AUTHORIZATION_ENDPOINT = "https://auth.wetheredge.com/api/oidc/authorization";
      OIDC_OP_TOKEN_ENDPOINT = "https://auth.wetheredge.com/api/oidc/token";
      OIDC_OP_USER_ENDPOINT = "https://auth.wetheredge.com/api/oidc/userinfo";
      OIDC_OP_JWKS_ENDPOINT = "https://auth.wetheredge.com/jwks.json";
    };
  };

  services.caddy.virtualHosts = {
    "links.wetheredge.com".extraConfig = "reverse_proxy http://localhost:${toString cfg.port}";
  };

  preservation.preserveAt.data.directories = [
    cfg.dataDir
  ];
}
