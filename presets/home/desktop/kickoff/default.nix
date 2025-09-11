{pkgs, ...}: {
  home.packages = with pkgs; [
    # Needed for gtk-launch for kickoff/menu.sh
    gtk3
  ];

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
        background = "#eff1f5dd"; # base
        prompt = "#7287fd"; # lavender
        text = "#6c6f85"; # subtext0
        text_query = "#4c4f69"; # text
        text_selected = "#7287fd"; # lavender
      };

      keybindings = {
        paste = ["ctrl+v"];
        execute = ["Return" "KP_Enter"];
        delete = ["BackSpace" "Delete" "KP_Delete"];
        delete_word = ["ctrl+BackSpace" "ctrl+w" "ctrl+Delete" "ctrl+KP_Delete"];
        complete = ["Tab"];
        nav_up = ["ctrl+p" "Up"];
        nav_down = ["ctrl+n" "Down"];
        exit = ["Escape"];
      };
    };
  };

  preservation.preserveAt.state.files = [
    ".cache/kickoff/menu.csv"
  ];
}
