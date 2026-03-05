{ generated, craneLib }:

craneLib.buildPackage (
  generated.verusfmt
  // {
    cargoTestFlags = [ "--no-run" ];
    doCheck = false;
  }
)
