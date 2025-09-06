{
  lib,
  pkgs,
  osConfig,
  ...
}: {
  programs.firefox = {
    enable = true;

    languagePacks = ["da" "en-US"];

    policies = {
      # Ads/tracking/telemetry
      DisableFirefoxStudies = true;
      DisableTelemetry = true;
      EnableTrackingProtection.Category = "strict";
      FirefoxSuggest = {
        WebSuggestions = false;
        SponsoredSuggestions = false;
        ImproveSuggest = false;
        Locked = true;
      };
      UserMessaging = {
        ExtensionRecommendations = false;
        FirefoxLabs = false; # Should be disabled by DisableTelemetry
        MoreFromMozilla = false;
      };

      # Unwanted features
      AutofillCreditCardEnabled = false;
      OfferToSaveLogins = false;
      PasswordManagerEnabled = false;
      DisableProfileImport = true;

      # First run
      NoDefaultBookmarks = true;
      OverrideFirstRunPage = "";
      OverridePostUpdatePage = "";
      UserMessaging.SkipOnboarding = true;
      SkipTermsOfUse = true;

      # https://bugzilla.mozilla.org/show_bug.cgi?id=1974147
      Homepage = {
        URL = "about:blank";
        Locked = true;
        StartPage = "none";
      };
      FirefoxHome = {
        Search = true;
        TopSites = false;
        SponsoredTopSites = false;
        Highlights = false;
        Pocket = false;
        Stories = false;
        SponsoredPocket = false;
        SponsoredStories = false;
        Snippets = false;
        Locked = true;
      };

      HttpsOnlyMode = "force_enabled";

      PromptForDownloadLocation = true;

      # Prevent these from getting changed by FF
      Preferences = let
        locked = v: {
          Value = v;
          Status = "locked";
        };
      in {
        "browser.aboutConfig.showWarning" = locked false;

        "browser.startup.homepage" = locked "about:blank";
        "browser.newtabpage.enabled" = locked false;

        "browser.ml.chat.enabled" = locked false;

        # English only for websites
        "intl.accept_languages" = locked "en-us";
        # Danish or English for UI
        "intl.locale.requested" = locked "da,en-US";
        # Use system locale format for dates, etc
        "intl.regional_prefs.use_os_locales" = locked true;
      };
    };

    profiles.default = {
      isDefault = true;

      search = {
        force = true;
        default = "ddg";
        privateDefault = "ddg";

        # Based on <https://wiki.nixos.org/wiki/Firefox#Advanced>
        engines = let
          channel = osConfig.system.nixos.release;
          nixSnowflake = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
          nixSearch = aliases: url: params: {
            definedAliases = aliases;
            icon = nixSnowflake;
            urls = [
              {
                template = url;
                params = lib.mapAttrsToList (name: value: {inherit name value;}) params;
              }
            ];
          };
          searchNixosOrg = aliases: type:
            nixSearch aliases "https://search.nixos.org/${type}" {
              inherit channel;
              query = "{searchTerms}";
            };
        in {
          "Nix Packages" = searchNixosOrg ["@nixpkgs" "@np"] "packages";
          "Nix Options" = searchNixosOrg ["@no"] "options";
          "NixOS Wiki" = nixSearch ["@nw"] "https://wiki.nixos.org/w/index.php" {
            search = "{searchTerms}";
          };
          "Home Manager Options" = nixSearch ["@ho"] "https://home-manager-options.extranix.com" {
            release = "release-${channel}";
            query = "{searchTerms}";
          };
        };
      };
    };
  };
}
