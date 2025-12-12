{
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./vcs.nix
  ];

  home.sessionVariables = {
    ASTRO_TELEMETRY_DISABLED = 1;
  };

  home.packages = with pkgs; [
    hyperfine # benchmarking
    lldb # debugger
    scc # count lines of code

    # Rust
    cargo-expand
    cargo-features-manager
  ];

  programs.helix = {
    # language servers
    extraPackages = with pkgs; [
      marksman # markdown
    ];

    languages = {
      language-server = {
        deno-lsp = {
          command = "deno";
          args = ["lsp"];
          config.deno.enable = true;
        };
      };

      language = let
        tsLike = {
          roots = ["deno.json" "deno.jsonc" "package.json"];
          language-servers = ["deno-lsp" "typescript-language-server"];
        };
      in
        lib.mapAttrsToList (name: attrs: {inherit name;} // attrs) {
          javascript = tsLike;
          typescript = tsLike;
        };
    };
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  services.podman.enable = true;

  # Git tag signing
  services.gpg-agent.enable = true;
  programs.gpg = {
    enable = true;
    settings = {
      pinentry-mode = "loopback";
      default-new-key-algo = "ed25519/cert";
      auto-key-retrieve = true;
      keyserver-options = "honor-keyserver-url";
    };
  };

  xdg.configFile."pnpm/rc".text = "update-notifier=false";

  preservation.preserveAt = {
    data.directories = [
      "Projects"
      "Work"
      {
        directory = ".gnupg";
        mode = "0700";
      }
    ];
    state.directories = [
      ".local/share/direnv/allow"
    ];
    cache.directories = [
      ".cache/dprint"
      ".cache/pnpm"
      ".cargo/git"
      ".cargo/registry"
    ];
  };
}
