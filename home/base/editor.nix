{ pkgs, ... }: {
  programs.helix = {
    enable = true;
    defaultEditor = true;

    settings = {
      theme = "catppuccin_mocha";

      editor = {
        bufferline = "multiple";
        color-modes = true;
        cursorline = true;
        line-number = "relative";
        # rainbow-brackets = true;
        smart-tab.supersede-menu = true;
        true-color = true;

        cursor-shape = {
          insert = "bar";
          normal = "block";
          select = "block";
        };

        indent-guides = {
          render = true;
          # rainbow-option = "normal";
        };

        # lsp.display-inlay-hints = true;

        statusline = {
          left = [ "mode" "spinner" "spacer" "version-control" ];
          center = [ "file-name" "file-modification-indicator" ];
        };
      };
    };

    extraPackages = with pkgs; [
      nixd
    ];
  };
  programs.fish.shellAbbrs.e = "hx";
}
