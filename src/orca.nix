{
  generated,
  appimageTools,
  lib,
  stdenv,
  stdenvNoCC,
  undmg,
}:
let
  system = stdenv.hostPlatform.system;

  source =
    {
      aarch64-darwin = generated.orca-bin-darwin-arm64;
      aarch64-linux = generated.orca-bin-linux-arm64;
      x86_64-darwin = generated.orca-bin-darwin-x64;
      x86_64-linux = generated.orca-bin-linux-x64;
    }
    .${system} or (throw "Unsupported system: ${system}");

  version = lib.removePrefix "v" source.version;

  meta = {
    description = "Agent development environment for orchestrating coding agents";
    homepage = "https://github.com/stablyai/orca";
    changelog = "https://github.com/stablyai/orca/releases/tag/${source.version}";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "orca";
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
  };
in
if stdenv.hostPlatform.isLinux then
  appimageTools.wrapType2 {
    pname = "orca";
    inherit version meta;
    src = source.src;
  }
else
  stdenvNoCC.mkDerivation {
    pname = "orca";
    inherit version meta;
    src = source.src;

    nativeBuildInputs = [ undmg ];

    sourceRoot = "Orca.app";

    installPhase = ''
      runHook preInstall

      mkdir -p "$out/Applications/Orca.app"
      cp -R . "$out/Applications/Orca.app"
      mkdir -p "$out/bin"
      ln -s "$out/Applications/Orca.app/Contents/MacOS/Orca" "$out/bin/orca"

      runHook postInstall
    '';

    dontFixup = true;
  }
