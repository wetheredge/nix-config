{pkgs,...}: {
  home.packages = with pkgs; [
    ente-desktop
    exiftool

    (darktable.override {
      withAi = true;
    })
  ];

  preservation.preserveAt = {
    data.directories = [
      ".config/darktable"
    ];
    cache.directories = [
      ".cache/darktable"
      ".config/ente"
      ".local/share/darktable/models"
    ];
  };
}
