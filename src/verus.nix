{
  toolchain ? "nightly-x86_64-nixos-nixos",
  stdenvNoCC,
  writeTextFile,
  generated,
  python3,
}:
let
  system = stdenvNoCC.hostPlatform.system;
  rustupSrc = ''
    #!${python3}/bin/python3
    """
    Spoof rustup.
    """

    import argparse
    import subprocess

    parser = argparse.ArgumentParser()
    subparsers = parser.add_subparsers()
    parser_show = subparsers.add_parser("show")
    parser_show.add_argument("show")
    parser_toolchain = subparsers.add_parser("toolchain")
    parser_toolchain.add_argument("toolchain")
    parser_run = subparsers.add_parser("run")
    parser_run.add_argument("run", nargs="*")
    args = parser.parse_args()

    if "show" in args and args.show == "active-toolchain":
        print("${toolchain}")
    elif "toolchain" in args and args.toolchain == "list":
        print("${toolchain}")
    elif "run" in args:
        subprocess.run(args.run[1:])
  '';
  rustup = writeTextFile {
    name = "rustup";
    text = rustupSrc;
    executable = true;
  };
  generatedSrc =
    if system == "x86_64-linux" then
      generated.verus-linux-x64
    else if system == "aarch64-darwin" then
      generated.verus-darwin-arm64
    else if system == "x86_64-darwin" then
      generated.verus-darwin-x64
    else
      throw "Unsupported system: ${system}";
in
stdenvNoCC.mkDerivation {
  pname = "verus";
  inherit (generatedSrc) version src;

  installPhase = ''
    mkdir -p $out
    cp -r $src/* $out/
    mkdir -p $out/bin
    cp ${rustup} $out/bin/rustup
    for bin in verus cargo-verus rust_verify z3; do
      ln -s $out/$bin $out/bin/$bin
    done
  '';
}
