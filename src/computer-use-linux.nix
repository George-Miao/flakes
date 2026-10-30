{
  generated,
  lib,
  stdenv,
  stdenvNoCC,
  autoPatchelfHook,
  makeWrapper,
  libxkbcommon,
  wtype,
  xdotool,
  wmctrl,
  xprop,
  desktop ? "all",
  x11Support ? true,
}:
let
  desktops = [
    "all"
    "wayland"
    "gnome"
    "kde"
    "cosmic"
    "x11"
  ];
  waylandSupport = desktop != "x11";
  tools =
    lib.optionals (lib.elem desktop [
      "all"
      "wayland"
    ]) [ wtype ]
    ++ lib.optionals x11Support [
      xdotool
      wmctrl
      xprop
    ];
  arch =
    {
      x86_64-linux = "x86_64";
      aarch64-linux = "aarch64";
    }
    .${stdenv.hostPlatform.system};
  binaries = [
    "computer-use-linux"
  ]
  ++ lib.optional (lib.elem desktop [
    "all"
    "cosmic"
  ]) "computer-use-linux-cosmic"
  ++ lib.optional waylandSupport "computer-use-linux-indicator";
  source = name: generated."${name}-${arch}";
in
assert lib.assertMsg (lib.elem desktop desktops)
  "computer-use-linux: desktop must be one of ${lib.concatStringsSep ", " desktops}";
assert lib.assertMsg (builtins.isBool x11Support)
  "computer-use-linux: x11Support must be a boolean";
assert lib.assertMsg (
  desktop != "x11" || x11Support
) "computer-use-linux: desktop = \"x11\" requires x11Support = true";
stdenvNoCC.mkDerivation {
  pname = "computer-use-linux";
  version = lib.removePrefix "v" (source "computer-use-linux").version;
  srcs = map (name: (source name).src) binaries;

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
  ];
  buildInputs = [ stdenv.cc.cc.lib ];
  runtimeDependencies = lib.optionals (lib.elem desktop [
    "all"
    "gnome"
  ]) [ libxkbcommon ];

  installPhase = ''
    runHook preInstall

    ${lib.concatMapStringsSep "\n" (name: ''
      install -Dm755 ${(source name).src} $out/bin/${name}
    '') binaries}
    ${lib.optionalString (tools != [ ]) ''
      wrapProgram $out/bin/computer-use-linux \
        --prefix PATH : ${lib.makeBinPath tools}
    ''}

    runHook postInstall
  '';

  meta = {
    description = "Linux desktop control through MCP and CLI";
    homepage = "https://github.com/agent-sh/computer-use-linux";
    license = lib.licenses.mit;
    mainProgram = "computer-use-linux";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
  };
}
