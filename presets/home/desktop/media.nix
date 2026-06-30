{
  config,
  osConfig,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    ffmpeg-headless
    itch-dl
  ];

  xdg.configFile."itch-dl/config.json".source = config.lib.file.mkOutOfStoreSymlink osConfig.age.secrets.itch-dl.path;

  programs.yt-dlp = {
    enable = true;
    extraConfig = ''
      --embed-thumbnail --embed-metadata
      --embed-subs --write-auto-subs --sub-langs en,en-US --sub-format best
      --prefer-free-formats
      --sponsorblock-remove default
      --progress
    '';
  };
}
