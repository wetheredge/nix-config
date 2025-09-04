{
  projectRootFile = "flake.nix";
  programs = {
    alejandra.enable = true; # formatting
    deadnix.enable = true; # dead code
    statix.enable = true; # static analysis

    just.enable = true;
    stylua.enable = true;
    typos.enable = true;
  };
}
