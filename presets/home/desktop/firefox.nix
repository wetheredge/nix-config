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

      # Prevent these from getting changed by FF
      Preferences =
        lib.mapAttrs (_: v: {
          Value = v;
          Status = "locked";
        }) {
          "browser.aboutConfig.showWarning" = false;

          "browser.startup.homepage" = "about:blank";
          "browser.newtabpage.enabled" = false;

          "browser.ml.chat.enabled" = false;

          # Danish or English for UI
          "intl.locale.requested" = "da,en-US";
          # English only for websites
          "intl.accept_languages" = "en-us";
          "browser.translations.neverTranslateLanguages" = "en";
          # Use system locale format for dates, etc
          "intl.regional_prefs.use_os_locales" = true;
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
          rustLogo = "https://www.rust-lang.org/static/images/favicon.svg";
          mkUrl = template: terms: extraParams: {
            inherit template;
            params =
              lib.mapAttrsToList
              lib.nameValuePair
              ({"${terms}" = "{searchTerms}";} // extraParams);
          };
          searchNixosOrg = aliases: type: {
            definedAliases = aliases;
            icon = nixSnowflake;
            urls = [(mkUrl "https://search.nixos.org/${type}" "query" {inherit channel;})];
          };
          rustdoc = crate: {
            definedAliases = ["@${crate}.rs"];
            icon = rustLogo;
            urls = [(mkUrl "https://doc.rust-lang.org/nightly/std/" "search" {})];
          };
        in {
          "Nix Packages" = searchNixosOrg ["@nixpkgs" "@np"] "packages";
          "Nix Options" = searchNixosOrg ["@no"] "options";
          "NixOS Wiki" = {
            definedAliases = ["@nw"];
            icon = nixSnowflake;
            urls = [(mkUrl "https://wiki.nixos.org/w/index.php" "search" {})];
          };
          "Home Manager Options" = {
            definedAliases = ["@ho"];
            icon = nixSnowflake;
            urls = [(mkUrl "https://home-manager-options.extranix.com" "query" {release = "release-${channel}";})];
          };
          "MDN" = {
            definedAliases = ["@mdn"];
            icon = "https://developer.mozilla.org/favicon.svg";
            urls = [(mkUrl "https://developer.mozilla.org/search" "q" {})];
          };
          "Rust crates (lib.rs)" = {
            definedAliases = ["@rs" "@lib.rs"];
            icon = "https://lib.rs/crates-logo.png";
            urls = [(mkUrl "https://lib.rs/search" "q" {})];
          };
          "Rust crates (crates.io)" = {
            definedAliases = ["@crates"];
            icon = "https://crates.io/assets/cargo.png";
            urls = [(mkUrl "https://crates.io/search" "q" {})];
          };
          "Rust crate docs" = {
            icon = rustLogo;
            urls = [(mkUrl "https://docs.rs/releases/search" "query" {})];
          };
          "Rust std docs" = rustdoc "std";
          "Rust alloc docs" = rustdoc "alloc";
          "Rust core docs" = rustdoc "core";
          "NPM Packages" = {
            definedAliases = ["@npm"];
            icon = "https://static-production.npmjs.com/1996fcfdf7ca81ea795f67f093d7f449.png";
            urls = [(mkUrl "https://www.npmjs.com/search" "q" {})];
          };
          "Wikipedia" = {
            definedAliases = ["@wiki"];
            icon = "https://www.wikipedia.org/static/favicon/wikipedia.ico";
            urls = [(mkUrl "https://www.wikipedia.org/search-redirect.php" "search" {})];
          };
          "Linkding" = {
            definedAliases = ["@link"];
            icon = "https://links.wetheredge.com/static/favicon.ico";
            urls = [(mkUrl "https://links.wetheredge.com/bookmarks" "q" {client = "opensearch";})];
          };
        };
      };
    };
  };

  preservation.preserveAt = {
    state.directories = [
      ".mozilla"
    ];
    cache.directories = [
      ".cache/mozilla"
    ];
  };
}
