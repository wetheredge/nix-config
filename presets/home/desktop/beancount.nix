{pkgs, ...}: {
  home.packages = with pkgs; [
    beancount
    fava
  ];

  settings.languageServers = [pkgs.beancount-language-server];
}
