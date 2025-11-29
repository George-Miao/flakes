pkgs:
let
  generated = import ./generated.nix pkgs;
  vsc-system =
    if pkgs.stdenv.hostPlatform.isDarwin then
      "darwin"
    else if pkgs.stdenv.hostPlatform.isAarch then
      "linux-arm64"
    else
      "linux-x64";
in
{
  vscode = pkgs.vscode.overrideAttrs (
    f: old: {
      inherit (old) buildInputs;
      src = generated."vscode-${vsc-system}-stable".src;
      version = "latest";
    }
  );
  vscode-insider =
    let
      platformDeps =
        with pkgs;
        if stdenv.hostPlatform.isLinux then
          [
            libsoup_3
            webkitgtk_4_1
          ]
        else
          [ ];
      extraBuildInputs = platformDeps ++ [
        pkgs.curl
      ];
    in
    (pkgs.vscode.override {
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
