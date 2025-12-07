{
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
