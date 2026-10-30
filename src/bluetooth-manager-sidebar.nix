{
  generated,
  lib,
  stdenvNoCC,
  autoPatchelfHook,
  copyDesktopItems,
  dpkg,
  makeDesktopItem,
  makeWrapper,
  python3,
  wrapGAppsHook4,
  adwaita-icon-theme,
  glib,
  gsettings-desktop-schemas,
  gtk4,
  gtk4-layer-shell,
  json-glib,
  libadwaita,
  libpulseaudio,
  util-linux,
}:
stdenvNoCC.mkDerivation {
  pname = "bluetooth-manager-sidebar";
  inherit (generated.bluetooth-manager-sidebar) version src;

  nativeBuildInputs = [
    autoPatchelfHook
    copyDesktopItems
    dpkg
    makeWrapper
    python3
    wrapGAppsHook4
  ];

  buildInputs = [
    adwaita-icon-theme
    glib
    gsettings-desktop-schemas
    gtk4
    gtk4-layer-shell
    json-glib
    libadwaita
  ];

  unpackCmd = "dpkg-deb --extract \"$src\" .";
  sourceRoot = ".";
  dontConfigure = true;
  dontBuild = true;
  dontWrapGApps = true;

  installPhase = ''
    runHook preInstall

    install -Dm755 usr/bin/bm-sidebar "$out/bin/bm-sidebar"
    install -Dm755 usr/libexec/bm-sidebar/bm-sidebar-gui \
      "$out/libexec/bm-sidebar/bm-sidebar-gui"
    cp -r usr/share "$out/share"

    # The ELF strings cannot grow. Both wrappers set the working directory to $out.
    python3 - "$out" <<'PY'
    from pathlib import Path
    import sys

    root = Path(sys.argv[1])
    replacements = {
        "bin/bm-sidebar": [
            (b"/usr/libexec/bm-sidebar/bm-sidebar-gui", b"libexec/bm-sidebar/bm-sidebar-gui"),
        ],
        "libexec/bm-sidebar/bm-sidebar-gui": [
            # The checkout CSS path takes priority over the installed CSS path.
            (b"/__w/bluetooth-manager-sidebar/bluetooth-manager-sidebar", b"share/bm-sidebar"),
            (b"/usr/share/bm-sidebar/bm-sidebar.css", b"share/bm-sidebar/bm-sidebar.css"),
        ],
    }
    for name, pairs in replacements.items():
        path = root / name
        data = path.read_bytes()
        for old, new in pairs:
            if len(new) > len(old):
                raise RuntimeError(f"{name}: replacement path is too long: {new!r}")
            needle = b"\0" + old + b"\0"
            count = data.count(needle)
            if count != 1:
                raise RuntimeError(f"{name}: expected one path {old!r}, found {count}")
            replacement = b"\0" + new.ljust(len(old), b"\0") + b"\0"
            data = data.replace(needle, replacement)
        path.write_bytes(data)
    PY

    runHook postInstall
  '';

  preFixup = ''
    wrapProgram "$out/bin/bm-sidebar" --chdir "$out"
    wrapProgram "$out/libexec/bm-sidebar/bm-sidebar-gui" \
      "''${gappsWrapperArgs[@]}" \
      --chdir "$out" \
      --prefix PATH : "${
        lib.makeBinPath [
          libpulseaudio
          util-linux
        ]
      }"
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "dev.relz.BmSidebar";
      desktopName = "Bluetooth Manager Sidebar";
      comment = "Manage Bluetooth devices from a Wayland sidebar";
      exec = "bm-sidebar --toggle";
      icon = "bluetooth-symbolic";
      categories = [
        "System"
        "Settings"
        "HardwareSettings"
      ];
    })
  ];

  meta = {
    description = "GTK4 Bluetooth sidebar for Wayland desktops";
    homepage = "https://github.com/Relz/bluetooth-manager-sidebar";
    license = lib.licenses.gpl3Plus;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    mainProgram = "bm-sidebar";
    platforms = [ "x86_64-linux" ];
  };
}
