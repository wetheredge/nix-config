{ vars, ... }: {
  programs.git = {
    enable = true;
    userName = vars.name;
    userEmail = vars.email;

    # Also used by jujutsu
    ignores = [ "*~" ];

    aliases = {
      tree = "log --graph --decorate --pretty=oneline --abbrev-commit --all";
    };

    extraConfig = {
      diff.renames = "copies";
      fetch.pruneTags = true;
      help.autoCorrect = "prompt";
      init.defaultBranch = "main";
      log.date = "human";
      merge.conflictStyle = "diff3";
      rebase.autoSquash = true;
      rebase.missingCommitsCheck = "error";
      stash.showPatch = true;
      status.showStash = true;
      tag.gpgSign = true;
    };
  };

  # programs.git.delta = {
  #   enable = true;
  # };

  programs.jujutsu = {
    enable = true;
    settings = {
      user = {
        inherit (vars) name email;
      };

      git = {
        push-bookmark-prefix = "${vars.devUser}/push-";
        # Automatically track newly discovered remote bookmarks
        auto-local-bookmark = true;
      };
    };
  };

  programs.gh = {
    enable = true;
    settings = {
      git_protocol = "ssh";
    };
    hosts."github.com" = {
      user = vars.devUser;
    };
  };
}
