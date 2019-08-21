self: super: {
  kakounePlugins = super.kakounePlugins // {
    kak-plumb = super.callPackage ./derivation.nix {};
  };
}
