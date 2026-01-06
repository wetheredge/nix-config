{
  config,
  lib,
  ...
}: let
  cfg = config.services.gatus;
  host = "status.wetheredge.com";

  user = "gatus";
  group = "gatus";

  stateDir = "/var/lib/private/gatus";
in {
  services.gatus = {
    enable = true;
    environmentFile = config.age.secrets.gatus-env.path;
    settings = {
      web = {
        address = "127.0.0.1";
        port = 3002;
      };

      storage = {
        type = "sqlite";
        path = "${stateDir}/data.db";
      };

      ui = {
        default-sort-by = "group";
        custom-css = ''
          #social {
            display: none;
          }
        '';
      };

      alerting.ntfy = {
        topic = "status";
        url = "https://ntfy.wetheredge.com";
        click = "https://${host}";
        token = "$NTFY_TOKEN";
        default-alert = {
          enabled = true;
          failure-threshold = 1;
          success-threshold = 2;
          send-on-resolved = true;
        };
      };

      endpoints = let
        mkService = name: url: cond: {
          inherit name url;
          group = "services";
          interval = "5m";
          conditions = [
            "[STATUS] == 200"
            cond
          ];
        };
        mkRedir = name: group: url: {
          inherit name url group;
          interval = "15m";
          conditions = ["[STATUS] == 302"];
        };
        mkDomain = domain: {
          name = domain;
          group = "domains";
          url = "https://${domain}";
          interval = "6h";
          conditions = ["[DOMAIN_EXPIRATION] > 720h"];
        };

        defaults = {
          alerts = [{type = "ntfy";}];
          client.ignore-redirect = true;
        };
      in
        lib.map (a: defaults // a) ([
            (mkService
              "Forgejo"
              "https://git.wetheredge.com/api/v1/version"
              "has([BODY].version) == true")
            (mkService
              "FreshRSS"
              "https://feeds.wetheredge.com/api/greader.php"
              "[BODY] == OK")
            (mkService
              "knot"
              "https://knot.wetheredge.com/xrpc/sh.tangled.knot.version"
              "has([BODY].version) == true")
            (mkService
              "ntfy"
              "https://ntfy.wetheredge.com/v1/health"
              "[BODY].healthy == true")
            (mkService
              "pds"
              "https://pds.wetheredge.com/xrpc/_health"
              "has([BODY].version) == true")
            (mkRedir "site" "services" "https://wetheredge.com")
            (mkRedir "homepage" "VerTX" "https://vertx.cc")
            {
              name = "simulator";
              group = "VerTX";
              url = "https://simulator.vertx.cc";
              interval = "15m";
              conditions = ["[STATUS] == 200"];
            }
          ]
          ++ lib.map mkDomain config.wren.private.domains);
    };
  };

  age.secrets.gatus-env = {
    owner = user;
    inherit group;
  };

  services.caddy.virtualHosts = {
    ${host} = {
      extraConfig = "reverse_proxy http://${cfg.settings.web.address}:${toString cfg.settings.web.port}";
      # Bind locally + tailscale
      listenAddresses = ["127.0.0.1" "::1" "100.104.193.124"];
    };
  };

  preservation.preserveAt.state.directories = [
    {
      directory = stateDir;
      inherit user group;
    }
  ];
}
