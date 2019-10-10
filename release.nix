{ nixpkgs ? (import ./nixpkgs.nix), ... }:
let
  pkgs = import nixpkgs { config = {}; };
  kak-plumb = pkgs.callPackage ./derivation.nix {};
in {
  test = pkgs.runCommandNoCC "kak-plumb-test" {} ''
    mkdir -p $out
    : ${kak-plumb}
  '';
}