{pkgs,...}: {
  home.packages = with pkgs; [
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
      ".local/share/darktable/models"
    ];
  };
}
