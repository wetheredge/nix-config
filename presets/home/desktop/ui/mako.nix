{lib, ...}: {
  services.mako = {
    enable = true;
    settings = {
      anchor = "bottom-left";
      margin = 8;
      outer-margin = "0,0,16,48";
      border-radius = 8;
      border-size = 1;
    };
    extraConfig = ''
      sort=-priority
      sort=+time

      include=~/.config/mako/colors.conf
    '';
  };

  xdg.configFile = let
    mkConf = lib.generators.toINIWithGlobalSection {};
  in {
    # catppuccin latte
    "mako/colors/light.conf".text = mkConf {
      globalSection = {
        background-color = "#e6e9ef"; # mantle
        text-color = "#4c4f69"; # text
        border-color = "#7287fd"; # lavender
      };
      sections = {
        "urgency=low".border-color = "#bcc0cc"; # surface1
        "urgency=high".border-color = "#d20f39"; # red
      };
    };

    # catppuccin mocha
    "mako/colors/dark.conf".text = mkConf {
      globalSection = {
        background-color = "#181825"; # mantle
        text-color = "#cdd6f4"; # text
        border-color = "#b4befe"; # lavender
      };
      sections = {
        "urgency=low".border-color = "#45475a"; # surface1
        "urgency=high".border-color = "#f38ba8"; # red
      };
    };
  };
}
