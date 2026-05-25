{
  lib,
  osConfig,
  pkgs,
  ...
}: let
  interpTheme = "$(${pkgs.darkman}/bin/darkman get)";
  darkLight = var: dark: light: ''test "${var}" = 'dark' && echo ${dark} || echo ${light}'';

  helixThemeDir = "~/.config/helix/themes";
  helixSystemToml = "${helixThemeDir}/system.toml";
  setHelixTheme = var: ''echo "inherits = '$(${darkLight var "catppuccin_mocha" "catppuccin_latte"})'" > ${helixSystemToml}'';

  setNiriTheme = var: ''ln -sf "$HOME/.config/niri/colors/${var}.kdl" ~/.config/niri/colors.kdl'';
in {
  gtk.enable = true;

  home.pointerCursor = {
    enable = true;
    gtk.enable = true;
    package = pkgs.afterglow-cursors-recolored;
    name = "Afterglow-Recolored-Catppuccin-Macchiato";
    size = 24;
  };

  services.darkman = {
    enable = true;
    settings = {
      usegeoclue = osConfig.services.geoclue2.enable;
      lat = 42.6;
      lng = -72.6;
    };
    scripts = {
      gtk = ''${pkgs.dconf}/bin/dconf write /org/gnome/desktop/interface/color-scheme "'prefer-$1'"'';
      helix = ''
        ${setHelixTheme "$1"}
        pkill -USR1 hx
      '';
      niri = setNiriTheme "$1";
    };
  };

  home.activation = {
    initialHelixTheme = lib.hm.dag.entryAfter ["writeBoundary"] ''
      if [ ! -e ${helixSystemToml} ]; then
        run mkdir -p ${helixThemeDir}
        run ${setHelixTheme interpTheme}
      else
        verboseEcho 'helix system.toml already exists'
      fi
    '';
    initialNiriTheme = lib.hm.dag.entryAfter ["writeBoundary"] ''
      run ${setNiriTheme interpTheme}
    '';
  };

  programs.helix.settings.theme = "system";
}
