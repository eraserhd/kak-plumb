{ nixpkgs ? (import ./nixpkgs.nix), ... }:
let
  pkgs = import nixpkgs { config = {}; };
  kak-plumb = pkgs.callPackage ./derivation.nix {};
in {
  test = pkgs.stdenv.mkDerivation {
    name = "kak-plumb-test-2019.10.10";
    src = ./.;

    buildInputs = [ pkgs.bash pkgs.kakoune-unwrapped ];
    buildPhase = ''
      patchShebangs --build test/9
      ${pkgs.bash}/bin/bash test/tests.bash
    '';
    installPhase = ''
      mkdir -p "$out"
    '';
  };
}
