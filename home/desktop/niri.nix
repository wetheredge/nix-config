{ pkgs, ... }: {
  home.packages = with pkgs; [
    swayimg
    # Needed for gtk-launch for kickoff/menu.sh
    gtk3
  ];

  programs = {
    alacritty.enable = true;
  };

  programs.eww = {
    enable = true;
    configDir = ./eww;
  };
  systemd.user.services = let
    bin = "${pkgs.eww}/bin/eww";
    open = window: {
      Unit = {
        Description = "ElKowars Wacky Widgets (${window})";
        Requires = [ "eww.service" ];
        After = [ "eww.service" ];
      };
      Service = {
        Type = "oneshot";
        ExecStart = "${bin} open --no-daemonize '${window}'";
        ExecStop = "${bin} close --no-daemonize '${window}'";
        RemainAfterExit = true;
      };
      Install = {
        WantedBy = [ "niri.service" ];
      };
    };
  in {
    eww = {
      Unit = {
        Description = "ElKowars Wacky Widgets";
        Documentation = "https://elkowar.github.io/eww";
        # FIXME: Shouldn't these be graphical-session.target?
        After = [ "niri.service" ];
        PartOf = [ "niri.service" ];
      };
      Service = {
        ExecStart = "${bin} daemon --no-daemonize";
        ExecStop = "${bin} kill";
        ExecReload = "${bin} reload";
      };
      Install = {
        WantedBy = [ "niri.service" ];
      };
    };
    eww-open-status = open "status";
    eww-open-workspaces = open "workspaces";
  };

  xdg.configFile."kickoff/menu.sh" = {
    source = ./menu.sh;
    executable = true;
  };
  programs.kickoff = {
    enable = true;
    settings = {
      prompt = ">";
      padding = 150;

      # fonts = [ "Source Sans Pro" "sans-serif" ];
      # font_size = 30;

      # Catppuccin latte
      colors = {
        background = "#eff1f5dd";  # base
        prompt = "#7287fd";        # lavender
        text = "#6c6f85";          # subtext0
        text_query = "#4c4f69";    # text
        text_selected = "#7287fd"; # lavender
      };

      keybindings = {
        paste = [ "ctrl+v" ];
        execute = [ "Return" "KP_Enter" ];
        delete = [ "BackSpace" "Delete" "KP_Delete" ];
        delete_word = [ "ctrl+BackSpace" "ctrl+w" "ctrl+Delete" "ctrl+KP_Delete" ];
        complete = [ "Tab" ];
        nav_up = [ "ctrl+p" "Up" ];
        nav_down = [ "ctrl+n" "Down" ];
        exit = [ "Escape" ];
      };
    };
  };

  programs.wezterm = {
    enable = true;
    extraConfig = builtins.readFile ./wezterm.lua;
  };
}
