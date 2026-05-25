{lib, ...}: {
  programs.wezterm = {
    enable = true;
    settings = {
      harfbuzz_features = ["zero" "cv02" "cv03" "cv31" "ss03" "ss11"];
      font = lib.generators.mkLuaInline ''
        wezterm.font_with_fallback({
          "Maple Mono",
          "Twitter Color Emoji",
          -- "Nerd Fonts Symbols",
        })
      '';
      font_size = 10;
      line_height = 1.2;
      unicode_version = 14;

      enable_tab_bar = false;
      enable_scroll_bar = true;
      window_padding = {
        left = 0;
        right = 8;
        top = 0;
        bottom = 0;
      };

      swallow_mouse_click_on_window_focus = true;
    };
    extraConfig = ''
      -- Based on <https://wezterm.org/config/lua/wezterm.gui/get_appearance.html>
      local appearance = wezterm.gui and wezterm.gui.get_appearance() or "Dark"
      config.color_scheme = appearance:find("Dark") and "Catppuccin Mocha" or "Catppuccin Latte"
    '';
  };
}
