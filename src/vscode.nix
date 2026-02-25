{
  generated,
  vscode,
  stdenv,
  curl,
  libsoup_3,
  webkitgtk_4_1,
}:
let
  vsc-system =
    if stdenv.hostPlatform.isDarwin then
      "darwin"
    else if stdenv.hostPlatform.isAarch then
      "linux-arm64"
    else
      "linux-x64";
  platformDeps =
    if stdenv.hostPlatform.isLinux then
      [
        libsoup_3
        webkitgtk_4_1
      ]
    else
      [ ];
  extraBuildInputs = platformDeps ++ [
    curl
  ];
in
{
  vscode = vscode.overrideAttrs (
    f: old: {
      buildInputs = old.buildInputs ++ extraBuildInputs;
      src = generated."vscode-${vsc-system}-stable".src;
      version = "latest";
    }
  );
  vscode-insider =
    (vscode.override {
      isInsiders = true;
      useVSCodeRipgrep = false;
    }).overrideAttrs
      (
        f: old: {
          buildInputs = old.buildInputs ++ extraBuildInputs;
          src = generated."vscode-${vsc-system}-insider".src;
          version = "latest";
        }
      );
}
