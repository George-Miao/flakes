{
  lib,
  stdenvNoCC,
  unzip,
  generated,
}:
stdenvNoCC.mkDerivation {
  pname = "xcharter";
  version = generated.xcharter.version;
  src = generated.xcharter.src;

  nativeBuildInputs = [ unzip ];

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    install -Dm444 opentype/*.otf -t "$out/share/fonts/opentype"
    install -Dm444 type1/*.pfb afm/*.afm -t "$out/share/fonts/type1"
    install -Dm444 README "$out/share/doc/xcharter/README"

    runHook postInstall
  '';

  meta = {
    description = "Extended Bitstream Charter fonts with small caps and oldstyle figures";
    homepage = "https://ctan.org/pkg/xcharter";
    license = [
      lib.licenses.bitstreamCharter
      lib.licenses.lppl13c
    ];
    platforms = lib.platforms.all;
  };
}
