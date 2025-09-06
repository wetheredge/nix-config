{
  config,
  pkgs,
  ...
}: {
  nixpkgs.overlays = [
    (_final: prev: {
      customGlibcLocales = prev.glibcLocales.overrideAttrs (old: {
        preBuild = ''
          ${old.preBuild}
          cp ${./da_US} ../glibc-${pkgs.glibc.version}/localedata/locales/da_US@wren
          echo 'SUPPORTED-LOCALES=${toString config.i18n.supportedLocales}' > ../glibc-${pkgs.glibc.version}/localedata/SUPPORTED
        '';
      });
    })
  ];

  i18n.glibcLocales = pkgs.customGlibcLocales;
  i18n.extraLocales = ["da_US@wren/UTF-8"];
}
