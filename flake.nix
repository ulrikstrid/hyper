{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    nix-filter.url = "github:numtide/nix-filter";

    ocaml-overlay.url = "github:anmonteiro/nix-overlays";
    ocaml-overlay.inputs.nixpkgs.follows = "nixpkgs";
    ocaml-overlay.inputs.flake-utils.follows = "flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, nix-filter, ocaml-overlay }:
    let
      supported_ocaml_versions = [ "ocamlPackages_4_13" "ocamlPackages_5_00" ];
      out = system:
        let
          pkgs = import nixpkgs {
            inherit system;
            overlays = [ ocaml-overlay.overlays."${system}".default ];
          };
          ocamlPackages_dev = pkgs.ocaml-ng.ocamlPackages;
          hyper = (pkgs.callPackage ./nix {
            inherit nix-filter;
            doCheck = true;
            ocamlPackages = ocamlPackages_dev;
          });
        in {
          devShells = {
            default = (pkgs.mkShell {
              inputsFrom = [ hyper ];
              buildInputs = with pkgs;
                with ocamlPackages_dev; [
                  ocaml-lsp
                  ocamlformat
                  odoc
                  ocaml
                  nixfmt
                ];
            });
          };

          formatter = pkgs.nixfmt;

          packages = { default = hyper; };
        };
    in with flake-utils.lib;
    eachSystem [
      system.x86_64-linux
      system.aarch64-linux
      system.x86_64-darwin
      system.aarch64-darwin
    ] out;

}
