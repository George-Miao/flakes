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
      aarch64-darwin = generated.oh-my-pi-darwin-arm64;
      aarch64-linux = generated.oh-my-pi-linux-arm64;
      x86_64-darwin = generated.oh-my-pi-darwin-x64;
      x86_64-linux = generated.oh-my-pi-linux-x64;
    }
    .${system} or (throw "Unsupported system: ${system}");

  version = lib.removePrefix "v" platform.version;
in
stdenvNoCC.mkDerivation {
  pname = "oh-my-pi";
  inherit version;
  inherit (platform) src;

  dontUnpack = true;
  dontBuild = true;
  dontConfigure = true;

  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [ autoPatchelfHook ];
  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [ stdenv.cc.cc.lib ];

  installPhase = ''
    runHook preInstall

    install -Dm755 $src $out/bin/omp

    runHook postInstall
  '';

  meta = {
    description = "AI coding agent for the terminal";
    homepage = "https://github.com/can1357/oh-my-pi";
    license = lib.licenses.mit;
    mainProgram = "omp";
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
  };
}
