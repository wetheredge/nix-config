{
  programs.atuin = {
    enable = true;
    settings = {
      workspaces = true;
    };
  };

  preservation.preserveAt.state.directories = [
    ".local/share/atuin"
  ];
}
