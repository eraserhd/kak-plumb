let
  pkgs = import <nixpkgs> {
    config = {};
    overlays = [
      (import ./overlay.nix)
    ];
  };
in pkgs.kakounePlugins.kak-plumb
