{
  config,
  lib,
  ...
}: let
  toUpperSnakeCase = s:
    s
    |> lib.split "[[:upper:]]"
    |> lib.map (a:
      if lib.isList a
      then ["_"] ++ a
      else [(lib.toUpper a)])
    |> lib.flatten
    |> lib.concatStrings;
in {
  options.environment.machine-info = with lib; {
    prettyHostname = mkOption {
      default = null;
      type = types.nullOr types.str;
      description = "Human-readable form of the system hostname";
    };
    iconName = mkOption {
      default = null;
      type = types.nullOr types.str;
      description = "An XDG icon to identify this machine";
    };
    chassis = mkOption {
      default = null;
      type = types.nullOr (types.enum ["desktop" "laptop" "convertible" "tablet" "handset" "watch" "server" "embedded" "vm" "container"]);
      description = "Override the detected chassis type.";
    };
    deployment = mkOption {
      default = null;
      type = types.nullOr types.str;
      description = ''
        System deployment environment. Suggested values:
        "development", "integration", "staging", "production".
      '';
    };
    location = mkOption {
      default = null;
      type = types.nullOr types.str;
      description = "Location of the system";
    };
    hardwareVendor = mkOption {
      default = null;
      type = types.nullOr types.str;
      description = "Override the hardware vendor from DMI or hwdb";
    };
    hardwareModel = mkOption {
      default = null;
      type = types.nullOr types.str;
      description = "Override the hardware model from DMI or hwdb";
    };
  };

  config.environment.etc.machine-info = with lib; rec {
    enable = mkDefault (text != "");
    text =
      config.environment.machine-info
      |> filterAttrs (_: isString)
      |> mapAttrsToList (key: value: "${toUpperSnakeCase key}=${value}")
      |> toString;
  };
}
