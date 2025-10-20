{
  config,
  lib,
  ...
}: let
  # mocha
  catppuccin = {
    crust = "#11111b";
    mantle = "#181825";
    surface0 = "#313244";
    overlay0 = "#6c7086";
    sapphire = "#74c7ec";
    lavender = "#b4befe";
    red = "#f38ba8";
  };
in {
  programs.niri.settings = {
    prefer-no-csd = true;

    screenshot-path = "${config.xdg.userDirs.pictures}/Screenshots/%Y-%m-%d_%H:%M:%S.png";

    hotkey-overlay.skip-at-startup = true;

    input = {
      keyboard.xkb.options = "compose:sclk";
      touchpad.natural-scroll = false;
    };

    cursor = {
      hide-after-inactive-ms = 10000;
      hide-when-typing = true;
    };

    layout = {
      default-column-width.proportion = 0.5;
      preset-column-widths = [
        {proportion = 1. / 3.;}
        {proportion = 1. / 2.;}
        {proportion = 2. / 3.;}
      ];

      gaps = 16;
      struts = {
        top = -8;
        bottom = -8;
        left = 64;
        right = 32;
      };
    };

    overview.backdrop-color = catppuccin.crust;
    layout = {
      background-color = catppuccin.mantle;
      insert-hint.display.color = "${catppuccin.sapphire}80";
      border = {
        enable = true;
        width = 1;
        active.color = catppuccin.lavender;
        inactive.color = catppuccin.surface0;
        urgent.color = catppuccin.red;
      };
      focus-ring = {
        width = 0.5;
        inactive.color = catppuccin.overlay0; # on inactive monitors
        active.color = "transparent";
      };
    };

    window-rules = [
      # 8px corners
      {
        geometry-corner-radius = lib.genAttrs ["top-left" "top-right" "bottom-left" "bottom-right"] (_: 8.);
        clip-to-geometry = true;
      }

      {
        matches = [{is-focused = false;}];
        opacity = 0.92;
      }

      {
        block-out-from = "screen-capture";
        matches = [
          {app-id = "^org\\.keepassxc\\.KeePassXC$";}
          {app-id = "^org\\.gnome\\.World\\.Secrets$";}
          {app-id = "^Bitwarden$";}
        ];
      }
    ];

    binds = with config.lib.niri.actions; let
      inherit (config.lib.niri) actions;
      screenshot = args: {screenshot = [args];};
      screenshot-window = args: {screenshot-window = [args];};
      # FIXME: <https://redirect.github.com/sodiboo/niri-flake/issues/1018>
      screenshot-screen = args: {screenshot-screen = [args];};

      media = device: set: action: {
        allow-when-locked = true;
        action = spawn "wpctl" "set-${set}" "@DEFAULT_AUDIO_${device}" action;
      };
      brightness = value: {
        allow-when-locked = true;
        action = spawn "brightnessctl" "--exponent=1.5" "set" value;
      };

      directions = mods: prefix: mid:
        lib.mapAttrs (_: action: {action = actions."${action}";}) {
          "${mods}+H" = "${prefix}-${mid.x or mid.both}-left";
          "${mods}+J" = "${prefix}-${mid.y or mid.both}-down";
          "${mods}+K" = "${prefix}-${mid.y or mid.both}-up";
          "${mods}+L" = "${prefix}-${mid.x or mid.both}-right";
        };

      workspaceUpDown = mods: prefix: {
        "${mods}+P".action = actions."${prefix}-workspace-up";
        "${mods}+N".action = actions."${prefix}-workspace-down";
      };
    in
      {
        "Mod+Shift+Slash".action = show-hotkey-overlay;

        "Mod+Return".action = spawn "wezterm" "start" "--always-new-process";
        "Mod+W".action = spawn "firefox";
        "Mod+D".action = spawn-sh "~/.config/kickoff/menu.sh | kickoff --from-stdin --history ~/.cache/kickoff/menu.csv";
        # TODO: swaylock
        # "Mod+Alt+L".action = spawn "swaylock";

        XF86AudioRaiseVolume = media "SINK" "volume" "0.1+";
        XF86AudioLowerVolume = media "SINK" "volume" "0.1-";
        XF86AudioMute = media "SINK" "mute" "toggle";
        XF86AudioMicMute = media "SOURCE" "mute" "toggle";
        "Mod+TouchpadScrollUp" = media "SINK" "volume" "0.02+";
        "Mod+TouchpadScrollDown" = media "SINK" "volume" "0.02-";

        XF86MonBrightnessUp = brightness "+5%";
        XF86MonBrightnessDown = brightness "5%-";

        # F13 mapped from tapped super
        XF86Tools.action = toggle-overview;
        "Mod+Q".action = close-window;
        "Mod+F".action = fullscreen-window;
        "Mod+M".action = maximize-column;
        "Mod+C".action = center-column;
        "Mod+Shift+E".action = quit;
        "Mod+Shift+S".action = power-off-monitors;

        Print.action = screenshot {show-pointer = false;};
        "Shift+Print".action = screenshot-window {write-to-disk = true;};
        "Ctrl+Print".action = screenshot-screen {write-to-disk = true;};

        "Mod+R".action = switch-preset-column-width;
        "Mod+Minus".action = set-column-width "-10%";
        "Mod+Equal".action = set-column-width "+10%";

        "Mod+Shift+R".action = reset-window-height;
        "Mod+Shift+Minus".action = set-window-height "-10%";
        "Mod+Shift+Equal".action = set-window-height "+10%";

        "Mod+BracketLeft".action = consume-or-expel-window-left;
        "Mod+BracketRight".action = consume-or-expel-window-right;

        "Mod+Home".action = focus-column-first;
        "Mod+End".action = focus-column-last;
        "Mod+Shift+Home".action = move-column-to-first;
        "Mod+Shift+End".action = move-column-to-last;
      }
      // workspaceUpDown "Mod" "focus"
      // workspaceUpDown "Mod+Shift" "move-column-to"
      // workspaceUpDown "Mod+Ctrl" "move"
      // directions "Mod" "focus" {
        x = "column";
        y = "window";
      }
      // directions "Mod+Shift" "move" {
        x = "column";
        y = "window";
      }
      // directions "Mod+Ctrl" "focus" {both = "monitor";}
      // directions "Mod+Ctrl+Shift" "move" {both = "column-to-monitor";};
  };
}
