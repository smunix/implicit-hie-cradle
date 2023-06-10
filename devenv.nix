{ inputs, pkgs, ... }:
with pkgs.haskell.lib;
with inputs.nix-utils.lib;
with inputs.nix-filter.lib;

let
  ghc-version = "96";
  hspkgs = fast pkgs.haskell.packages."ghc${ghc-version}" [
    {
      modifiers = [ ];
      extension = hfinal: hprevious: with hfinal; { };
    }
    {
      modifiers = [ doHaddock dontCheck ];
      extension = hfinal: hprevious:
        with hfinal; {
          implicity-hie-cradle = callCabal2nixWithOptions "implicity-hie-cradle"
            (filter { root = inputs.self; }) ("") { };
        };
    }
  ];
in with pkgs; {
  env.GREET = "devenv";
  packages = [
    direnv
    nix-direnv-flakes
    git
    hpack
    (with hspkgs;
      ghcWithPackages
      (p: with p; [ cabal-install implicit-hie implicity-hie-cradle ]))
    toybox
  ];
  scripts.hello.exec = "echo hello from $GREET";
  scripts.repl.exec =
    "${ghcid}/bin/ghcid -W -a -c cabal repl lib:implicity-hie-cradle";
  enterShell = ''
    hello
    git --version
    # ${hpack}/bin/hpack -f package.yaml
  '';
  pre-commit.hooks = {
    hpack.enable = true;
    fourmolu.enable = true;
    nixfmt.enable = true;
  };
}
