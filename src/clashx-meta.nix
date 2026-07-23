{
  generated,
  lib,
  stdenvNoCC,
}:
let
  source = generated.clashx-meta;
in
stdenvNoCC.mkDerivation {
  pname = "clashx-meta";
  version = lib.removePrefix "v" source.version;

  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/Applications/ClashX Meta.app"
    cp -R "${source.src}/." "$out/Applications/ClashX Meta.app"

    runHook postInstall
  '';

  dontFixup = true;

  meta = {
    description = "Rule-based proxy client for macOS powered by Mihomo";
    homepage = "https://github.com/MetaCubeX/ClashX.Meta";
    changelog = "https://github.com/MetaCubeX/ClashX.Meta/releases/tag/${source.version}";
    license = lib.licenses.agpl3Only;
    maintainers = [ ];
    platforms = lib.platforms.darwin;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
  };
}
