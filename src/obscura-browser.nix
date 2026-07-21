{
  generated,
  lib,
  stdenv,
  stdenvNoCC,
  autoPatchelfHook,
}:
let
  system = stdenv.hostPlatform.system;

  platform =
    {
      aarch64-darwin = generated.obscura-browser-bin-darwin-arm64;
      aarch64-linux = generated.obscura-browser-bin-linux-arm64;
      x86_64-darwin = generated.obscura-browser-bin-darwin-x64;
      x86_64-linux = generated.obscura-browser-bin-linux-x64;
    }
    .${system} or (throw "Unsupported system: ${system}");

  version = lib.removePrefix "v" platform.version;

  meta = {
    description = "Lightweight headless browser for AI agents and web scraping";
    homepage = "https://github.com/h4ckf0r0day/obscura";
    license = lib.licenses.asl20;
    maintainers = [ ];
    mainProgram = "obscura";
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
in
{
  obscura-browser-bin = stdenvNoCC.mkDerivation {
    pname = "obscura-browser-bin";
    inherit version meta;

    dontUnpack = true;
    dontBuild = true;
    dontConfigure = true;

    nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [ autoPatchelfHook ];
    buildInputs = lib.optionals stdenv.hostPlatform.isLinux [ stdenv.cc.cc.lib ];

    installPhase = ''
      runHook preInstall

      install -Dm755 ${platform.src}/obscura ${platform.src}/obscura-worker -t $out/bin

      runHook postInstall
    '';
  };
}
