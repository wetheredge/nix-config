{pkgs, ...}: {
  home.packages = with pkgs; [
    (writeShellScriptBin "kickoff-launcher" ''
      echo $XDG_DATA_DIRS \
        | sed 's|:|/applications\n|g' \
        | xargs ${fd}/bin/fd -tf -tl -e desktop . 2>/dev/null \
        | xargs ${ripgrep}/bin/rg --files-without-match -F NoDisplay=true \
        | while read file; do echo "$(${ripgrep}/bin/rg -m 1 ^Name= "$file" | cut -d= -f2)=${gtk3}/bin/gtk-launch $${file##*/}"; done \
        | sort --ignore-case --unique \
        | kickoff --from-stdin --history ~/.local/share/kickoff/menu.csv
    '')
  ];

  programs.kickoff = {
    enable = true;
    settings = {
      prompt = ">";
      padding = 150;

      fonts = ["sans-serif"];
      font_size = 30;

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

  preservation.preserveAt.state.directories = [
    ".local/share/kickoff"
  ];
}
