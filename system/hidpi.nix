{ config, options, lib, pkgs, ... }: with lib; {
  options.profiles.hidpi = mkOption {
    type = types.bool;
    default = false;
  };

  config.console = mkIf config.profiles.hidpi {
    earlySetup = true;
    font = "ter-v28n";
    packages = [ pkgs.terminus_font ];
  };
}
