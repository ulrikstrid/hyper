{ pkgs, stdenv, lib, nix-filter, ocamlPackages, doCheck }:

with ocamlPackages;
buildDunePackage rec {
  pname = "hyper";
  version = "1.0.0-alpha.1";

  # Using nix-filter means we only rebuild when we have to
  src = with nix-filter.lib;
    filter {
      root = ../.;
      include = [
        "dune-project"
        "hyper.opam"
        "README.md"
        (inDirectory "example")
        (inDirectory "src")
        (inDirectory "test")
      ];
    };

  checkInputs = [ alcotest alcotest-lwt dream ];

  propagatedBuildInputs = [ dream-httpaf dream-pure mirage-crypto-rng uri ] ++ checkInputs;

  inherit doCheck;

  meta = {
    description = "Web client with HTTP/1, HTTP/2, TLS, and WebSocket support";
  };
}
