{
  programs.atuin = {
    enable = true;
    settings = {
      filter_mode = "workspace";
      workspaces = true;
    };
  };

  preservation.preserveAt.state.directories = [
    ".local/share/atuin"
  ];
}
