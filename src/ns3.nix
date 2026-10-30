{
  fetchzip,
  clangStdenv,
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
clangStdenv.mkDerivation {
  pname = "ns3";
  version = "3.47";

  inherit src;

  sourceRoot = "source/ns-3.47";

  nativeBuildInputs = [
    python3
    cmake
  ];

  postPatch = ''
    substituteInPlace contrib/lorawan/model/logical-lora-channel.cc \
      --replace-fail '#include "logical-lora-channel.h"' \
      '#include "logical-lora-channel.h"
    #include "ns3/log.h"'
    substituteInPlace src/internet/model/ipv4-l3-protocol.cc \
      --replace-fail '        uint32_t ifaceIndex = 0;' "" \
      --replace-fail 'ifaceIter++, ifaceIndex++' 'ifaceIter++'
  '';
}
