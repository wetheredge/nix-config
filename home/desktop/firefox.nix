{
  programs.firefox = {
    enable = true;

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
      };
    };

    profiles.default = {
      isDefault = true;

      search = {
        force = true;
        default = "ddg";
        privateDefault = "ddg";
      };
    };
  };
}
