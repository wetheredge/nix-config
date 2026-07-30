{
  osConfig,
  config,
  pkgs,
  vars,
  ...
}: {
  programs.git = {
    enable = true;

    # Also used by jujutsu
    ignores = ["*~"];

    settings = {
      user = {
        inherit (vars) name email;
      };

      aliases = {
        tree = "log --graph --decorate --pretty=oneline --abbrev-commit --all";
      };

      credential.helper = "store";
      commit.verbose = true;
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

      url = {
        # Always use ssh auth for personal GH repos
        "git@github.com:${vars.devUser}/".insteadOf = "https://github.com/${vars.devUser}/";
      };
    };
  };

  xdg.configFile."git/credentials".source = config.lib.file.mkOutOfStoreSymlink osConfig.age.secrets.git-credentials.path;

  # programs.git.delta = {
  #   enable = true;
  # };

  programs.jujutsu = {
    enable = true;
    package = pkgs.jujutsu;
    settings = {
      user = {
        inherit (vars) name email;
      };

      ui = {
        default-command = "status";
        diff-editor = ":builtin";
        pager = "less -FRX";
      };

      # Enable colocated git repos by default
      git.colocate = true;

      aliases = let
        execBashScript = script: ["util" "exec" "--" "bash" "-c" script ""];
      in {
        bump = {
          doc = "Advance a bookmark by one revision";
          definition = execBashScript ''
            set -eo pipefail
            if [[ -n "$1" ]]; then
              jj bookmark move "$1" -t "$1+"
            else
              jj bookmark move -f "closest_bookmark(@)" -t "closest_bookmark(@)+"
            fi
          '';
        };
        conflicts = {
          doc = "Open all files with conflicts in $EDITOR";
          definition = execBashScript ''
            set -eo pipefail
            jj show --no-patch -T 'self.conflicted_files().map(|f| f.path())' \
              | xargs -L1 "$EDITOR"
          '';
        };
        gpa = {
          doc = "Push all git remotes";
          definition = execBashScript ''
            set -eo pipefail
            jj --ignore-working-copy git remote list \
              | cut -w -f1 \
              | xargs -L1 jj git push --remote
          '';
        };
        origin-diff = {
          doc = "Show local changes to a bookmark relative to origin";
          definition = execBashScript ''
            jj --ignore-working-copy diff -f "$1@origin" -t "$1"
          '';
        };
        # <https://zerowidth.com/2025/jj-tips-and-tricks/#bookmarks-and-branches>
        tug = {
          doc = "Move the most recent bookmark to @-";
          definition = ["bookmark" "move" "--from" "closest_bookmark(@-)" "--to" "@-"];
        };
      };

      revset-aliases = {
        "closest_bookmark(to)" = "heads(::to & bookmarks())";
      };

      templates = {
        git_push_bookmark = ''"${vars.devUser}/push-" ++ change_id.short()'';
        # Include diff in commit description editor
        # <https://jj-vcs.github.io/jj/v0.34.0/config/#default-description>
        draft_commit_description = ''
          concat(
            coalesce(description, default_commit_description, "\n"),
            surround(
              "\nJJ: Changes to be committed:\n",
              "",
              indent("JJ:     ", diff.stat(72)),
            ),
            "\nJJ: ignore-rest\n",
            diff.git(),
          )
        '';
      };

      revset-aliases = {
        "ahead()" = "remote_bookmarks()..bookmarks()";
        "behind()" = "bookmarks()..remote_bookmarks()";
      };
    };
  };

  programs.gh = {
    enable = true;
    gitCredentialHelper.enable = false;
    settings = {
      git_protocol = "ssh";
    };
    hosts."github.com" = {
      user = vars.devUser;
    };
  };
}
