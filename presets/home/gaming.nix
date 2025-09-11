{pkgs, ...}: {
  home.packages = with pkgs; [
    steamcmd
    steam-tui
  ];

  preservation.preserveAt = {
    data.directories = [
      ".local/share/Replicube"
    ];
    cache.directories = [
      ".steam"
      ".local/share/Steam"
    ];
  };
}
