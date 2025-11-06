{
  config,
  pkgs,
  vars,
  ...
}: let
  hostname = "feeds.wetheredge.com";
  inherit (cfg) user;
  inherit (config.users.users.${user}) group;

  cfg = config.services.freshrss;
in {
  services.freshrss = {
    enable = true;
    baseUrl = "https://${hostname}";
    virtualHost = hostname;
    webserver = "caddy";
    defaultUser = vars.user;
    passwordFile = config.age.secrets.freshrss-password.path;

    extensions = with pkgs.freshrss-extensions; [
      reading-time

      (buildFreshRssExtension {
        FreshRssExtUniqueId = "ComicsInFeed";
        pname = "comics-in-feed";
        version = "1.5.1";
        src = pkgs.fetchFromGitHub {
          owner = "giventofly";
          repo = "freshrss-comicsinfeed";
          rev = "525027dafe9c6a80c4aee4b11cee1007416bad7a";
          hash = "sha256-9G7B3SfpaXJQmJ4WL0VwkEkdXZuCflRWonX+lzIKfKc=";
        };
      })
    ];
  };

  age.secrets.freshrss-password = {
    inherit group;
    owner = user;
  };

  preservation.preserveAt.data.directories = [
    {
      directory = cfg.dataDir;
      inherit user group;
    }
  ];
}
