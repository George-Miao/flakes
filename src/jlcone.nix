{
  generated,
  lib,
  stdenv,
  stdenvNoCC,
  undmg,
  dpkg,
  autoPatchelfHook,
  makeWrapper,
  wrapGAppsHook3,
  alsa-lib,
  at-spi2-atk,
  at-spi2-core,
  cairo,
  cups,
  dbus,
  expat,
  glib,
  gtk3,
  libdrm,
  libgbm,
  libnotify,
  libsecret,
  libuuid,
  libxkbcommon,
  nspr,
  nss,
  pango,
  systemd,
  libx11,
  libxcomposite,
  libxdamage,
  libxext,
  libxfixes,
  libxrandr,
  libxscrnsaver,
  libxtst,
  libxcb,
  xdg-utils,
}:
let
  source =
    {
      x86_64-linux = generated.jlcone-linux-x64;
      aarch64-darwin = generated.jlcone-darwin-arm64;
    }
    .${stdenv.hostPlatform.system};
  meta = {
    description = "JLCPCB desktop client for manufacturing orders";
    homepage = "https://jlcone.com/download";
    license = lib.licenses.unfree;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    platforms = [
      "x86_64-linux"
      "aarch64-darwin"
    ];
    mainProgram = "jlcone";
  };
in
stdenvNoCC.mkDerivation (
  {
    pname = "jlcone";
    inherit (source) src version;
    inherit meta;
    dontConfigure = true;
    dontBuild = true;
  }
  // (
    if stdenv.hostPlatform.isDarwin then
      {
        nativeBuildInputs = [ undmg ];
        sourceRoot = "JLCONE.app";
        installPhase = ''
          runHook preInstall
          mkdir -p $out/Applications/JLCONE.app $out/bin
          cp -R . $out/Applications/JLCONE.app
          ln -s $out/Applications/JLCONE.app/Contents/MacOS/JLCONE $out/bin/jlcone
          runHook postInstall
        '';
        dontFixup = true;
      }
    else
      {
        nativeBuildInputs = [
          dpkg
          autoPatchelfHook
          makeWrapper
          wrapGAppsHook3
        ];
        buildInputs = [
          alsa-lib
          at-spi2-atk
          at-spi2-core
          cairo
          cups
          dbus
          expat
          glib
          gtk3
          libdrm
          libgbm
          libnotify
          libsecret
          libuuid
          libxkbcommon
          nspr
          nss
          pango
          stdenv.cc.cc.lib
          libx11
          libxcomposite
          libxdamage
          libxext
          libxfixes
          libxrandr
          libxscrnsaver
          libxtst
          libxcb
        ];
        runtimeDependencies = [ (lib.getLib systemd) ];
        unpackCmd = ''dpkg-deb --extract "$src" .'';
        sourceRoot = ".";
        dontWrapGApps = true;
        installPhase = ''
          runHook preInstall
          mkdir -p $out/opt $out/bin
          cp -r opt/JLCONE $out/opt/JLCONE
          cp -r usr/share $out/share
          substituteInPlace $out/share/applications/jlcone.desktop \
            --replace-fail '/opt/JLCONE/jlcone' "$out/bin/jlcone"
          runHook postInstall
        '';
        preFixup = ''
          makeWrapper $out/opt/JLCONE/jlcone $out/bin/jlcone \
            "''${gappsWrapperArgs[@]}" \
            --prefix PATH : ${lib.makeBinPath [ xdg-utils ]} \
            --prefix LD_LIBRARY_PATH : ${
              lib.makeLibraryPath [
                libsecret
                libnotify
              ]
            }
        '';
      }
  )
)
