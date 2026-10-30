{
  generated,
  vscode,
  buildVscode,
  stdenv,
  curl,
  libsoup_3,
  webkitgtk_4_1,
}:
let
  vsc-system =
    if stdenv.hostPlatform.isDarwin then
      "darwin-arm64"
    else if stdenv.hostPlatform.isAarch then
      "linux-arm64"
    else
      "linux-x64";
  appPath = if stdenv.hostPlatform.isDarwin then "Contents/Resources/app" else "resources/app";
  platformDeps =
    if stdenv.hostPlatform.isLinux then
      [
        libsoup_3
        webkitgtk_4_1
      ]
    else
      [ ];
  mkVscode =
    channel:
    let
      source = generated."vscode-${vsc-system}-${channel}".src;
      package = builtins.fromJSON (builtins.readFile "${source}/${appPath}/package.json");
    in
    (vscode.override {
      isInsiders = channel == "insider";
      buildVscode =
        args:
        buildVscode (
          args
          // {
            src = source;
            version = package.version;
            vscodeVersion = package.version;
          }
        );
    }).overrideAttrs
      (old: {
        buildInputs = old.buildInputs ++ platformDeps ++ [ curl ];
      });
in
{
  vscode = mkVscode "stable";
  vscode-insider = mkVscode "insider";
}
