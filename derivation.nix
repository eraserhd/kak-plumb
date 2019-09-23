{ stdenv, plan9port, ... }:

stdenv.mkDerivation {
  pname = "kak-plumb";
  version = "0.1.0";
  src = ./.;

  installPhase = ''
    mkdir -p $out/share/kak/autoload/plugins/
    substitute rc/plumb.kak $out/share/kak/autoload/plugins/plumb.kak \
      --replace '9 plumb' '${plan9port}/bin/9 plumb'
  '';

  meta = with stdenv.lib; {
    description = "Kakoune integration with the Plan 9 plumber";
    homepage = https://github.com/eraserhd/kak-plumb;
    license = licenses.publicDomain;
    maintainers = with maintainers; [ eraserhd ];
    platforms = platforms.all;
  };
}
