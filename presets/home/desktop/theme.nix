{pkgs, ...}: {
  home.pointerCursor = {
    enable = true;
    gtk.enable = true;
    package = pkgs.afterglow-cursors-recolored;
    name = "Afterglow-Recolored-Catppuccin-Macchiato";
    size = 24;
  };

  gtk.enable = true;
}
