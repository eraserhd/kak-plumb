{ stdenv, lib, fetchFromGitHub, kakoune-unwrapped, plan9port, ... }:

stdenv.mkDerivation rec {
  pname = "kak-plumb";
  version = "0.1.1";

  src = ./.;

  installPhase = ''
    mkdir -p $out/bin $out/share/kak/autoload/plugins/
    substitute rc/plumb.kak $out/share/kak/autoload/plugins/plumb.kak \
      --replace '9 plumb' '${plan9port}/bin/9 plumb'
    cp rc/plumbing.kak $out/share/kak/autoload/plugins/plumbing.kak
    substitute edit-client $out/bin/edit-client \
      --replace '9 9p' '${plan9port}/bin/9 9p' \
      --replace 'kak -p' '${kakoune-unwrapped}/bin/kak -p'
    chmod +x $out/bin/edit-client
  '';

  meta = with lib; {
    description = "Kakoune integration with the Plan 9 plumber";
    homepage = https://github.com/eraserhd/kak-plumb;
    license = licenses.unlicense;
    maintainers = with maintainers; [ eraserhd ];
    platforms = platforms.all;
  };
}
