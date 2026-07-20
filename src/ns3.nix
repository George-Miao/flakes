{
  fetchzip,
  stdenv,
  python3,
  cmake,
  ...
}:
let
  src = fetchzip {
    url = "https://www.nsnam.org/releases/ns-allinone-3.47.tar.bz2";
    hash = "sha256-iMM4OwG2osuYK6O6sUBC5nOY0BzvcO+nOIkiKmOtEls=";
  };
in
stdenv.mkDerivation {
  pname = "ns3";
  version = "3.47";

  inherit src;

  sourceRoot = "source/ns-3.47";

  nativeBuildInputs = [
    python3
    cmake
  ];
}
