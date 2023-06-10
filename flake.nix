{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    systems.url = "github:nix-systems/default";
    # devenv.url = "github:cachix/devenv";
    devenv.url = "github:smunix/devenv?ref=smunix-patch-1";
    devenv.inputs.nixpkgs.follows = "nixpkgs";
    nix-utils.url = "github:smunix/nix-utils";
    nix-filter.url = "github:numtide/nix-filter";
  };

  outputs = { self, nixpkgs, devenv, systems, ... }@inputs:
    let forEachSystem = nixpkgs.lib.genAttrs (import systems);
    in {
      devShells = forEachSystem (system:
        let pkgs = nixpkgs.legacyPackages.${system};
        in {
          default = devenv.lib.mkShell {
            inherit inputs pkgs;
            modules = [
              (import ./devenv.nix { inherit inputs pkgs; })
              {
                # https://devenv.sh/reference/options/
                packages = [ pkgs.hello ];

                enterShell = ''
                  hello
                '';
              }
            ];
          };
        });
    };
}
