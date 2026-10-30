{
  lib,
  stdenvNoCC,
  generated,
}:
let
  variants = [
    "black"
    "dark"
    "light"
  ];
in
stdenvNoCC.mkDerivation {
  pname = "breezex-cursor";
  version = lib.removePrefix "v" generated.breezex-dark.version;

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/share/icons"
    ${lib.concatMapStringsSep "\n" (variant: ''
      tar -xf ${generated."breezex-${variant}".src} -C "$out/share/icons"
    '') variants}

    runHook postInstall
  '';

  meta = {
    description = "Extended Breeze cursor themes in Black, Dark, and Light";
    homepage = "https://github.com/ful1e5/BreezeX_Cursor";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.linux;
  };
}
