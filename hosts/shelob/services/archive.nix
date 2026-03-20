{
  config,
  lib,
  pkgs,
  ...
}: let
  torPort = 4000;
  privoxyPort = 4001;

  archiveQuery = "#mirror";

  firefoxVersion = pkgs.firefox.version;
  userAgent = "Mozilla/5.0 (X11; Linux x86_64; rv: ${firefoxVersion}) Gecko/20100101 Firefox/${firefoxVersion}";

  user = "archive";
  group = "archive";
in {
  services.tor = {
    enable = true;
    client.enable = true;
    settings.SOCKSPort = [{port = torPort;}];
  };

  services.privoxy = {
    enable = true;
    settings = {
      listen-address = "127.0.0.1:${toString privoxyPort}";
      forward-socks5 = ".onion 127.0.0.1:${toString torPort} .";
    };
  };

  systemd = {
    timers.archive = {
      after = ["network-online.target"];
      requires = ["network-online.target"];
      wantedBy = ["timers.target"];
      timerConfig = {
        OnCalendar = "08:00 UTC";
        RandomizedOffsetSec = "1h";
      };
    };

    services.archive = {
      description = "Archive web sites";

      environment.http_proxy = "http://127.0.0.1:${toString privoxyPort}";
      serviceConfig.EnvironmentFile = config.age.secrets.archive-env.path;

      path = with pkgs; [jq wget2];
      script = ''
        cd "$STATE_DIRECTORY"

        wget2 -qO- --header "Authorization: Token $LINKDING_TOKEN" \
          https://links.wetheredge.com/api/bookmarks/?q=${lib.escapeURL archiveQuery} \
          | jq -cr '.results|map(if .tag_names|contains(["tor"]) then .notes|sub(".*<(?<url>http://[a-z0-9]+\\.onion(/[^>]*)?)>.*"; .url) else .url end).[]' \
          | wget2 -mpkE --no-parent --cut-url-get-vars --xattr \
            --no-robots -U '${userAgent}' \
            -w 1 --random-wait -i -

        test -x ./quirks && ./quirks
      '';

      serviceConfig = {
        User = user;
        Group = group;
        StateDirectory = "archive";
      };
    };
  };

  services.caddy.virtualHosts = {
    "archive.wetheredge.com" = {
      extraConfig = ''
        root /var/lib/archive
        try_files {path} {path}.html
        file_server {
          index index.html
          hide /var/lib/archive/quirks
          browse
        }
      '';
      # Bind locally + tailscale
      listenAddresses = ["127.0.0.1" "::1" "100.104.193.124"];
    };
  };

  users = {
    users.${user} = {
      inherit group;
      isSystemUser = true;
    };
    groups.${group} = {};
  };

  preservation.preserveAt = {
    state.directories = [
      {
        directory = "/var/lib/tor";
        user = "tor";
        group = "tor";
      }
    ];
    data.directories = [
      {
        directory = "/var/lib/archive";
        inherit user group;
      }
    ];
  };
}
