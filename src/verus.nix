pkgs: generated:
let
  system = pkgs.stdenv.hostPlatform.system;
  src =
    if system == "x86_64-linux" then
      generated.verus-linux-x64
    else if system == "aarch64-darwin" then
      generated.verus-darwin-arm64
    else if system == "x86_64-darwin" then
      generated.verus-darwin-x64
    else
      throw "Unsupported system: ${system}";
in
pkgs.stdenv.mkDerivation {
  pname = "verus";
  inherit (src) version src;

  installPhase = ''
    mkdir -p $out
    cp -r $src/* $out/
    mkdir -p $out/bin
    for bin in verus cargo-verus rust_verify z3; do
      ln -s $out/$bin $out/bin/$bin
    done
  '';
}
